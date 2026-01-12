import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

class BeforeAfterSlider extends StatefulWidget {
  final String? beforeImagePath;
  final String? afterImagePath;
  final File? beforeImageFile;
  final File? afterImageFile;

  const BeforeAfterSlider({
    super.key,
    this.beforeImagePath,
    this.afterImagePath,
    this.beforeImageFile,
    this.afterImageFile,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _sliderPosition = 0.5;

  Widget _buildImage(String? path, File? file, BoxFit fit) {
    if (file != null) {
      return Image.file(
        file,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (path != null) {
      if (path.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: path,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: AppColors.primary400),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Icon(LucideIcons.imageOff, color: AppColors.textMuted),
          ),
        );
      } else if (path.startsWith('assets/')) {
        return Image.asset(
          path,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
        );
      } else {
        return Image.file(
          File(path),
          fit: fit,
          width: double.infinity,
          height: double.infinity,
        );
      }
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (details) {
            _updateSliderPosition(details.localPosition.dx, constraints.maxWidth);
          },
          onPanUpdate: (details) {
            _updateSliderPosition(details.localPosition.dx, constraints.maxWidth);
          },
          child: Container(
            color: Colors.black, // Black background to hide any gaps
            child: Stack(
              children: [
                // After Image (right side - clipped from slider position to end)
                Positioned.fill(
                  child: ClipRect(
                    clipper: _RightClipper(_sliderPosition),
                    child: _buildImage(widget.afterImagePath, widget.afterImageFile, BoxFit.contain),
                  ),
                ),

                // Before Image (left side - clipped from start to slider position)
                Positioned.fill(
                  child: ClipRect(
                    clipper: _LeftClipper(_sliderPosition),
                    child: _buildImage(widget.beforeImagePath, widget.beforeImageFile, BoxFit.contain),
                  ),
                ),

                // Slider line
                Positioned(
                  left: constraints.maxWidth * _sliderPosition - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Colors.white,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Handle
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            LucideIcons.arrowLeftRight,
                            size: 20,
                            color: AppColors.primary600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  void _updateSliderPosition(double x, double maxWidth) {
    setState(() {
      _sliderPosition = (x / maxWidth).clamp(0.0, 1.0);
    });
  }
}

/// Clips the left portion (from 0 to position)
class _LeftClipper extends CustomClipper<Rect> {
  final double position;

  _LeftClipper(this.position);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * position, size.height);
  }

  @override
  bool shouldReclip(_LeftClipper oldClipper) {
    return position != oldClipper.position;
  }
}

/// Clips the right portion (from position to end)
class _RightClipper extends CustomClipper<Rect> {
  final double position;

  _RightClipper(this.position);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(size.width * position, 0, size.width, size.height);
  }

  @override
  bool shouldReclip(_RightClipper oldClipper) {
    return position != oldClipper.position;
  }
}
