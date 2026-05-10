import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class AIService {
  Interpreter? _photoQcInterpreter;
  
  Future<void> init() async {
    // Load TensorFlow Lite model untuk Photo QC
    try {
      _photoQcInterpreter = await Interpreter.fromAsset('models/photo_qc_model.tflite');
    } catch (e) {
      print('Model not loaded, using fallback');
    }
  }
  
  // AI Image Quality Check for Print
  Future<Map<String, dynamic>> validatePrintFile(File file) async {
    final bytes = await file.readAsBytes();
    
    // Create multipart request to backend AI
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/api/ai/validate-image'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', file.path));
    
    final response = await request.send();
    final result = await response.stream.bytesToString();
    final data = Map<String, dynamic>.from(JSON.decode(result));
    
    return {
      'isValid': data['valid'] ?? false,
      'issues': data['issues'] ?? [],
      'suggestedFix': data['upscaled'] != null ? 'AI upscale available' : null,
    };
  }
  
  // AI Photo Quality Check for Delivery Evidence
  Future<bool> checkPhotoQuality(File photo) async {
    if (_photoQcInterpreter == null) return true;
    
    final bytes = await photo.readAsBytes();
    var image = img.decodeImage(bytes);
    var resized = img.copyResize(image!, width: 224, height: 224);
    
    // Convert to tensor input
    var input = List.generate(224 * 224 * 3, (i) => 0.0);
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        input[(y * 224 + x) * 3] = pixel.r / 255.0;
        input[(y * 224 + x) * 3 + 1] = pixel.g / 255.0;
        input[(y * 224 + x) * 3 + 2] = pixel.b / 255.0;
      }
    }
    
    var output = List.filled(1 * 2, 0.0).reshape([1, 2]);
    _photoQcInterpreter!.run(input, output);
    
    // Output[0][1] is probability of "clear"
    return output[0][1] > 0.7;
  }
  
  // OCR untuk extract data dari dokumen
  Future<String> extractTextFromDocument(File document) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/api/ai/ocr'),
    );
    request.files.add(await http.MultipartFile.fromPath('document', document.path));
    
    final response = await request.send();
    final result = await response.stream.bytesToString();
    final data = Map<String, dynamic>.from(JSON.decode(result));
    
    return data['text'] ?? '';
  }
  
  // Background Remover
  Future<File> removeBackground(File photo) async {
    // Send to backend for processing with OpenCV
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/api/ai/remove-background'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', photo.path));
    
    final response = await request.send();
    final bytes = await response.stream.toBytes();
    
    final outputFile = File(photo.path.replaceAll('.', '_nobg.'));
    await outputFile.writeAsBytes(bytes);
    return outputFile;
  }
}