import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../widgets/before_after_slider.dart';

class ImageModal extends StatefulWidget {
  final String imageUrl;
  final String? originalImageUrl;
  final String? prompt;
  final Function()? onClose;
  final bool initialShowComparison;
  final bool isNewResult; // When true, shows "אהבתי! שמור" / "חזור למקור" buttons
  final Function()? onKeepResult; // Called when user chooses to keep the result
  final Function()? onRevertToOriginal; // Called when user chooses to revert

  const ImageModal({
    super.key,
    required this.imageUrl,
    this.originalImageUrl,
    this.prompt,
    this.onClose,
    this.initialShowComparison = false,
    this.isNewResult = false,
    this.onKeepResult,
    this.onRevertToOriginal,
  });

  /// Check if this is an AI-processed image (has different original)
  bool get hasAIComparison =>
      originalImageUrl != null && originalImageUrl != imageUrl;

  @override
  State<ImageModal> createState() => _ImageModalState();
}

class _ImageModalState extends State<ImageModal> {
  late bool _showComparison;
  bool _isDownloading = false;
  bool _isSharing = false;
  bool _showUI = true;
  bool _hasConfirmedResult = false; // User clicked "אהבתי! שמור"
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    // Auto-enable comparison mode if requested and available
    _showComparison = widget.initialShowComparison && widget.hasAIComparison;
  }
  
  /// Whether to show the initial decision buttons (אהבתי/חזור למקור)
  bool get _showNewResultButtons => widget.isNewResult && !_hasConfirmedResult;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _toggleUI() {
    setState(() => _showUI = !_showUI);
  }

  /// Show a nicely designed toast message
  void _showToast({
    required String message,
    IconData? icon,
    Color? backgroundColor,
  }) {
    final bgColor = backgroundColor ?? Colors.green.shade600;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);
    try {
      String filePath;
      
      if (widget.imageUrl.startsWith('http')) {
        final response = await HttpClient().getUrl(Uri.parse(widget.imageUrl));
        final httpResponse = await response.close();
        final bytes = await httpResponse.fold<List<int>>(
          <int>[],
          (previous, element) => previous..addAll(element),
        );
        
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/moomhe_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(bytes);
        filePath = file.path;
      } else if (widget.imageUrl.startsWith('assets/')) {
        final byteData = await rootBundle.load(widget.imageUrl);
        final bytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/moomhe_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(bytes);
        filePath = file.path;
      } else {
        filePath = widget.imageUrl;
      }

      await Gal.putImage(filePath);

      if (mounted) {
        _showToast(
          message: 'התמונה נשמרה בגלריה!',
          icon: LucideIcons.check,
          backgroundColor: Colors.green.shade600,
        );
      }
    } catch (e) {
      if (mounted) {
        _showToast(
          message: 'שגיאה בהורדת התמונה',
          icon: LucideIcons.alertCircle,
          backgroundColor: Colors.red.shade600,
        );
      }
    }
    if (mounted) {
      setState(() => _isDownloading = false);
    }
  }

  Future<void> _handleShare() async {
    setState(() => _isSharing = true);
    try {
      String filePath;
      
      if (widget.imageUrl.startsWith('http')) {
        final response = await HttpClient().getUrl(Uri.parse(widget.imageUrl));
        final httpResponse = await response.close();
        final bytes = await httpResponse.fold<List<int>>(
          <int>[],
          (previous, element) => previous..addAll(element),
        );

        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/moomhe_share_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(bytes);
        filePath = file.path;
      } else if (widget.imageUrl.startsWith('assets/')) {
        final byteData = await rootBundle.load(widget.imageUrl);
        final bytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/moomhe_share_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(bytes);
        filePath = file.path;
      } else {
        filePath = widget.imageUrl;
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        text: '🏠 עיצבתי את זה עם מומחה AI!\n📸 רוצים לנסות גם? https://moomhe.com',
      );
    } catch (e) {
      if (mounted) {
        _showToast(
          message: 'שגיאה בשיתוף',
          icon: LucideIcons.alertCircle,
          backgroundColor: Colors.red.shade600,
        );
      }
    }
    if (mounted) {
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image layer - fullscreen with zoom
          GestureDetector(
            onTap: _toggleUI,
            child: _showComparison && widget.hasAIComparison
                ? SafeArea(
                    child: BeforeAfterSlider(
                      beforeImagePath: widget.originalImageUrl!,
                      afterImagePath: widget.imageUrl,
                    ),
                  )
                : InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.5,
                    maxScale: 5.0,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    child: Center(
                      child: _buildImage(widget.imageUrl),
                    ),
                  ),
          ),

          // UI overlay - animated visibility
          AnimatedOpacity(
            opacity: _showUI ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_showUI,
              child: SafeArea(
                child: Column(
                  children: [
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onClose?.call();
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withValues(alpha: 0.5),
                            ),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                          // Comparison checkbox - only show for AI-processed images after confirming result
                          if (widget.hasAIComparison && !_showNewResultButtons)
                            GestureDetector(
                              onTap: () => setState(() => _showComparison = !_showComparison),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: _showComparison 
                                      ? Border.all(color: AppColors.primary400, width: 2)
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: _showComparison 
                                            ? AppColors.primary500 
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: _showComparison 
                                              ? AppColors.primary400 
                                              : Colors.white.withValues(alpha: 0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: _showComparison
                                          ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'השוואה',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Prompt (if available and AI-processed)
                    if (widget.prompt != null && widget.prompt!.isNotEmpty && widget.hasAIComparison)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.sparkles,
                                size: 16,
                                color: AppColors.primary400,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.prompt!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: _showNewResultButtons
                          ? _buildNewResultButtons()
                          : widget.hasAIComparison
                              ? _buildRegularAIButtons()
                              : _buildDownloadOnlyButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewResultButtons() {
    return Row(
      children: [
        // חזור למקור (Revert to original) button - Dark/Grey
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onRevertToOriginal?.call();
              Navigator.pop(context, 'revert');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.rotateCcw, size: 20, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'חזור למקור',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // אהבתי! שמור (Love it! Save) button - Teal/Green
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Stay on screen and show regular buttons with comparison checkbox
              // Turn off comparison mode to show the final result
              setState(() {
                _hasConfirmedResult = true;
                _showComparison = false;
              });
              // Notify parent that user kept the result
              widget.onKeepResult?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF26A69A), // Teal color
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.checkCircle, size: 20, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'אהבתי! שמור',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegularAIButtons() {
    return Row(
      children: [
        // Download button
        Expanded(
          child: ElevatedButton(
            onPressed: _isDownloading ? null : _handleDownload,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
            ),
            child: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.download, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'הורד',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(width: 12),

        // Share button
        Expanded(
          child: ElevatedButton(
            onPressed: _isSharing ? null : _handleShare,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.share2, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'שתפו',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadOnlyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isDownloading ? null : _handleDownload,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
        ),
        child: _isDownloading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.download, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'הורד',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary400),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(LucideIcons.imageOff, color: AppColors.textMuted, size: 48),
        ),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.contain,
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.contain,
      );
    }
  }
}
