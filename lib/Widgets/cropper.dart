import 'package:image_cropper/image_cropper.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:proyecto_web/Controlador/Componentes/list_Update_Component.dart';

extension ComponenteUpdateExtension on ComponenteUpdate {
  Uint8List? imagenBytes(int index) {
    if (index < 0 || index >= imagenesBase64.length) return null;

    String? base64Str = imagenesBase64[index];
    if (base64Str == null) return null;

    base64Str = base64Str.trim();
    if (base64Str.isEmpty) return null;

    try {
      final regex = RegExp(r'data:image/[^;]+;base64,');
      base64Str = base64Str.replaceAll(regex, '');

      final mod = base64Str.length % 4;
      if (mod != 0) {
        base64Str = base64Str.padRight(base64Str.length + (4 - mod), '=');
      }

      return base64Decode(base64Str);
    } catch (e) {
      return null;
    }
  }
}

class CropAspectRatioPresetCustom4x5 implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (4, 5);
  @override
  String get name => '4x5';
}

class CropAspectRatioPresetCustom3x4 implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (3, 4);

  @override
  String get name => '3x4';
}
