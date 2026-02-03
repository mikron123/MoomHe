import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

/// Model for a design category from Firestore
class DesignCategory {
  final String id;
  final String label;
  final DateTime createdAt;

  DesignCategory({
    required this.id,
    required this.label,
    required this.createdAt,
  });

  factory DesignCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DesignCategory(
      id: doc.id,
      label: data['label'] ?? doc.id,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Get localized label for the category
  String getLocalizedLabel(AppLocalizations l10n) {
    final idLower = id.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    switch (idLower) {
      case 'kitchen':
      case 'kitchens':
        return l10n.categoryKitchen;
      case 'kids_bedroom':
      case 'kids_bedrooms':
      case 'kidsbedroom':
        return l10n.categoryKidsBedroom;
      case 'bathroom':
      case 'bathrooms':
        return l10n.categoryBathroom;
      case 'living_room':
      case 'living_rooms':
      case 'livingroom':
        return l10n.categoryLivingRoom;
      case 'master_bedroom':
      case 'master_bedrooms':
      case 'masterbedroom':
        return l10n.categoryMasterBedroom;
      default:
        return label; // Fallback to Firestore label
    }
  }
}

/// Model for a design item from Firestore
class DesignItem {
  final String id;
  final String url;
  final String? urlThumb;
  final String title;
  final DateTime createdAt;

  DesignItem({
    required this.id,
    required this.url,
    this.urlThumb,
    required this.title,
    required this.createdAt,
  });

