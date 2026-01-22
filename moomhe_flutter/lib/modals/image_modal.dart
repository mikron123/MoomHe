import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../widgets/before_after_slider.dart';
import '../services/analytics_service.dart';
import '../l10n/localized_options.dart';

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
  final AnalyticsService _analytics = AnalyticsService();
  late bool _showComparison;
  bool _isDownloading = false;
  bool _isSharing = false;
  bool _showUI = true;
  bool _hasConfirmedResult = false; // User clicked "אהבתי! שמור"
  final TransformationController _transformationController = TransformationController();

  // Google Lens selection state
  bool _isGoogleLensMode = false;
  Rect? _lensSelection;
  bool _isSelectingLens = false;
  bool _isUploadingLensImage = false;
  Offset? _selectionStart;
  
  // Image rendering info for coordinate conversion
  final GlobalKey _imageContainerKey = GlobalKey();

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
    if (!_isGoogleLensMode) {
      setState(() => _showUI = !_showUI);
    }
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

      // Track image saved to gallery
      _analytics.logImageSavedToGallery();

      if (mounted) {
        _showToast(
          message: context.l10n.imageSavedToGallery,
          icon: LucideIcons.check,
          backgroundColor: Colors.green.shade600,
        );
      }
    } catch (e) {
      if (mounted) {
        _showToast(
          message: context.l10n.errorDownloadingImage,
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
        text: context.l10n.shareText,
      );
      
      // Track image shared
      _analytics.logImageShared();
    } catch (e) {
      if (mounted) {
        _showToast(
          message: context.l10n.errorSharing,
          icon: LucideIcons.alertCircle,
          backgroundColor: Colors.red.shade600,
        );
      }
    }
    if (mounted) {
      setState(() => _isSharing = false);
    }
  }

  // Google Lens Selection Handlers
  void _handleGoogleLensStart() {
    setState(() {
      _isGoogleLensMode = true;
      _lensSelection = null;
      _showUI = true;
    });
  }

  void _cancelGoogleLens() {
    setState(() {
      _isGoogleLensMode = false;
      _lensSelection = null;
      _isSelectingLens = false;
    });
  }

  void _handleLensPanStart(DragStartDetails details) {
    if (!_isGoogleLensMode) return;
    
    setState(() {
      _isSelectingLens = true;
      _selectionStart = details.localPosition;
      _lensSelection = Rect.fromPoints(details.localPosition, details.localPosition);
    });
  }

  void _handleLensPanUpdate(DragUpdateDetails details) {
    if (!_isSelectingLens || !_isGoogleLensMode || _selectionStart == null) return;
    
    setState(() {
      _lensSelection = Rect.fromPoints(_selectionStart!, details.localPosition);
    });
  }

  void _handleLensPanEnd(DragEndDetails details) async {
    if (!_isSelectingLens || _lensSelection == null) return;
    
    setState(() => _isSelectingLens = false);

    // Check if selection is valid (minimum size)
    final width = _lensSelection!.width.abs();
    final height = _lensSelection!.height.abs();
    
    if (width < 30 || height < 30) {
      setState(() => _lensSelection = null);
      return;
    }

    // Selection is valid, now crop and search
    await _cropAndSearchGoogleLens();
  }

  Future<void> _cropAndSearchGoogleLens() async {
    if (_lensSelection == null) return;

    final l10n = context.l10n;
    setState(() => _isUploadingLensImage = true);

    try {
      // Get the container's render box
      final containerBox = _imageContainerKey.currentContext?.findRenderObject() as RenderBox?;
      if (containerBox == null) {
        throw Exception('Container not found');
      }

      final containerSize = containerBox.size;

      // Load the image bytes
      Uint8List imageBytes;
      if (widget.imageUrl.startsWith('http')) {
        final response = await HttpClient().getUrl(Uri.parse(widget.imageUrl));
        final httpResponse = await response.close();
        imageBytes = Uint8List.fromList(await httpResponse.fold<List<int>>(
          <int>[],
          (previous, element) => previous..addAll(element),
        ));
      } else if (widget.imageUrl.startsWith('assets/')) {
        final byteData = await rootBundle.load(widget.imageUrl);
        imageBytes = byteData.buffer.asUint8List();
      } else {
        imageBytes = await File(widget.imageUrl).readAsBytes();
      }

      // Decode the image to get its natural dimensions
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final naturalWidth = image.width.toDouble();
      final naturalHeight = image.height.toDouble();

      // Calculate the displayed image size (object-fit: contain logic)
      final containerAspect = containerSize.width / containerSize.height;
      final imageAspect = naturalWidth / naturalHeight;

      double displayedWidth, displayedHeight;
      double offsetX, offsetY;

      if (imageAspect > containerAspect) {
        // Image is wider - fit to width
        displayedWidth = containerSize.width;
        displayedHeight = containerSize.width / imageAspect;
        offsetX = 0;
        offsetY = (containerSize.height - displayedHeight) / 2;
      } else {
        // Image is taller - fit to height
        displayedHeight = containerSize.height;
        displayedWidth = containerSize.height * imageAspect;
        offsetX = (containerSize.width - displayedWidth) / 2;
        offsetY = 0;
      }

      // Normalize selection rect (handle negative width/height from drag direction)
      final normalizedSelection = Rect.fromLTRB(
        _lensSelection!.left < _lensSelection!.right ? _lensSelection!.left : _lensSelection!.right,
        _lensSelection!.top < _lensSelection!.bottom ? _lensSelection!.top : _lensSelection!.bottom,
        _lensSelection!.left > _lensSelection!.right ? _lensSelection!.left : _lensSelection!.right,
        _lensSelection!.top > _lensSelection!.bottom ? _lensSelection!.top : _lensSelection!.bottom,
      );

      // Convert selection from container coordinates to image coordinates
      final scaleX = naturalWidth / displayedWidth;
      final scaleY = naturalHeight / displayedHeight;

      final imgRelativeX = normalizedSelection.left - offsetX;
      final imgRelativeY = normalizedSelection.top - offsetY;

      // Calculate crop bounds in natural image pixels
      int cropX = (imgRelativeX * scaleX).round().clamp(0, naturalWidth.round() - 1);
      int cropY = (imgRelativeY * scaleY).round().clamp(0, naturalHeight.round() - 1);
      int cropWidth = (normalizedSelection.width * scaleX).round().clamp(1, naturalWidth.round() - cropX);
      int cropHeight = (normalizedSelection.height * scaleY).round().clamp(1, naturalHeight.round() - cropY);

      // Ensure we have valid crop dimensions
      if (cropWidth <= 0 || cropHeight <= 0) {
        if (mounted) {
          _showToast(
            message: l10n.selectAreaWithinImage,
            icon: LucideIcons.alertCircle,
            backgroundColor: Colors.orange.shade600,
          );
        }
        setState(() => _isUploadingLensImage = false);
        return;
      }

      // Create a picture recorder to crop the image
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Draw cropped region
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(cropX.toDouble(), cropY.toDouble(), cropWidth.toDouble(), cropHeight.toDouble()),
        Rect.fromLTWH(0, 0, cropWidth.toDouble(), cropHeight.toDouble()),
        Paint(),
      );

      final croppedPicture = recorder.endRecording();
      final croppedImage = await croppedPicture.toImage(cropWidth, cropHeight);
      
      // Convert to bytes
      final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to convert image to bytes');
      
      final croppedBytes = byteData.buffer.asUint8List();

      // Upload to Firebase Storage (use temp/ path which is allowed by storage rules)
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'temp/$userId/lens_$timestamp.png';
      
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      await ref.putData(croppedBytes, SettableMetadata(contentType: 'image/png'));
      final downloadURL = await ref.getDownloadURL();

      // Open Google Lens in in-app browser
      final lensUrl = Uri.parse('https://lens.google.com/uploadbyurl?url=${Uri.encodeComponent(downloadURL)}');
      
      // Use inAppBrowserView for a full browser experience within the app
      await launchUrl(
        lensUrl, 
        mode: LaunchMode.inAppBrowserView,
        browserConfiguration: const BrowserConfiguration(showTitle: true),
      );

      // Reset selection state
      setState(() {
        _isGoogleLensMode = false;
        _lensSelection = null;
      });

    } catch (error) {
      debugPrint('Google Lens search failed: $error');
      if (mounted) {
        _showToast(
          message: l10n.googleLensSearchFailed,
          icon: LucideIcons.alertCircle,
          backgroundColor: Colors.red.shade600,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingLensImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image layer - fullscreen with zoom (or selection mode)
          GestureDetector(
            onTap: _toggleUI,
            onPanStart: _isGoogleLensMode ? _handleLensPanStart : null,
            onPanUpdate: _isGoogleLensMode ? _handleLensPanUpdate : null,
            onPanEnd: _isGoogleLensMode ? _handleLensPanEnd : null,
            child: Container(
              key: _imageContainerKey,
              child: _showComparison && widget.hasAIComparison && !_isGoogleLensMode
                  ? SafeArea(
                      child: BeforeAfterSlider(
                        beforeImagePath: widget.originalImageUrl!,
                        afterImagePath: widget.imageUrl,
                      ),
                    )
                  : _isGoogleLensMode
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image (no zoom in lens mode)
                            Center(
                              child: _buildImage(widget.imageUrl),
                            ),
                            // Selection overlay
                            if (_lensSelection != null)
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _SelectionOverlayPainter(
                                    selection: _lensSelection!,
                                  ),
                                ),
                              ),
                          ],
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
          ),

          // Google Lens Mode Instructions overlay
          if (_isGoogleLensMode && _lensSelection == null && !_isUploadingLensImage)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.search, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.selectAreaToSearch,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Uploading overlay
          if (_isUploadingLensImage)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.blue),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.searchingWithGoogleLens,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
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
                            onPressed: _isGoogleLensMode ? _cancelGoogleLens : () {
                              Navigator.pop(context);
                              widget.onClose?.call();
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withValues(alpha: 0.5),
                            ),
                            icon: Icon(
                              _isGoogleLensMode ? LucideIcons.x : Icons.close,
                              color: Colors.white,
                            ),
                          ),
                          // Comparison checkbox - only show for AI-processed images after confirming result
                          if (widget.hasAIComparison && !_showNewResultButtons && !_isGoogleLensMode)
                            GestureDetector(
                              onTap: () {
                                final newValue = !_showComparison;
                                _analytics.logComparisonToggled(enabled: newValue);
                                setState(() => _showComparison = newValue);
                              },
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
                                    Text(
                                      context.l10n.comparison,
                                      style: const TextStyle(
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
                    if (widget.prompt != null && widget.prompt!.isNotEmpty && widget.hasAIComparison && !_isGoogleLensMode)
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
                    if (!_isGoogleLensMode)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: _showNewResultButtons
                            ? _buildNewResultButtons()
                            : widget.hasAIComparison
                                ? _buildRegularAIButtons()
                                : _buildDownloadOnlyButton(),
                      ),
                    
                    // Cancel button in Google Lens mode
                    if (_isGoogleLensMode)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _cancelGoogleLens,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LucideIcons.x, size: 20, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  context.l10n.cancelSearch,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.rotateCcw, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  context.l10n.revertToOriginal,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Love it! Save button - Teal/Green
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.checkCircle, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  context.l10n.loveItSave,
                  style: const TextStyle(
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
    return Column(
      children: [
        // Main row: Download, Share, Search
        Row(
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.download, size: 20, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.download,
                            style: const TextStyle(
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.share2, size: 20, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.share,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Google Lens Search button - Blue
            Expanded(
              child: ElevatedButton(
                onPressed: _handleGoogleLensStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.search, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        context.l10n.searchWithLens,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDownloadOnlyButton() {
    return Column(
      children: [
        Row(
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.download, size: 20, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.download,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Google Lens Search button - Blue
            Expanded(
              child: ElevatedButton(
                onPressed: _handleGoogleLensStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.search, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.searchWithLens,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
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

/// Custom painter for the selection overlay with semi-transparent background
class _SelectionOverlayPainter extends CustomPainter {
  final Rect selection;

  _SelectionOverlayPainter({required this.selection});

  @override
  void paint(Canvas canvas, Size size) {
    // Normalize selection rect
    final normalizedSelection = Rect.fromLTRB(
      selection.left < selection.right ? selection.left : selection.right,
      selection.top < selection.bottom ? selection.top : selection.bottom,
      selection.left > selection.right ? selection.left : selection.right,
      selection.top > selection.bottom ? selection.top : selection.bottom,
    );

    // Draw semi-transparent overlay over the entire canvas
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Create a path that covers everything except the selection
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(normalizedSelection)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, overlayPaint);

    // Draw selection border
    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRect(normalizedSelection, borderPaint);

    // Draw corner handles
    final handlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    const handleSize = 12.0;
    final corners = [
      normalizedSelection.topLeft,
      normalizedSelection.topRight,
      normalizedSelection.bottomLeft,
      normalizedSelection.bottomRight,
    ];

    for (final corner in corners) {
      canvas.drawCircle(corner, handleSize / 2, handlePaint);
    }

    // Draw white outline for handles
    final handleOutlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final corner in corners) {
      canvas.drawCircle(corner, handleSize / 2, handleOutlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SelectionOverlayPainter oldDelegate) {
    return oldDelegate.selection != selection;
  }
}
