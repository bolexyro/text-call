import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/utils/constants.dart';

class ImageDisplayer extends StatelessWidget {
  // if not for preview, keyInMp and onDelete should be non null
  const ImageDisplayer({
    super.key,
    required this.imagePath,
    this.onDelete,
    this.keyInMap,
    this.forPreview = false,
    required this.isNetworkImage,
  });

  final String imagePath;
  final int? keyInMap;
  final void Function(int key)? onDelete;
  final bool forPreview;
  final bool isNetworkImage;

  void _goFullScreen(BuildContext context, Widget imageWidget) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageDisplayer(
          imagePath: imagePath,
          imageWidget: imageWidget,
          minScale: 1.0,
          maxScale: 3.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = isNetworkImage
        ? CachedNetworkImage(
            imageUrl: imagePath,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Center(
              child:
                  CircularProgressIndicator(value: downloadProgress.progress),
            ),
            errorWidget: (context, url, error) => SvgPicture.asset(
              'assets/icons/offline.svg',
              height: kIconHeight,
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color!,
                BlendMode.srcIn,
              ),
            ),
            fit: BoxFit.contain,
          )
        : Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          );
    return SizedBox(
      height: 400,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                bottom: kSpaceBtwWidgetsInPreviewOrRichTextEditor),
            child: GestureDetector(
              onDoubleTap: () {
                _goFullScreen(context, imageWidget);
              },
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(width: 2),
                ),
                child: Center(
                  child: Hero(
                    tag: imagePath,
                    child: imageWidget,
                  ),
                ),
              ),
            ),
          ),
          if (!forPreview)
            Positioned(
              right: -10,
              top: -10,
              child: GestureDetector(
                onTap: () => onDelete!(keyInMap!),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/delete.svg',
                    colorFilter: const ColorFilter.mode(
                      Color.fromARGB(255, 255, 57, 43),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            right: 10,
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                _goFullScreen(context, imageWidget);
              },
              child: SvgPicture.asset(
                'assets/icons/full-screen.svg',
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                height: kIconHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// for more info on the magic you performed here, you can check this medium blog - https://medium.com/@lanltn/flutter-interactive-viewer-gallery-with-interactiveviewer-55ae260d2014
class FullScreenImageDisplayer extends StatefulWidget {
  const FullScreenImageDisplayer({
    super.key,
    required this.imagePath,
    required this.imageWidget,
    required this.minScale,
    required this.maxScale,
  });

  final String imagePath;
  final Widget imageWidget;
  final double minScale;
  final double maxScale;

  @override
  State<FullScreenImageDisplayer> createState() =>
      _FullScreenImageDisplayerState();
}

class _FullScreenImageDisplayerState extends State<FullScreenImageDisplayer>
    with TickerProviderStateMixin {
  late TransformationController _transformationController;
  double get _scale => _transformationController.value.row0.x;
  late Offset _doubleTapLocalPosition;

  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  Offset? _dragOffset;
  Offset? _previousPosition;
  bool _enableDrag = true;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        _transformationController.value =
            _animation?.value ?? Matrix4.identity();
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _onDragStart(ScaleStartDetails scaleDetails) {
    _previousPosition = scaleDetails.focalPoint;
  }

  void _onDragUpdate(ScaleUpdateDetails scaleUpdateDetails) {
    final currentPosition = scaleUpdateDetails.focalPoint;
    final previousPosition = _previousPosition ?? currentPosition;

    final newY =
        (_dragOffset?.dy ?? 0.0) + (currentPosition.dy - previousPosition.dy);
    _previousPosition = currentPosition;
    if (_enableDrag) {
      setState(() {
        _dragOffset = Offset(0, newY);
      });
    }
  }

  void _onOverScrollDragEnd(ScaleEndDetails? scaleEndDetails) {
    if (_dragOffset == null) return;
    final dragOffset = _dragOffset!;

    final screenSize = MediaQuery.of(context).size;

    if (scaleEndDetails != null) {
      if (dragOffset.dy.abs() >= screenSize.height / 3) {
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
      final velocity = scaleEndDetails.velocity.pixelsPerSecond;
      final velocityY = velocity.dy;

      const thresholdOffsetYToEnablePop = 75.0;
      const thresholdVelocityYToEnablePop = 200.0;
      if (velocityY.abs() > thresholdOffsetYToEnablePop &&
          dragOffset.dy.abs() > thresholdVelocityYToEnablePop &&
          _enableDrag) {
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
    }
  }

  _onDoubleTap() {
    Matrix4 matrix = _transformationController.value.clone();

    final double currentScale = matrix.row0.x;
    double targetScale = widget.minScale;

    if (currentScale <= widget.minScale) {
      targetScale = widget.maxScale;
    }
    final double offSetX = targetScale == widget.minScale
        ? 0.0
        : -_doubleTapLocalPosition.dx * (targetScale - 1);
    final double offSetY = targetScale == widget.minScale
        ? 0.0
        : -_doubleTapLocalPosition.dy * (targetScale - 1);

    matrix = Matrix4.fromList([
      targetScale,
      matrix.row1.x,
      matrix.row2.x,
      matrix.row3.x,
      matrix.row0.y,
      targetScale,
      matrix.row2.y,
      matrix.row3.y,
      matrix.row0.z,
      matrix.row1.z,
      targetScale,
      matrix.row3.z,
      offSetX,
      offSetY,
      matrix.row2.w,
      matrix.row3.w
    ]);

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: matrix,
    ).animate(
      CurveTween(curve: Curves.easeOut).animate(_animationController),
    );
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (TapDownDetails details) {
        _doubleTapLocalPosition = details.localPosition;
      },
      onDoubleTap: _onDoubleTap,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: InteractiveViewer(
          transformationController: _transformationController,
          onInteractionUpdate: (details) {
            _onDragUpdate(details);
            if (_scale == 1.0) {
              // _enablePageView = true;
              _enableDrag = true;
            } else {
              // _enablePageView = false;
              _enableDrag = false;
            }
            setState(() {});
          },
          onInteractionEnd: (details) {
            if (_enableDrag) {
              _onOverScrollDragEnd(details);
            }
          },
          onInteractionStart: (details) {
            if (_enableDrag) {
              _onDragStart(details);
            }
          },
          child: SafeArea(
            child: Center(
              child: Hero(
                tag: widget.imagePath,
                child: widget.imageWidget,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
