import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../enums/liveness_challenge.dart';
import '../services/advanced_liveness_service.dart';
import '../services/location_service.dart';
import '../services/ml_service.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../utils/camera_utils.dart';
import '../widgets/camera_overlay_widget.dart';

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
  final AdvancedLivenessService _livenessService = AdvancedLivenessService();

  // Challenge Sequence untuk Liveness
  late ChallengeSequence _challengeSequence;

  Face? _detectedFace;
  bool _isProcessing = false;
  bool _isLivenessPassed = false;
  String _statusMessage = 'Posisikan wajah Anda di dalam area';

  @override
  void initState() {
    super.initState();
    // Generate 2 tantangan acak (misal: Toleh Kiri -> Kedip Mata)
    _challengeSequence = ChallengeSequence.generateRandom(count: 2);
    _updateChallengeMessage();
    _initializeCameraAndML();
  }

  void _updateChallengeMessage() {
    final current = _challengeSequence.currentAction;
    if (current != null) {
      _statusMessage = 'Tantangan ${_challengeSequence.currentIndex + 1}/${_challengeSequence.actions.length}: ${current.instruction}';
    }
  }

  Future<void> _initializeCameraAndML() async {
    try {
      await _mlService.initializeModels();

      final options = FaceDetectorOptions(
        enableClassification: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.accurate,
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

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing || _isLivenessPassed || !mounted) return;
    _isProcessing = true;

    try {
      final inputImage = CameraUtils.inputImageFromCameraImage(
        image: image,
        controller: _cameraController,
      );
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final faces = await _faceDetector!.processImage(inputImage);
      if (!mounted) return;

      if (faces.isEmpty) {
        setState(() => _statusMessage = 'Posisikan wajah Anda di dalam area');
      } else {
        faces.sort((a, b) {
          final areaA = a.boundingBox.width * a.boundingBox.height;
          final areaB = b.boundingBox.width * b.boundingBox.height;
          return areaB.compareTo(areaA); 
        });
        final mainFace = faces.first;
        // Validasi batas wajah dan probabilitas mata
        final isValidFrame = _livenessService.isFaceAndEyesValid(mainFace);
          if (!isValidFrame) {
          _isProcessing = false;
          return;
        }

        if (!isValidFrame) {
          setState(() => _statusMessage = 'Wajah terlalu dekat / terpotong');
          _isProcessing = false;
          return;
        }

        // 2. Cek aksi tantangan saat ini
        final currentAction = _challengeSequence.currentAction;
        if (currentAction != null) {
          final isActionVerified = _livenessService.verifyHeadPose(mainFace, currentAction);

          if (isActionVerified) {
            _livenessService.resetBlinkTimer();
            _challengeSequence.next(); 

            if (_challengeSequence.isCompleted) {
              _isLivenessPassed = true;
              _detectedFace = mainFace;
              setState(() => _statusMessage = 'Tantangan Selesai! Memproses...');

              await _cameraController!.stopImageStream();
              _onLivenessSuccess();
            } else {
              // Lanjut ke tantangan berikutnya
              setState(() => _updateChallengeMessage());
            }
          } else {
            setState(() => _updateChallengeMessage());
          }
        }
      }
    } catch (e) {
      debugPrint('Error deteksi liveness: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _onLivenessSuccess() async {
    try {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 300));
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        throw Exception('Kamera tidak siap');
      }
      final XFile photo = await _cameraController!.takePicture();
      final File imageFile = File(photo.path);

      if (!mounted) return;

      setState(() => _statusMessage = 'Verifikasi Tekstur Wajah (Anti-Spoof)...');
      if (_detectedFace != null) {
        bool isRealPerson = await _mlService.checkPassiveLiveness(imageFile, _detectedFace!);
        if (!isRealPerson) {
          throw Exception('Terdeteksi Foto/Layar HP! Harap gunakan wajah asli.');
        }
      }

      if (!mounted) return;

      setState(() => _statusMessage = 'Mengekstrak Vektor Wajah 128-D...');
      List<double> faceEmbedding = [];
      if (_detectedFace != null) {
        faceEmbedding = await _mlService.extractFaceEmbedding(imageFile, _detectedFace!);
      }

      if (faceEmbedding.isEmpty) {
        throw Exception('Gagal mengekstrak fitur vektor wajah.');
      }

      if (!mounted) return;

      setState(() => _statusMessage = 'Mengecek Lokasi GPS...');
      final position = await LocationService.getCurrentLocation();

      if (!mounted) return;

      setState(() => _statusMessage = 'Mengirim Data Absensi...');
      final savedEmployeeId = await ApiService.getSavedEmployeeId();

      final response = await ApiService.submitAttendance(
        employeeId: savedEmployeeId,
        latitude: position.latitude,
        longitude: position.longitude,
        faceEmbedding: faceEmbedding,
        type: widget.attendanceType,
        imagePath: imageFile.path, 
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Absensi Berhasil Disimpan!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.primaryRed,
          ),
        );

        if (_cameraController != null && _cameraController!.value.isInitialized) {
          // Reset tantangan jika gagal di tengah jalan
          _challengeSequence = ChallengeSequence.generateRandom(count: 2);
          _isLivenessPassed = false;
          _updateChallengeMessage();
          _cameraController!.startImageStream(_processCameraImage);
        }
      }
    }
  }

  @override
  void dispose() {
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      _cameraController?.stopImageStream();
    }
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
          widget.attendanceType == 'CLOCK_IN' ? 'Clock In Absensi' : 'Clock Out Absensi',
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
                CameraOverlayWidget(
                  isLivenessPassed: _isLivenessPassed,
                  statusMessage: _statusMessage,
                ),
              ],
            ),
    );
  }
}