  factory DesignItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DesignItem(
      id: doc.id,
      url: data['url'] ?? '',
      urlThumb: data['urlThumb'],
      title: data['title'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String get thumbnailUrl => urlThumb ?? url;
}

/// Result when user selects a design
class SelectedDesign {
  final String url;
  final String? thumbnail;
  final String title;
  final String id;
  final String categoryId;
  final String categoryLabel;
  final String localPath; // Downloaded file path

  SelectedDesign({
    required this.url,
    this.thumbnail,
    required this.title,
    required this.id,
    required this.categoryId,
    required this.categoryLabel,
    required this.localPath,
  });
}

class ReadyDesignsModal extends StatefulWidget {
  final Function(SelectedDesign)? onSelectDesign;
  final VoidCallback? onClose;

  const ReadyDesignsModal({
    super.key,
    this.onSelectDesign,
    this.onClose,
  });

  @override
  State<ReadyDesignsModal> createState() => _ReadyDesignsModalState();
}

class _ReadyDesignsModalState extends State<ReadyDesignsModal>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<DesignCategory> _categories = [];
  String? _activeCategory;
  List<DesignItem> _currentDesigns = [];
  bool _loadingCategories = true;
  bool _loadingDesigns = false;
  bool _downloadingDesign = false;

  // Scroll controllers - state persists because widget stays in tree
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _gridScrollController = ScrollController();

  // Cache designs per category so we don't refetch
  final Map<String, List<DesignItem>> _designsCache = {};

  // Animation controller for shimmer effect
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _loadCategories();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _categoryScrollController.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    if (_categories.isNotEmpty) return; // Already loaded

    setState(() => _loadingCategories = true);

    try {
      final snapshot = await _firestore
          .collection('preDesigns')
          .orderBy('createdAt', descending: false)
          .get();

      final cats = snapshot.docs
          .map((doc) => DesignCategory.fromFirestore(doc))
          .toList();

      if (mounted) {
        setState(() {
          _categories = cats;
          _loadingCategories = false;

          if (cats.isNotEmpty && _activeCategory == null) {
            _activeCategory = cats.first.id;
            _loadDesigns(_activeCategory!);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      if (mounted) {
        setState(() => _loadingCategories = false);
      }
    }
  }

  Future<void> _loadDesigns(String categoryId) async {
    // Check cache first
    if (_designsCache.containsKey(categoryId)) {
      setState(() {
        _currentDesigns = _designsCache[categoryId]!;
        _loadingDesigns = false;
      });
      return;
    }

    setState(() => _loadingDesigns = true);

    try {
      final snapshot = await _firestore
          .collection('preDesigns')
          .doc(categoryId)
          .collection('items')
          .orderBy('createdAt', descending: true)
          .get();

      final designs =
          snapshot.docs.map((doc) => DesignItem.fromFirestore(doc)).toList();

      if (mounted) {
        // Cache the designs
        _designsCache[categoryId] = designs;

        setState(() {
          _currentDesigns = designs;
          _loadingDesigns = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading designs: $e');
      if (mounted) {
        setState(() {
          _currentDesigns = [];
          _loadingDesigns = false;
        });
      }
    }
  }

  void _onCategoryTap(DesignCategory category) {
    if (category.id == _activeCategory) return;

    setState(() {
      _activeCategory = category.id;
    });

    // Reset grid scroll to top when switching categories
    if (_gridScrollController.hasClients) {
      _gridScrollController.jumpTo(0);
    }

    _loadDesigns(category.id);
  }

  Future<void> _handleDesignSelect(DesignItem design) async {
    if (widget.onSelectDesign == null) return;

    setState(() => _downloadingDesign = true);

    try {
      // Download the image to a temporary file
      final response = await http.get(Uri.parse(design.url));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }

      // Save to temp directory
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'preset_${design.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      // Get category info
      final category = _categories.firstWhere(
        (c) => c.id == _activeCategory,
        orElse: () => DesignCategory(
          id: _activeCategory!,
          label: _activeCategory!,
          createdAt: DateTime.now(),
        ),
      );

      // Get localized label for the prompt
      final l10n = AppLocalizations.of(context)!;
      final localizedLabel = category.getLocalizedLabel(l10n);

      final selectedDesign = SelectedDesign(
        url: design.url,
        thumbnail: design.urlThumb,
        title: design.title,
        id: design.id,
        categoryId: _activeCategory!,
        categoryLabel: localizedLabel,
        localPath: file.path,
      );

      if (mounted) {
        setState(() => _downloadingDesign = false);
        widget.onSelectDesign!(selectedDesign);
        // Note: onSelectDesign callback will handle closing the modal
      }
    } catch (e) {
      debugPrint('Error downloading design: $e');
      if (mounted) {
        setState(() => _downloadingDesign = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading design'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A2744),
            AppColors.background,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Stack(
          children: [
            // Decorative background elements
            _buildBackgroundDecoration(),

            // Main content
            Column(
              children: [
                // Premium header
                _buildHeader(l10n),

                // Category tabs
                _buildCategoryTabs(l10n),

                // Designs grid
                Expanded(
                  child: _buildDesignsGrid(l10n),
                ),
              ],
            ),

            // Loading overlay when downloading
            if (_downloadingDesign) _buildLoadingOverlay(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Top gradient orb
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary400.withValues(alpha: 0.15),
                    AppColors.secondary400.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Left gradient orb
          Positioned(
            top: 200,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary500.withValues(alpha: 0.1),
                    AppColors.primary500.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          // Drag handle indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    // Icon with gradient background
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.secondary400.withValues(alpha: 0.2),
                            AppColors.secondary600.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondary400.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        LucideIcons.layoutGrid,
                        color: AppColors.secondary300,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.white,
                          AppColors.secondary200,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        l10n.readyDesigns,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Close button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: IconButton(
              onPressed: () {
                if (widget.onClose != null) {
                  widget.onClose!();
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(
                LucideIcons.x,
                color: AppColors.textMuted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(AppLocalizations l10n) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: _loadingCategories
          ? _buildCategoryLoading(l10n)
          : _categories.isEmpty
              ? _buildNoCategoriesMessage(l10n)
              : _buildCategoryList(l10n),
    );
  }

  Widget _buildCategoryLoading(AppLocalizations l10n) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.secondary400,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.loading,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCategoriesMessage(AppLocalizations l10n) {
    return Center(
      child: Text(
        l10n.noCategories,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCategoryList(AppLocalizations l10n) {
    return ListView.builder(
      controller: _categoryScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isActive = category.id == _activeCategory;

        return Padding(
          padding: EdgeInsets.only(
            right: index < _categories.length - 1 ? 10 : 0,
          ),
          child: _buildCategoryChip(category, isActive, l10n),
        );
      },
    );
  }

  Widget _buildCategoryChip(
      DesignCategory category, bool isActive, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _onCategoryTap(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondary500,
                    AppColors.secondary600,
                  ],
                )
              : null,
          color: isActive ? null : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isActive
                ? AppColors.secondary400.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.secondary500.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          category.getLocalizedLabel(l10n),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.textMuted,
            letterSpacing: isActive ? 0.3 : 0,
          ),
        ),
      ),
    );
  }

  Widget _buildDesignsGrid(AppLocalizations l10n) {
    if (_loadingDesigns) {
      return _buildDesignsLoading(l10n);
    }

    if (_currentDesigns.isEmpty) {
      return _buildNoDesignsMessage(l10n);
    }

    return GridView.builder(
      controller: _gridScrollController,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: _currentDesigns.length,
      itemBuilder: (context, index) {
        final design = _currentDesigns[index];
        return _DesignCard(
          design: design,
          onTap: () => _handleDesignSelect(design),
          index: index,
        );
      },
    );
  }

  Widget _buildDesignsLoading(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom loading animation
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.secondary400.withValues(alpha: 0.15),
                  AppColors.secondary600.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.secondary400.withValues(alpha: 0.2),
              ),
            ),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.secondary400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.loadingDesigns,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDesignsMessage(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.06),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(
              LucideIcons.image,
              size: 36,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.noDesigns,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.noDesignsInCategory,
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(AppLocalizations l10n) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withValues(alpha: 0.6),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface.withValues(alpha: 0.95),
                    AppColors.background.withValues(alpha: 0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.secondary400.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary500.withValues(alpha: 0.2),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.secondary400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.loading,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium design card with animations
class _DesignCard extends StatefulWidget {
  final DesignItem design;
  final VoidCallback onTap;
  final int index;

  const _DesignCard({
    required this.design,
    required this.onTap,
    required this.index,
  });

  @override
  State<_DesignCard> createState() => _DesignCardState();
}

class _DesignCardState extends State<_DesignCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            border: Border.all(
              color: _isPressed
                  ? AppColors.secondary400.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
              width: _isPressed ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              if (_isPressed)
                BoxShadow(
                  color: AppColors.secondary400.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image section
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Main image
                      CachedNetworkImage(
                        imageUrl: widget.design.thumbnailUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildPlaceholder(),
                        errorWidget: (context, url, error) =>
                            _buildErrorWidget(),
                      ),
                      // Gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Top shine effect
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Press indicator
                      if (_isPressed)
                        Positioned.fill(
                          child: Container(
                            color: AppColors.secondary400.withValues(alpha: 0.1),
                          ),
                        ),
                    ],
                  ),
                ),
                // Title section with glass effect
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.design.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.secondary400.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              LucideIcons.arrowRight,
                              size: 14,
                              color: AppColors.secondary300,
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
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceHighlight,
            AppColors.surface,
          ],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.secondary400.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: AppColors.surfaceHighlight,
      child: Icon(
        LucideIcons.imageOff,
        color: AppColors.textMuted.withValues(alpha: 0.5),
        size: 32,
      ),
    );
  }
}
