import 'package:image_cropper/image_cropper.dart';

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
