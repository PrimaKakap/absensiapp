import 'dart:io';
import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import '../enums/liveness_challenge.dart';

class AdvancedLivenessService {
  DateTime? _blinkStartTime;

  void resetBlinkTimer() {
    _blinkStartTime = null;
  }

  /// 1. VALIDASI WAJAH & MATA (Sangat Toleran / Tanpa Batas Margin Ketat)
  bool isFaceAndEyesValid(Face face) {
    // Cek ketersediaan probabilitas mata
    if (face.leftEyeOpenProbability == null || face.rightEyeOpenProbability == null) {
      return false;
    }
    return true;
  }

  /// 2. DETEKSI KEDIPAN (Lebih Sensitif untuk Pengguna Berkacamata)
  bool verifySimultaneousBlink(Face face) {
    final leftProb = face.leftEyeOpenProbability ?? 1.0;
    final rightProb = face.rightEyeOpenProbability ?? 1.0;

    // Ambang batas dinaikkan ke 0.35 agar ramah pengguna berkacamata
    final isBothClosed = leftProb < 0.35 && rightProb < 0.35;
    final isBothOpen = leftProb > 0.65 && rightProb > 0.65;

    final now = DateTime.now();

    if (isBothClosed) {
      _blinkStartTime ??= now;
      return false;
    }

    if (isBothOpen && _blinkStartTime != null) {
      final durationMs = now.difference(_blinkStartTime!).inMilliseconds;
      _blinkStartTime = null;

      // Durasi kedipan fleksibel (80ms - 600ms)
      if (durationMs >= 80 && durationMs <= 600) {
        return true;
      }
    }

    return false;
  }

  /// 3. VERIFIKASI AKSI ORIENTASI WAJAH
  bool verifyHeadPose(Face face, LivenessAction action) {
    final headEulerAngleY = face.headEulerAngleY ?? 0.0; // Yaw (Kiri/Kanan)

    switch (action) {
      case LivenessAction.turnLeft:
        return headEulerAngleY > 15.0; // Sudut dipotong jadi 15 derajat agar tidak terlalu jauh tolehnya
      case LivenessAction.turnRight:
        return headEulerAngleY < -15.0;
      case LivenessAction.blink:
        return verifySimultaneousBlink(face);
    }
  }

  /// 4. CROP & COMPRESS
  Future<File> cropAndCompressFaceImage(File originalImageFile, Face face) async {
    final bytes = await originalImageFile.readAsBytes();
    img.Image? srcImage = img.decodeImage(bytes);

    if (srcImage == null) throw Exception('Gagal memproses gambar wajah');

    final box = face.boundingBox;
    int marginX = (box.width * 0.15).round();
    int marginY = (box.height * 0.15).round();

    int cropX = max(0, box.left.round() - marginX);
    int cropY = max(0, box.top.round() - marginY);
    int cropWidth = min(srcImage.width - cropX, box.width.round() + (2 * marginX));
    int cropHeight = min(srcImage.height - cropY, box.height.round() + (2 * marginY));

    img.Image croppedFace = img.copyCrop(
      srcImage,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    img.Image resizedFace = img.copyResize(
      croppedFace,
      width: 400,
      height: 400,
      maintainAspect: true,
    );

    List<int> compressedBytes = img.encodeJpg(resizedFace, quality: 75);

    final tempDir = Directory.systemTemp;
    final compressedFile = File(
      '${tempDir.path}/face_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await compressedFile.writeAsBytes(compressedBytes);

    return compressedFile;
  }
}