import 'dart:typed_data';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';

//ZOOM DE IMAENES
class ZoomableImagePage extends StatelessWidget {
  final Uint8List imgBytes;

  const ZoomableImagePage({super.key, required this.imgBytes});

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      isFullScreen: true,
      disabled: true,
      onDismissed: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              minScale: 1.0,
              maxScale: 5.0,
              constrained: true,
              child: Align(
                alignment: Alignment.center,
                child: Image.memory(imgBytes, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                bottom: true,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: 1.0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//DESLIZAR A LOS LADOS
class ZoomableGalleryPage extends StatefulWidget {
  final List<Uint8List> imagenes;
  final int initialIndex;

  const ZoomableGalleryPage({
    super.key,
    required this.imagenes,
    this.initialIndex = 0,
  });

  @override
  State<ZoomableGalleryPage> createState() => _ZoomableGalleryPageState();
}

class _ZoomableGalleryPageState extends State<ZoomableGalleryPage> {
  late final PageController _pageController;
  late final TransformationController _transformationController;
  bool showCloseButton = true;
  bool isZoomed = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _transformationController = TransformationController();

    _transformationController.addListener(() {
      final scale = _transformationController.value.getMaxScaleOnAxis();
      if (scale > 1.0 && !isZoomed) {
        setState(() => isZoomed = true);
      } else if (scale == 1.0 && isZoomed) {
        setState(() => isZoomed = false);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      isFullScreen: true,
      disabled: true,
      onDismissed: () {},
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: isZoomed
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              itemCount: widget.imagenes.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  transformationController: _transformationController,
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 1.0,
                  maxScale: 5.0,
                  constrained: true,
                  child: Center(
                    child: Image.memory(
                      widget.imagenes[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                bottom: true,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: showCloseButton ? 1.0 : 0.0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
