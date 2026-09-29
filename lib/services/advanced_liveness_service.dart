// import 'dart:io';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:image/image.dart' as img;
// import '../enums/liveness_challenge.dart';

// class AdvancedLivenessService {
//   DateTime? _blinkStartTime;
//   void resetBlinkTimer(){
//     _blinkStartTime = null;
//   }

//   bool isFaceAndEyesValid(Face face, int imageWidth, int imageHeight) {
//     final boundingBox = face.boundingBox;

//     // Pastikan wajah tidak terlalu dekat ke tepi frame (terpotong jari/kamera)
//     const margin = 20.0;
//     if (boundingBox.left < margin ||
//         boundingBox.top < margin ||
//         boundingBox.right > imageWidth - margin ||
//         boundingBox.bottom > imageHeight - margin) {
//       return false; // Wajah terpotong di tepi frame
//     }

//     // Cek ketersediaan data probabilitas mata
//     if (face.leftEyeOpenProbability == null || face.rightEyeOpenProbability == null) {
//       return false;
//     }

//     return true;
//   }

//   /// 2. PEMBERANTAS TRIK JARI: Deteksi Kedipan Simultan dengan Rentang Waktu (100 - 400 ms)
//   bool verifySimultaneousBlink(Face face) {
//     final leftProb = face.leftEyeOpenProbability ?? 1.0;
//     final rightProb = face.rightEyeOpenProbability ?? 1.0;

//     // Ambang batas mata tertutup (EAR < 0.20)
//     final isBothClosed = leftProb < 0.20 && rightProb < 0.20;
//     // Ambang batas mata terbuka (EAR > 0.70)
//     final isBothOpen = leftProb > 0.70 && rightProb > 0.70;

//     final now = DateTime.now();

//     if (isBothClosed) {
//       _blinkStartTime ??= now;
//       return false;
//     }

//     if (isBothOpen && _blinkStartTime != null) {
//       final durationMs = now.difference(_blinkStartTime!).inMilliseconds;
//       _blinkStartTime = null; // Reset setelah kedipan terdeteksi

//       // Kedipan mata manusia normal terjadi dalam durasi 100ms - 400ms
//       if (durationMs >= 100 && durationMs <= 400) {
//         return true; // Valid Kedipan Alami
//       }
//     }

//     return false;
//   }

//   /// 3. VERIFIKASI AKSI ORIENTASI WAJAH (Head Pose Estimation)
//   bool verifyHeadPose(Face face, LivenessAction action) {
//     final headEulerAngleY = face.headEulerAngleY ?? 0.0; // Yaw (Kiri/Kanan)
//     final headEulerAngleX = face.headEulerAngleX ?? 0.0; // Pitch (Atas/Bawah)

//     switch (action) {
//       case LivenessAction.turnLeft:
//         return headEulerAngleY > 20.0; // Toleh Kiri
//       case LivenessAction.turnRight:
//         return headEulerAngleY < -20.0; // Toleh Kanan
//       case LivenessAction.lookUp:
//         return headEulerAngleX > 15.0; // Tengok Atas
//       case LivenessAction.blink:
//         return verifySimultaneousBlink(face);
//     }
//   }

//   /// 4. CAPTURE, CROP FACE & COMPRESS FRAME (<= 80 KB, Max 400x400 px, JPEG Quality 75%)
//   Future<File> cropAndCompressFaceImage(File originalImageFile, Face face) async {
//     final bytes = await originalImageFile.readAsBytes();
//     img.Image? srcImage = img.decodeImage(bytes);

//     if (srcImage == null) throw Exception('Gagal memproses gambar wajah');

//     // Potong (Crop) area Bounding Box Wajah dengan Margin 15%
//     final box = face.boundingBox;
//     int marginX = (box.width * 0.15).round();
//     int marginY = (box.height * 0.15).round();

//     int cropX = max(0, box.left.round() - marginX);
//     int cropY = max(0, box.top.round() - marginY);
//     int cropWidth = min(srcImage.width - cropX, box.width.round() + (2 * marginX));
//     int cropHeight = min(srcImage.height - cropY, box.height.round() + (2 * marginY));

//     img.Image croppedFace = img.copyCrop(
//       srcImage,
//       x: cropX,
//       y: cropY,
//       width: cropWidth,
//       height: cropHeight,
//     );

//     // Resize ke Max 400 x 400 px
//     img.Image resizedFace = img.copyResize(
//       croppedFace,
//       width: 400,
//       height: 400,
//       maintainAspect: true,
//     );

//     // Kompres ke JPEG Quality 75%
//     List<int> compressedBytes = img.encodeJpg(resizedFace, quality: 75);

//     // Buat file hasil kompresi di folder temporary
//     final tempDir = Directory.systemTemp;
//     final compressedFile = File('${tempDir.path}/face_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
//     await compressedFile.writeAsBytes(compressedBytes);

//     return compressedFile;
//   }
// }