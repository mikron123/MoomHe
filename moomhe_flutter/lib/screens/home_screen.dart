import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/onboarding_overlay.dart';
import '../modals/mobile_menu_modal.dart';
import '../modals/style_selector_modal.dart';
import '../modals/color_palette_modal.dart';
import '../modals/options_modal.dart';
import '../modals/image_modal.dart';
import '../modals/auth_modal.dart';
import '../modals/limit_reached_modal.dart';
import '../modals/subscription_modal.dart';
import '../modals/coupon_modal.dart';
import '../modals/contact_modal.dart';
import '../modals/ai_error_modal.dart';
import '../models/history_entry.dart';
import '../models/prompt_option.dart';
import '../services/ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // AI Service
  final AIService _aiService = AIService();
  
  // Image state
  String? _mainImage;
  String? _originalImage;
  String? _objectImage; // Object/item image to add to main image
  bool _isProcessing = false;
  String? _lastPrompt;
  String _processingStatus = '';
  
  // Keyboard visibility tracking
  double _previousBottomInset = 0;

  // History
  final List<HistoryEntry> _imageHistory = [];
  bool _historyLoading = false;
  
  // User state
  String? _userEmail;
  int _userCredits = 0;
  int _userSubscription = 0;
  bool _isLoggedIn = false;

  // UI state
  bool _showOnboarding = false;
  late AnimationController _processingController;
  
  // Prompt input
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _promptFocusNode = FocusNode();
  bool _isPromptFocused = false;

  // Keys for onboarding
  final GlobalKey _uploadKey = GlobalKey();
  final GlobalKey _toolsKey = GlobalKey();
  final GlobalKey _historyKey = GlobalKey();

  final ImagePicker _picker = ImagePicker();

  // Design actions (interior design mode only)
  final List<Map<String, dynamic>> _designActions = [
    {'label': 'סגנון עיצוב', 'icon': LucideIcons.palette, 'action': 'style'},
    {'label': 'צבע קירות', 'icon': LucideIcons.paintbrush, 'action': 'color'},
    {'label': 'תאורה', 'icon': LucideIcons.lamp, 'action': 'lighting'},
    {'label': 'ריהוט', 'icon': LucideIcons.sofa, 'action': 'furniture'},
    {'label': 'חלונות ודלתות', 'icon': LucideIcons.home, 'action': 'doors_windows'},
    {'label': 'רחצה', 'icon': LucideIcons.droplets, 'action': 'bathroom'},
    {'label': 'תיקונים', 'icon': LucideIcons.hammer, 'action': 'repairs'},
    {'label': 'כללי', 'icon': LucideIcons.wand2, 'action': 'custom'},
  ];

  // Default image constant
  static const String _defaultAssetImage = 'assets/images/design_img.jpg';

  @override
  void initState() {
    super.initState();
    _processingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    // Set default image on startup
    _mainImage = _defaultAssetImage;
    _originalImage = _defaultAssetImage;
    
    // Listen to prompt focus changes
    _promptFocusNode.addListener(_onPromptFocusChange);
    
    // Register keyboard visibility observer
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize Firebase and load user data
    _initializeApp();
  }

  void _onPromptFocusChange() {
    setState(() {
      _isPromptFocused = _promptFocusNode.hasFocus;
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Detect keyboard visibility changes
    final bottomInset = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
    
    // If keyboard was visible and now hidden, unfocus the prompt
    if (_previousBottomInset > 0 && bottomInset == 0 && _promptFocusNode.hasFocus) {
      _promptFocusNode.unfocus();
    }
    
    _previousBottomInset = bottomInset;
  }

  Future<void> _initializeApp() async {
    try {
      // Sign in anonymously
      await _aiService.ensureSignedIn();
      
      // Load user credits
      await _loadUserCredits();
      
      // Load history
      await _loadHistory();
      
      if (mounted) {
        setState(() => _isLoggedIn = true);
      }
    } catch (e) {
      print('Error initializing app: $e');
    }
  }

  Future<void> _loadHistory() async {
    if (_historyLoading) return;
    
    setState(() => _historyLoading = true);
    
    try {
      final historyData = await _aiService.loadUserHistory();
      if (mounted) {
        setState(() {
          _imageHistory.clear();
          _imageHistory.addAll(historyData.map((data) => HistoryEntry(
            id: data['id'] ?? '',
            imageUrl: data['storageUrl'] ?? data['imageUrl'] ?? '',
            thumbnailUrl: data['thumbnailUrl'],
            originalImageUrl: data['originalImageUrl'],
            prompt: data['prompt'],
            createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
          )));
        });
      }
    } catch (e) {
      print('Error loading history: $e');
    }
    
    if (mounted) {
      setState(() => _historyLoading = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _processingController.dispose();
    _promptController.dispose();
    _promptFocusNode.removeListener(_onPromptFocusChange);
    _promptFocusNode.dispose();
    super.dispose();
  }

  /// Show a nicely designed toast message
  void _showToast({
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? iconColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final bgColor = backgroundColor ?? Colors.green.shade600;
    final icColor = iconColor ?? Colors.white;
    
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
                  child: Icon(icon, color: icColor, size: 18),
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
        duration: duration,
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );

    if (image != null && mounted) {
      // Upload to history with type: 'uploaded'
      _uploadImageToHistory(image.path);
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );

    if (image != null && mounted) {
      // Upload to history with type: 'uploaded'
      _uploadImageToHistory(image.path);
    }
  }

  Future<void> _pickObjectImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      setState(() {
        _objectImage = image.path;
      });

      // Add default prompt if prompt is empty, or append it
      const defaultPrompt = 'הוסף את הפריט המצורף לתמונה';
      final currentPrompt = _promptController.text.trim();
      
      if (currentPrompt.isEmpty) {
        _promptController.text = defaultPrompt;
      } else if (!currentPrompt.contains(defaultPrompt)) {
        _promptController.text = '$currentPrompt $defaultPrompt';
      }

      // Show toast/snackbar
      if (mounted) {
        _showToast(
          message: 'תמונת פריט נטענה! תאר בשורת הפרומפט איפה להוסיף אותו.',
          icon: LucideIcons.check,
          backgroundColor: Colors.green.shade600,
        );
      }
    }
  }

  Future<void> _uploadImageToHistory(String imagePath) async {
    setState(() {
      _mainImage = imagePath;
      _originalImage = imagePath;
      _isProcessing = true;
      _processingStatus = 'מעלה תמונה...';
    });

    try {
      final entry = await _aiService.uploadImageToHistory(imagePath);
      
      if (mounted) {
        final storageUrl = entry['storageUrl'] as String;
        setState(() {
          _mainImage = storageUrl;
          _originalImage = storageUrl;
          _isProcessing = false;
          
          // Add to local history
          _imageHistory.insert(0, HistoryEntry(
            id: entry['id'] as String,
            imageUrl: storageUrl,
            thumbnailUrl: entry['thumbnailUrl'] as String?,
            originalImageUrl: null,
            prompt: 'Uploaded image',
            createdAt: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _showToast(
          message: 'שגיאה בהעלאת התמונה',
          icon: LucideIcons.alertCircle,
          backgroundColor: Colors.red.shade600,
        );
      }
    }
  }

  void _handleActionTap(String action) {
    if (_mainImage == null) {
      _showUploadPrompt();
      return;
    }

    switch (action) {
      case 'style':
        _showStyleSelector();
        break;
      case 'color':
        _showColorPalette();
        break;
      case 'lighting':
        _showLightingOptions();
        break;
      case 'furniture':
        _showFurnitureOptions();
        break;
      case 'doors_windows':
        _showDoorsWindowsOptions();
        break;
      case 'bathroom':
        _showBathroomOptions();
        break;
      case 'repairs':
        _showRepairsOptions();
        break;
      case 'custom':
        _showCustomPromptDialog();
        break;
      default:
        _showComingSoon(action);
    }
  }

  void _showUploadPrompt() {
    _showToast(
      message: 'יש להעלות תמונה קודם',
      icon: LucideIcons.upload,
      backgroundColor: AppColors.primary600,
    );
  }

  void _showStyleSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StyleSelectorModal(
        onStyleSelect: (style) {
          Navigator.pop(modalContext);
          // Use Future.delayed to ensure modal is closed before processing
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _processWithPrompt('שנה את הסגנון ל${style.name}');
            }
          });
        },
      ),
    );
  }

  void _showColorPalette() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => ColorPaletteModal(
        onColorSelect: (color, prompt) {
          debugPrint('🎨 Color selected: ${color.name}, prompt: $prompt');
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _processWithPrompt(prompt);
            }
          });
        },
      ),
    );
  }

  void _showLightingOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => OptionsModal(
        title: 'בחר סוג תאורה',
        options: LightingOptions.options,
        onSelect: (option) {
          debugPrint('💡 Lighting selected: ${option.name}, prompt: ${option.prompt}');
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _processWithPrompt(option.prompt);
            }
          });
        },
      ),
    );
  }

  void _showFurnitureOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => OptionsModal(
        title: 'בחר סוג ריהוט',
        options: FurnitureOptions.options,
        onSelect: (option) {
          debugPrint('🪑 Furniture selected: ${option.name}, prompt: ${option.prompt}');
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _processWithPrompt(option.prompt);
            }
          });
        },
      ),
    );
  }

  void _showDoorsWindowsOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => GroupedOptionsModal(
        title: 'חלונות ודלתות',
        groups: DoorsWindowsOptions.groups,
        onSelect: (option) {
          debugPrint('🚪 Door/Window selected: ${option.name}, prompt: ${option.prompt}');
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _processWithPrompt(option.prompt);
            }
          });
        },
      ),
    );
  }

  void _showBathroomOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => GroupedOptionsModal(
        title: 'אפשרויות רחצה',
        groups: BathroomOptions.groups,
        onSelect: (option) {
          debugPrint('🚿 Bathroom selected: ${option.name}, prompt: ${option.prompt}');
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _processWithPrompt(option.prompt);
            }
          });
        },
      ),
    );
  }

  void _showRepairsOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => OptionsModal(
        title: 'בחר סוג תיקון/נזק',
        options: RepairsOptions.options,
        onSelect: (option) {
          debugPrint('🔧 Repairs selected: ${option.name}, prompt: ${option.prompt}');
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _processWithPrompt(option.prompt);
            }
          });
        },
      ),
    );
  }

  void _showCustomPromptDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'מה לעשות?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'תאר את השינוי הרצוי...',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ביטול'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          Navigator.pop(context);
                          _processWithPrompt(controller.text);
                        }
                      },
                      child: const Text('בצע'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    _showToast(
      message: '$feature - בקרוב!',
      icon: LucideIcons.sparkles,
      backgroundColor: AppColors.secondary600,
    );
  }

  Future<void> _processWithPrompt(String prompt) async {
    // Check credits first
    final canProcess = await _aiService.canMakeRequest();
    if (!canProcess) {
      _showLimitReachedModal();
      return;
    }

    if (!mounted || _mainImage == null) return;
    
    // Dismiss keyboard if open
    FocusScope.of(context).unfocus();
    
    setState(() {
      _isProcessing = true;
      _lastPrompt = prompt;
      _processingStatus = 'מתחיל...';
    });

    try {
      // Call the real AI service, passing object image if attached
      final result = await _aiService.processImage(
        imagePath: _mainImage!,
        prompt: prompt,
        objectImagePath: _objectImage,
        onStatusUpdate: (status) {
          if (mounted) {
            setState(() => _processingStatus = status);
          }
        },
      );

      if (!mounted) return;

      if (result.success && result.imageUrl != null) {
        debugPrint('🎉 AI Success! imageUrl: ${result.imageUrl}');
        
        // Create history entry with result
        final entry = HistoryEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imageUrl: result.imageUrl!,
          thumbnailUrl: result.thumbnailUrl,
          originalImageUrl: result.originalImageUrl ?? _originalImage,
          prompt: prompt,
          createdAt: DateTime.now(),
        );

        debugPrint('📝 Setting state: _isProcessing=false, _mainImage=${result.imageUrl}');
        setState(() {
          _isProcessing = false;
          _mainImage = result.imageUrl;
          _imageHistory.insert(0, entry);
          // Clear the object image after successful processing
          _objectImage = null;
        });
        debugPrint('✅ State updated successfully');

        // Refresh credits
        _loadUserCredits();

        // Auto-open image modal with comparison mode
        if (mounted) {
          _openImageModalWithComparison();
        }
      } else {
        throw Exception(result.error ?? 'שגיאה לא ידועה');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        
        // Show nice error modal instead of snackbar
        AIErrorModal.show(
          context,
          errorMessage: e.toString(),
        );
      }
    }
  }

  Future<void> _loadUserCredits() async {
    final info = await _aiService.getUserCreditsInfo();
    if (mounted) {
      setState(() {
        _userCredits = info.remaining;
      });
    }
  }

  void _showLimitReachedModal() {
    showDialog(
      context: context,
      builder: (context) => LimitReachedModal(
        userSubscription: _userSubscription,
        currentUsage: 3 - _userCredits,
        limit: 3,
        onShowPricing: _showSubscriptionModal,
      ),
    );
  }

  void _showSubscriptionModal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => SubscriptionModal(
          currentSubscription: _userSubscription,
          currentCredits: _userCredits,
          onPurchaseComplete: () {
            // Refresh user credits after purchase
            _loadUserCredits();
          },
        ),
      ),
    );
  }

  void _showMobileMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileMenuModal(
        isLoggedIn: _isLoggedIn,
        userEmail: _userEmail,
        userSubscription: _userSubscription,
        userCredits: _userCredits,
        userUsage: 3 - _userCredits,
        onLogin: () {
          // Note: mobile menu already pops itself before calling this
          _showAuthModal(true);
        },
        onSubscriptionClick: _showSubscriptionModal,
        onLogout: () {
          // Note: mobile menu already pops itself before calling this
          setState(() {
            _isLoggedIn = false;
            _userEmail = null;
          });
        },
        onCouponClick: () {
          // Note: mobile menu already pops itself before calling this
          _showCouponModal();
        },
      ),
    );
  }

  void _showCouponModal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => CouponModal(
          onRedeemCoupon: (code) async {
            // Call the actual server API to redeem the coupon
            return await _aiService.redeemCoupon(code);
          },
          onCouponSuccess: (credits) {
            // Update local credits state
            setState(() {
              _userCredits += credits;
            });
            // Also refresh from server to ensure consistency
            _loadUserCredits();
            // Show success toast
            _showToast(
              message: 'נוספו $credits קרדיטים לחשבונך! 🎉',
              icon: LucideIcons.gift,
              backgroundColor: const Color(0xFF10B981),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showAuthModal(bool isLogin) async {
    final result = await Navigator.of(context).push<AuthResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AuthModal(
          initialIsLogin: isLogin,
          onPasswordReset: (email) {
            // Handle password reset
          },
        ),
      ),
    );

    // Handle auth result if user submitted
    if (result != null && mounted) {
      setState(() {
        _isLoggedIn = true;
        _userEmail = result.email;
      });
    }
  }

  Future<void> _openImageModal({bool showComparison = false, bool isNewResult = false}) async {
    if (_mainImage == null) return;

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ImageModal(
          imageUrl: _mainImage!,
          originalImageUrl: _originalImage,
          prompt: _lastPrompt,
          initialShowComparison: showComparison,
          isNewResult: isNewResult,
        ),
      ),
    );

    // Handle result after modal closes
    if (result == 'revert' && _originalImage != null && mounted) {
      debugPrint('↩️ User reverted to original');
      setState(() {
        _mainImage = _originalImage;
      });
    } else if (result == 'keep') {
      debugPrint('✅ User kept the AI result');
    }
  }

  void _openImageModalWithComparison() {
    _openImageModal(showComparison: true, isNewResult: true);
  }

  void _handleHistoryTap(HistoryEntry entry) {
    setState(() {
      _mainImage = entry.imageUrl;
      _originalImage = entry.originalImageUrl;
      _lastPrompt = entry.prompt;
    });
  }

  List<OnboardingStep> get _onboardingSteps => [
    OnboardingStep(
      title: 'ברוכים הבאים למומחה!',
      description: 'בעזרת בינה מלאכותית, תוכלו להפוך כל חלל לעיצוב חלומותיכם בלחיצת כפתור.',
      targetKey: _uploadKey,
    ),
    OnboardingStep(
      title: 'בחרו כלי עיצוב',
      description: 'כאן תמצאו את כל הכלים לעיצוב - סגנונות, צבעים, תאורה ועוד.',
      targetKey: _toolsKey,
    ),
    OnboardingStep(
      title: 'היסטוריית העיצובים',
      description: 'כל העיצובים שלכם נשמרים כאן. תוכלו לחזור אליהם בכל עת.',
      targetKey: _historyKey,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  AppColors.primary900.withValues(alpha: 0.3),
                  AppColors.background,
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(),

                // Main canvas with image
                _buildMainCanvas(),

                // Prompt input
                _buildPromptInput(),

                // Action buttons row - hide when keyboard is open
                if (!_isPromptFocused) _buildActionButtons(),

                // History panel at bottom - hide when keyboard is open
                if (!_isPromptFocused) _buildHistorySection(),
              ],
            ),
          ),

          // Processing overlay
          if (_isProcessing)
            Positioned.fill(
              child: _buildProcessingOverlay(),
            ),

          // Onboarding overlay
          if (_showOnboarding)
            OnboardingOverlay(
              steps: _onboardingSteps,
              onComplete: () => setState(() => _showOnboarding = false),
              onSkip: () => setState(() => _showOnboarding = false),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Left side - Help and Contact buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Help button (most left)
              IconButton(
                onPressed: () {
                  setState(() => _showOnboarding = true);
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
                icon: Icon(
                  LucideIcons.helpCircle,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 22,
                ),
              ),
              // Contact button (to the right of help)
              IconButton(
                onPressed: _showFeedbackDialog,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
                icon: Icon(
                  LucideIcons.messageSquare,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 22,
                ),
              ),
            ],
          ),

          // Center - Logo
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primary300, Colors.white, AppColors.secondary300],
                    ).createShader(bounds),
                    child: const Text(
                      'מומחה',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  // AI badge with glow effect
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary500.withValues(alpha: 0.3),
                          AppColors.secondary400.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary500.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right side - Avatar with credits badge
          GestureDetector(
            onTap: _showMobileMenu,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Center(
                    child: _userEmail != null
                        ? Text(
                            _userEmail!.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            LucideIcons.user,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                ),
                // Credits badge
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gold, Color(0xFFFFB300)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.crown,
                          size: 10,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$_userCredits',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFeedbackDialog() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const ContactModal(),
      ),
    );

    // Show success message if submission was successful
    if (result == true && mounted) {
      _showToast(
        message: 'ההודעה נשלחה בהצלחה!',
        icon: LucideIcons.check,
        backgroundColor: Colors.green.shade600,
      );
    }
  }

  Widget _buildMainCanvas() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GlassCard(
          key: _uploadKey,
          child: _mainImage == null
              ? _buildUploadArea()
              : _buildImageDisplay(),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary500.withValues(alpha: 0.2),
                    AppColors.secondary500.withValues(alpha: 0.2),
                  ],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.upload,
                  size: 32,
                  color: AppColors.primary400,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'העלה תמונה',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'לחץ כאן להעלאת תמונה מהגלריה',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUploadOption(
                  icon: LucideIcons.image,
                  label: 'גלריה',
                  onTap: _pickImage,
                ),
                const SizedBox(width: 16),
                _buildUploadOption(
                  icon: LucideIcons.camera,
                  label: 'מצלמה',
                  onTap: _takePhoto,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary400),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageDisplay() {
    return Stack(
      children: [
        // Main image
        GestureDetector(
          onTap: _openImageModal,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildMainImage(),
          ),
        ),
        
        // Object image thumbnail (bottom right)
        if (_objectImage != null)
          Positioned(
            bottom: 16,
            right: 16,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Thumbnail
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary400,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_objectImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // X button to remove
                Positioned(
                  top: -8,
                  right: -8,
                  child: GestureDetector(
                    onTap: _removeObjectImage,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.x,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _removeObjectImage() {
    setState(() {
      _objectImage = null;
    });
    // Optionally clear the prompt if it contains the default object prompt
    const defaultPrompt = 'הוסף את הפריט המצורף לתמונה';
    if (_promptController.text.contains(defaultPrompt)) {
      _promptController.text = _promptController.text
          .replaceAll(defaultPrompt, '')
          .trim();
    }
  }

  Widget _buildMainImage() {
    if (_mainImage!.startsWith('assets/')) {
      return Image.asset(
        _mainImage!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error loading asset: $error');
          return _buildImageError();
        },
      );
    } else if (_mainImage!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: _mainImage!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary400),
        ),
        errorWidget: (context, url, error) {
          debugPrint('❌ Error loading image: $error');
          return _buildImageError();
        },
      );
    } else {
      return Image.file(
        File(_mainImage!),
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error loading file: $error');
          return _buildImageError();
        },
      );
    }
  }

  Widget _buildImageError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.alertCircle, color: Colors.red.shade400, size: 48),
          const SizedBox(height: 8),
          const Text('שגיאה בטעינת התמונה',
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildPromptInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        key: _toolsKey,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            // Text input
            Expanded(
              child: TextField(
                controller: _promptController,
                focusNode: _promptFocusNode,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'מה לשנות?',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _processWithPrompt(value);
                    _promptController.clear();
                  }
                },
              ),
            ),
            // Send button with sparkles icon
            GestureDetector(
              onTap: () {
                final prompt = _promptController.text.trim();
                if (prompt.isNotEmpty) {
                  _processWithPrompt(prompt);
                  _promptController.clear();
                } else {
                  // If no text, show the custom prompt dialog
                  _showCustomPromptDialog();
                }
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary500, AppColors.primary600],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.sparkles,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          // העלה תמונה (Upload image) button - Blue
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.upload,
              label: 'העלה תמונה',
              color: const Color(0xFF2196F3), // Blue
              onTap: _pickImage,
            ),
          ),
          const SizedBox(width: 10),
          // העלה פריט (Add item) button - Green
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.plus,
              label: 'העלה פריט',
              color: _objectImage != null ? AppColors.primary500 : const Color(0xFF4CAF50), // Green, or purple if has object
              onTap: _pickObjectImage,
            ),
          ),
          const SizedBox(width: 10),
          // עיצוב מחדש (Redesign) button - Purple
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.wand2,
              label: 'עיצוב מחדש',
              color: const Color(0xFF9C27B0), // Purple
              onTap: _showStyleSelector,
            ),
          ),
          const SizedBox(width: 10),
          // עוד (More) button - Opens bottom drawer
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.moreHorizontal,
              label: 'עוד',
              color: Colors.grey.shade700,
              onTap: _showMoreOptionsDrawer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 24),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return GestureDetector(
      key: _historyKey,
      onTap: _showHistoryDrawer,
      onVerticalDragUpdate: (details) {
        // Swipe up to open drawer
        if (details.delta.dy < -5) {
          _showHistoryDrawer();
        }
      },
      child: Container(
        height: 44,
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Arrow up icon
            Icon(
              LucideIcons.chevronUp,
              size: 20,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 2),
            // History text
            Text(
              'היסטוריה',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.history, color: AppColors.primary400, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'היסטוריה',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white10),
            // History content
            Expanded(
              child: _imageHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.image,
                            color: Colors.white.withValues(alpha: 0.3),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'עדיין אין היסטוריה',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'התמונות שתעלה ותערוך יופיעו כאן',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _imageHistory.length,
                      itemBuilder: (context, index) {
                        final entry = _imageHistory[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _handleHistoryTap(entry);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildHistoryThumbnail(entry),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryThumbnail(HistoryEntry entry) {
    final imageUrl = entry.thumbnailUrl ?? entry.imageUrl;
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surfaceHighlight,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary400,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.surfaceHighlight,
          child: const Icon(LucideIcons.imageOff, color: AppColors.textMuted),
        ),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    } else {
      return Image.file(File(imageUrl), fit: BoxFit.cover);
    }
  }

  void _showMoreOptionsDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'עוד אפשרויות',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white10),
            // Options Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: _designActions.length,
                itemBuilder: (context, index) {
                  final action = _designActions[index];
                  return _buildMoreOptionItem(
                    icon: action['icon'] as IconData,
                    label: action['label'] as String,
                    onTap: () {
                      Navigator.pop(context);
                      _handleActionTap(action['action'] as String);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primary500.withValues(alpha: 0.3),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary400, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary500.withValues(alpha: 0.2),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simple loader
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: AppColors.primary400,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'המומחה עובד...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _processingStatus.isNotEmpty ? _processingStatus : 'מעצב את התמונה שלך',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
