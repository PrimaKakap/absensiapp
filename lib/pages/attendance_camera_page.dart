import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../theme/app_colors.dart';
import '../services/location_service.dart';
import '../services/ml_service.dart';
import '../services/api_service.dart';

class AttendanceCameraPage extends StatefulWidget {
  final String attendanceType; // CLOCK_IN atau CLOCK_OUT

  const AttendanceCameraPage({
    super.key,
    required this.attendanceType,
  });

  @override
  State<AttendanceCameraPage> createState() => _AttendanceCameraPageState();
}

class _AttendanceCameraPageState extends State<AttendanceCameraPage> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  final MLService _mlService = MLService();
  
  Face? _detectedFace;
  bool _isProcessing = false;
  bool _isLivenessPassed = false;
  String _statusMessage = 'Posisikan wajah anda di dalam area';

  @override
  void initState() {
    super.initState();
    _initializeCameraAndML();
  }

  // Inisialisasi kamera depan + detector wajah ML Kit & ML Model
  Future<void> _initializeCameraAndML() async {
    try {
      // Load model TFLite (Anti-Spoofing & MobileFaceNet)
      await _mlService.initializeModels();

      final options = FaceDetectorOptions(
        enableClassification: true,
        performanceMode: FaceDetectorMode.fast,
      );
      _faceDetector = FaceDetector(options: options);

      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      _cameraController!.startImageStream(_processCameraImage);
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inisialisasi kamera/ML: $e')),
        );
      }
    }
  }

  // Pemrosesan tiap frame gambar dari kamera
  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing || _isLivenessPassed) return;
    _isProcessing = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final faces = await _faceDetector!.processImage(inputImage);
      if (faces.isEmpty) {
        setState(() {
          _statusMessage = 'Wajah tidak terdeteksi';
        });
      } else if (faces.length > 1) {
        setState(() {
          _statusMessage = 'Hanya 1 wajah yang diperbolehkan!';
        });
      } else {
        final face = faces.first;
        final leftEyeProb = face.leftEyeOpenProbability ?? 1.0;
        final rightEyeProb = face.rightEyeOpenProbability ?? 1.0;

        // Logic deteksi kedip (Active Liveness)
        if (leftEyeProb < 0.3 && rightEyeProb < 0.3) {
          _isLivenessPassed = true;
          _detectedFace = face; // Simpan objek face untuk di-crop di Step 3
          setState(() {
            _statusMessage = 'Kedipan terdeteksi! Memproses...';
          });

          await _cameraController!.stopImageStream();
          _onLivenessSuccess();
        } else {
          setState(() {
            _statusMessage = 'Silakan Kedipkan Mata Anda';
          });
        }
      }
    } catch (e) {
      debugPrint('Error deteksi wajah: $e');
    } finally {
      _isProcessing = false;
    }
  }

  // Eksekusi setelah Active Liveness (kedip) lolos
  Future<void> _onLivenessSuccess() async {
    try {
      // 1. Ambil Foto
      final XFile photo = await _cameraController!.takePicture();
      final File imageFile = File(photo.path);

      // 2. Passive Liveness (Anti-Spoofing / Layar HP)
      setState(() {
        _statusMessage = 'Verifikasi Tekstur Wajah (Anti-Spoof)...';
      });

      if (_detectedFace != null) {
        bool isRealPerson = await _mlService.checkPassiveLiveness(imageFile, _detectedFace!);
        if (!isRealPerson) {
          throw Exception('Terdeteksi Foto/Layar HP! Harap gunakan wajah asli.');
        }
      }

      // 3. Ekstraksi Vector Embedding 128-D (MobileFaceNet)
      setState(() {
        _statusMessage = 'Mengekstrak Vektor Wajah 128-D...';
      });

      List<double> faceEmbedding = [];
      if (_detectedFace != null) {
        faceEmbedding = await _mlService.extractFaceEmbedding(imageFile, _detectedFace!);
      }

      if (faceEmbedding.isEmpty) {
        throw Exception('Gagal mengekstrak fitur vektor wajah.');
      }

      // 4. Cek Lokasi GPS & Anti-Fake GPS
      setState(() {
        _statusMessage = 'Mengecek Lokasi GPS...';
      });
      final position = await LocationService.getCurrentLocation();

      // 5. Kirim Payload JSON ke Backend NestJS
      setState(() {
        _statusMessage = 'Mengirim Data Absensi...';
      });

      final response = await ApiService.submitAttendance(
        employeeId: 'EMP-001', // Sesuaikan ID karyawan yang aktif
        latitude: position.latitude,
        longitude: position.longitude,
        faceEmbedding: faceEmbedding,
        type: widget.attendanceType,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Absensi Berhasil Disimpan!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Kembali ke beranda
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.primaryRed,
          ),
        );

        // Jika terdeteksi fake/spoof/gagal, kembalikan kamera ke mode stream
        _isLivenessPassed = false;
        _cameraController!.startImageStream(_processCameraImage);
      }
    }
  }

  // Helper Konversi Frame Kamera ke InputImage ML Kit
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    final camera = _cameraController!.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isAndroid) {
      var rotationCompensation = sensorOrientation;
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    } else if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }

    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (image.planes.isEmpty) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    _mlService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.attendanceType == 'CLOCK_IN'
              ? 'Clock In Absensi'
              : 'Clock Out Absensi',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(_cameraController!),
                ),
                Center(
                  child: Container(
                    width: 260,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(160),
                      border: Border.all(
                        color: _isLivenessPassed
                            ? Colors.green
                            : AppColors.accentOrange,
                        width: 4,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}