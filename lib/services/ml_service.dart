import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class MLService {
  Interpreter? _antiSpoofInterpreter;
  Interpreter? _mobileFaceNetInterpreter;

  bool _isModelLoaded = false;

  /// Inisialisasi & Muat Model TFLite dari assets/models/
Future<void> initializeModels() async {
  if (_isModelLoaded) return;

  try {
    
    _antiSpoofInterpreter = await Interpreter.fromAsset('assets/models/face_antispoof.tflite');
    _mobileFaceNetInterpreter = await Interpreter.fromAsset('assets/models/mobilefacenet.tflite');

    _isModelLoaded = true;
    debugPrint('Model TFLite Anti-Spoofing & MobileFaceNet berhasil dimuat.');
  } catch (e) {
    debugPrint('Detail error load model TFLite: $e'); // Cetak error spesifik di console
    throw Exception('Gagal memuat model Machine Learning: $e');
  }
}

  /// Cek Passive Liveness / Anti-Spoofing (Deteksi Layar HP / Foto Cetak)
  /// Mengembalikan nilai boolean: true = Wajah Asli, false = Fake/Spoof
  Future<bool> checkPassiveLiveness(File imageFile, Face face) async {
    if (!_isModelLoaded) await initializeModels();

    try {
      // Crop area wajah dari gambar foto
      img.Image? croppedFace = await _cropFace(imageFile, face, targetSize: 80);
      if (croppedFace == null) return false;

      // Normalize pixel values (0-255 -> Float32 0.0 - 1.0)
      var input = _imageToFloat32List(croppedFace, 80, 80);
      var reshapedInput = input.reshape([1, 80, 80, 3]);

      // Output tensor untuk model anti-spoofing (2 class: Real / Fake)
      var output = List.filled(1 * 2, 0.0).reshape([1, 2]);

      _antiSpoofInterpreter!.run(reshapedInput, output);

      // Ambil skor probabilitas wajah asli (Index 1)
      double realScore = output[0][1];
      debugPrint('Skor Anti-Spoofing (Real Score): $realScore');

      // Ambang batas (Threshold) wajah asli, misal > 0.6
      return realScore > 0.6;
    } catch (e) {
      debugPrint('Error pada Passive Liveness: $e');
      return false;
    }
  }

  /// Ekstraksi Wajah Menjadi Array Vektor 128-D (MobileFaceNet)
  Future<List<double>> extractFaceEmbedding(File imageFile, Face face) async {
    if (!_isModelLoaded) await initializeModels();

    try {
      // Crop area wajah dari gambar foto (MobileFaceNet standar ukuran 112x112)
      img.Image? croppedFace = await _cropFace(imageFile, face, targetSize: 112);
      if (croppedFace == null) return [];

      // Preprocessing image: Normalize pixel values (-1.0 s/d 1.0)
      var input = _imageToFloat32ListMobileFaceNet(croppedFace, 112, 112);
      var reshapedInput = input.reshape([1, 112, 112, 3]);

      // Output array 128 float
      var output = List.filled(1 * 128, 0.0).reshape([1, 128]);

      _mobileFaceNetInterpreter!.run(reshapedInput, output);

      // Konversi List<dynamic> ke List<double>
      List<double> embedding128D = List<double>.from(output[0]);
      return embedding128D;
    } catch (e) {
      debugPrint('Error ekstraksi face embedding: $e');
      return [];
    }
  }

  /// Helper untuk Crop area bounding box wajah
  Future<img.Image?> _cropFace(File imageFile, Face face, {required int targetSize}) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) return null;

    final rect = face.boundingBox;

    int x = rect.left.toInt().clamp(0, originalImage.width - 1);
    int y = rect.top.toInt().clamp(0, originalImage.height - 1);
    int w = rect.width.toInt().clamp(1, originalImage.width - x);
    int h = rect.height.toInt().clamp(1, originalImage.height - y);

    img.Image cropped = img.copyCrop(originalImage, x: x, y: y, width: w, height: h);
    return img.copyResize(cropped, width: targetSize, height: targetSize);
  }

  /// Preprocessing Float32 untuk Anti-Spoofing (0.0 s/d 1.0)
  Float32List _imageToFloat32List(img.Image image, int width, int height) {
    var buffer = Float32List(1 * width * height * 3);
    int pixelIndex = 0;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        var pixel = image.getPixel(x, y);
        buffer[pixelIndex++] = pixel.r / 255.0;
        buffer[pixelIndex++] = pixel.g / 255.0;
        buffer[pixelIndex++] = pixel.b / 255.0;
      }
    }
    return buffer;
  }

  /// Preprocessing Float32 untuk MobileFaceNet (-1.0 s/d 1.0)
  Float32List _imageToFloat32ListMobileFaceNet(img.Image image, int width, int height) {
    var buffer = Float32List(1 * width * height * 3);
    int pixelIndex = 0;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        var pixel = image.getPixel(x, y);
        buffer[pixelIndex++] = (pixel.r - 127.5) / 128.0;
        buffer[pixelIndex++] = (pixel.g - 127.5) / 128.0;
        buffer[pixelIndex++] = (pixel.b - 127.5) / 128.0;
      }
    }
    return buffer;
  }

  void dispose() {
    _antiSpoofInterpreter?.close();
    _mobileFaceNetInterpreter?.close();
  }
}