import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import '../modals/rate_app_modal.dart';
import '../modals/create_account_prompt_modal.dart';
import '../models/history_entry.dart';
import '../services/ai_service.dart';
import '../services/analytics_service.dart';
import '../l10n/localized_options.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  // Services
  final AIService _aiService = AIService();
  final AnalyticsService _analytics = AnalyticsService();
  
  // Image state
  String? _mainImage;
  String? _originalImage; // The very first uploaded image (for full revert)
  String? _beforeImage; // The image before the last processing (for comparison)
  String? _objectImage; // Object/item image to add to main image
  bool _isProcessing = false;
  String? _lastPrompt;
  String _processingStatus = '';
  int _currentPhraseIndex = 0;
  
  // Fun AI-related phrases - now loaded from localization
  List<String> _getFunPhrases(BuildContext context) {
    return context.localizedOptions.funPhrases;
  }
  
  // Keyboard visibility tracking
  double _previousBottomInset = 0;

  // History
  final List<HistoryEntry> _imageHistory = [];
  bool _historyLoading = false;
  bool _hasMoreHistory = true;
  DocumentSnapshot? _lastHistoryDoc;
  
  // User state
  String? _userEmail;
  int _userCredits = 0;
  int _userSubscription = 0;
  bool _isLoggedIn = false;

  // UI state
  bool _showOnboarding = false;
  late AnimationController _processingController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _iconRotateController;
  Timer? _phraseTimer;
  
  // Prompt input
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _promptFocusNode = FocusNode();
  bool _isPromptFocused = false;

  // Keys for onboarding
  final GlobalKey _uploadKey = GlobalKey();
  final GlobalKey _historyKey = GlobalKey();
  final GlobalKey _redesignKey = GlobalKey();
  final GlobalKey _promptKey = GlobalKey();
  final GlobalKey _addItemKey = GlobalKey();

  final ImagePicker _picker = ImagePicker();

  // Design actions - loaded from localization
  List<Map<String, dynamic>> _getDesignActions(BuildContext context) {
    return context.localizedOptions.designActions;
  }

  // Default image constant
  static const String _defaultAssetImage = 'assets/images/design_mobile.jpg';
  
  // Shared preferences key for onboarding
  static const String _onboardingShownKey = 'onboarding_shown';

  @override
  void initState() {
    super.initState();
    _processingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    
    _iconRotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
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

  String? _lastSyncedLocale;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync the current locale with AIService when dependencies change
    final locale = Localizations.localeOf(context);
    final localeString = locale.countryCode != null 
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    
    // Only update if locale changed
    if (_lastSyncedLocale != localeString) {
      _lastSyncedLocale = localeString;
      _aiService.setCurrentLocale(localeString);
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Sign in anonymously
      await _aiService.ensureSignedIn();
      
      // Load user credits (also loads subscription, email, and login status)
      await _loadUserCredits();
      
      // Load history
      await _loadHistory();
      
      // Check if this is the first launch and show onboarding
      await _checkFirstLaunchOnboarding();
    } catch (e) {
      print('Error initializing app: $e');
    }
  }
  
  Future<void> _checkFirstLaunchOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool(_onboardingShownKey) ?? false;
      
      if (!hasSeenOnboarding && mounted) {
        // Show onboarding on first launch
        setState(() => _showOnboarding = true);
        
        // Mark onboarding as shown
        await prefs.setBool(_onboardingShownKey, true);
        
        // Track first open with onboarding
        _analytics.logFirstOpen();
      }
    } catch (e) {
      print('Error checking first launch onboarding: $e');
    }
  }

  Future<void> _loadHistory() async {
    if (_historyLoading) return;
    
    setState(() => _historyLoading = true);
    
    try {
      final result = await _aiService.loadUserHistory();
      if (mounted) {
        setState(() {
          _imageHistory.clear();
          _imageHistory.addAll(result.items.map((data) => HistoryEntry(
            id: data['id'] ?? '',
            imageUrl: data['storageUrl'] ?? data['imageUrl'] ?? '',
            thumbnailUrl: data['thumbnailUrl'],
            originalImageUrl: data['originalImageUrl'],
            prompt: data['prompt'],
            createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
          )));
          _hasMoreHistory = result.hasMore;
          _lastHistoryDoc = result.lastDocument;
          
          // Set the main image to the most recent history entry if available
          if (_imageHistory.isNotEmpty) {
            final lastEntry = _imageHistory.first;
            _mainImage = lastEntry.imageUrl;
            _originalImage = lastEntry.originalImageUrl ?? lastEntry.imageUrl;
            _beforeImage = lastEntry.originalImageUrl;
            _lastPrompt = lastEntry.prompt;
          }
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
    _shimmerController.dispose();
    _pulseController.dispose();
    _iconRotateController.dispose();
    _phraseTimer?.cancel();
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
      // Track gallery upload
      _analytics.logImageUploadGallery();
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
      // Track camera upload
      _analytics.logImageUploadCamera();
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

      // Track object image attached
      _analytics.logObjectImageAttached();

      // Add default prompt if prompt is empty, or append it
      final l10n = context.l10n;
      final defaultPrompt = l10n.addAttachedItem;
      final currentPrompt = _promptController.text.trim();
      
      if (currentPrompt.isEmpty) {
        _promptController.text = defaultPrompt;
      } else if (!currentPrompt.contains(defaultPrompt)) {
        _promptController.text = '$currentPrompt $defaultPrompt';
      }

      // Show toast/snackbar
      if (mounted) {
        _showToast(
          message: l10n.itemImageLoaded,
          icon: LucideIcons.check,
          backgroundColor: Colors.green.shade600,
        );
      }
    }
  }

  Future<void> _uploadImageToHistory(String imagePath) async {
    final l10n = context.l10n;
    setState(() {
      _mainImage = imagePath;
      _originalImage = imagePath;
      _beforeImage = imagePath; // Initialize before image for first comparison
      _isProcessing = true;
      _processingStatus = l10n.uploadingImage;
    });

    try {
      final entry = await _aiService.uploadImageToHistory(imagePath);
      
      if (mounted) {
        final storageUrl = entry['storageUrl'] as String;
        setState(() {
          _mainImage = storageUrl;
          _originalImage = storageUrl;
          _beforeImage = storageUrl; // Update before image for comparison
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
          message: context.l10n.errorUploadingImage,
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
      message: context.l10n.uploadImageFirst,
      icon: LucideIcons.upload,
      backgroundColor: AppColors.primary600,
    );
  }

  void _showStyleSelector() {
    // Track style modal opened
    _analytics.logStyleModalOpened();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StyleSelectorModal(
        onStyleSelect: (style) {
          Navigator.pop(modalContext);
          // Track style selected
          _analytics.logStyleSelected(style.name);
          // Use Future.delayed to ensure modal is closed before processing
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              // Process immediately for style selection
              _processWithPrompt(style.prompt, promptType: 'style', styleName: style.name);
            }
          });
        },
      ),
    );
  }

  void _showColorPalette() {
    // Track color modal opened
    _analytics.logColorModalOpened();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => ColorPaletteModal(
        onColorSelect: (color, prompt) {
          debugPrint('🎨 Color selected: ${color.name}, prompt: $prompt');
          // Track color selected
          _analytics.logColorSelected(color.name);
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              // Process immediately for color selection
              _processWithPrompt(prompt, promptType: 'color', colorName: color.name);
            }
          });
        },
      ),
    );
  }

  void _showLightingOptions() {
    // Track options modal opened
    _analytics.logOptionsModalOpened('lighting');
    final l10n = context.l10n;
    final options = context.localizedOptions.lightingOptions;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => OptionsModal(
        title: l10n.selectLightingType,
        options: options,
        onSelect: (option) {
          debugPrint('💡 Lighting selected: ${option.name}, prompt: ${option.prompt}');
          // Track option selected
          _analytics.logOptionSelected('lighting', option.name);
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _setPromptText(option.prompt);
            }
          });
        },
      ),
    );
  }

  void _showFurnitureOptions() {
    // Track options modal opened
    _analytics.logOptionsModalOpened('furniture');
    final l10n = context.l10n;
    final options = context.localizedOptions.furnitureOptions;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => OptionsModal(
        title: l10n.selectFurnitureType,
        options: options,
        onSelect: (option) {
          debugPrint('🪑 Furniture selected: ${option.name}, prompt: ${option.prompt}');
          // Track option selected
          _analytics.logOptionSelected('furniture', option.name);
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _setPromptText(option.prompt);
            }
          });
        },
      ),
    );
  }

  void _showDoorsWindowsOptions() {
    // Track options modal opened
    _analytics.logOptionsModalOpened('doors_windows');
    final l10n = context.l10n;
    final groups = context.localizedOptions.doorsWindowsGroups;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => GroupedOptionsModal(
        title: l10n.doorsWindows,
        groups: groups,
        onSelect: (option) {
          debugPrint('🚪 Door/Window selected: ${option.name}, prompt: ${option.prompt}');
          // Track option selected
          _analytics.logOptionSelected('doors_windows', option.name);
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _setPromptText(option.prompt);
            }
          });
        },
      ),
    );
  }

  void _showBathroomOptions() {
    // Track options modal opened
    _analytics.logOptionsModalOpened('bathroom');
    final l10n = context.l10n;
    final groups = context.localizedOptions.bathroomGroups;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => GroupedOptionsModal(
        title: l10n.bathroomOptions,
        groups: groups,
        onSelect: (option) {
          debugPrint('🚿 Bathroom selected: ${option.name}, prompt: ${option.prompt}');
          // Track option selected
          _analytics.logOptionSelected('bathroom', option.name);
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _setPromptText(option.prompt);
            }
          });
        },
      ),
    );
  }

  void _showRepairsOptions() {
    // Track options modal opened
    _analytics.logOptionsModalOpened('repairs');
    final l10n = context.l10n;
    final options = context.localizedOptions.repairsOptions;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => OptionsModal(
        title: l10n.selectRepairType,
        options: options,
        onSelect: (option) {
          debugPrint('🔧 Repairs selected: ${option.name}, prompt: ${option.prompt}');
          // Track option selected
          _analytics.logOptionSelected('repairs', option.name);
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _setPromptText(option.prompt);
            }
          });
        },
      ),
    );
  }

  void _showCustomPromptDialog() {
    final controller = TextEditingController();
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
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
              Text(
                l10n.whatToDo,
                style: const TextStyle(
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
                decoration: InputDecoration(
                  hintText: l10n.describeChange,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          Navigator.pop(dialogContext);
                          _processWithPrompt(controller.text);
                        }
                      },
                      child: Text(l10n.execute),
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
      message: context.l10n.comingSoon(feature),
      icon: LucideIcons.sparkles,
      backgroundColor: AppColors.secondary600,
    );
  }

  /// Sets the prompt text without auto-submitting, allowing user to edit
  void _setPromptText(String prompt) {
    _promptController.text = prompt;
    // Move cursor to end of text
    _promptController.selection = TextSelection.fromPosition(
      TextPosition(offset: _promptController.text.length),
    );
    // Show notification to user
    _showToast(
      message: context.l10n.promptAddedToInput,
      icon: LucideIcons.pencil,
      backgroundColor: AppColors.primary600,
    );
  }

  Future<void> _processWithPrompt(
    String prompt, {
    String promptType = 'custom',
    String? styleName,
    String? colorName,
  }) async {
    // Check if anonymous user is trying their 3rd generation - prompt them to create account
    if (_aiService.isAnonymous) {
      final creditsInfo = await _aiService.getUserCreditsInfo();
      if (creditsInfo.count >= 2) {
        // Show create account prompt dialog
        final wantsToCreateAccount = await _showCreateAccountPrompt();
        if (wantsToCreateAccount) {
          // User wants to create account - show auth modal will be triggered in the dialog
          return; // Don't proceed with generation, let user create account first
        }
        // User chose "Maybe Later" - continue with generation
      }
    }

    // Check credits first
    final canProcess = await _aiService.canMakeRequest();
    if (!canProcess) {
      _showLimitReachedModal();
      return;
    }

    if (!mounted || _mainImage == null) return;
    
    // Dismiss keyboard if open
    FocusScope.of(context).unfocus();
    
    // Save current image as "before" for comparison
    _beforeImage = _mainImage;
    
    // Track AI processing started
    final startTime = DateTime.now();
    _analytics.logAIProcessingStarted(
      promptType: promptType,
      styleName: styleName,
      colorName: colorName,
      hasObjectImage: _objectImage != null,
    );
    
    final funPhrases = _getFunPhrases(context);
    setState(() {
      _isProcessing = true;
      _lastPrompt = prompt;
      _processingStatus = context.l10n.processingStarting;
      _currentPhraseIndex = Random().nextInt(funPhrases.length);
    });
    
    // Start phrase cycling timer
    _phraseTimer?.cancel();
    _phraseTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (mounted && _isProcessing) {
        setState(() {
          _currentPhraseIndex = (_currentPhraseIndex + 1) % funPhrases.length;
        });
      } else {
        timer.cancel();
      }
    });

    try {
      // Call the real AI service, passing object image if attached
      final result = await _aiService.processImage(
        imagePath: _mainImage!,
        prompt: prompt,
        objectImagePath: _objectImage,
        onStatusUpdate: (status) {
          if (mounted) {
            final l10n = context.l10n;
            final localizedStatus = switch (status) {
              ProcessingStatus.connectingToCloud => l10n.connectingToCloud,
              ProcessingStatus.uploadingImage => l10n.uploadingImage,
              ProcessingStatus.sendingToAI => l10n.sendingToAI,
              ProcessingStatus.analyzingItem => l10n.analyzingItem,
              ProcessingStatus.creatingDesign => l10n.creatingDesign,
            };
            setState(() => _processingStatus = localizedStatus);
          }
        },
      );

      if (!mounted) return;

      if (result.success && result.imageUrl != null) {
        debugPrint('🎉 AI Success! imageUrl: ${result.imageUrl}');
        
        // Track AI processing success
        final processingTime = DateTime.now().difference(startTime).inMilliseconds;
        _analytics.logAIProcessingSuccess(
          promptType: promptType,
          processingTimeMs: processingTime,
        );
        
        // Create history entry with result
        // Store _beforeImage (the image that was processed) for comparison
        final entry = HistoryEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imageUrl: result.imageUrl!,
          thumbnailUrl: result.thumbnailUrl,
          originalImageUrl: _beforeImage ?? _originalImage,
          prompt: prompt,
          createdAt: DateTime.now(),
        );

        debugPrint('📝 Setting state: _isProcessing=false, _mainImage=${result.imageUrl}');
        _phraseTimer?.cancel();
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
        _phraseTimer?.cancel();
        setState(() => _isProcessing = false);
        
        final errorMessage = e.toString();
        
        // Track AI processing error
        _analytics.logAIProcessingError(
          promptType: promptType,
          errorMessage: errorMessage,
        );
        
        // Check if this is a "limit reached" error from the server
        if (errorMessage.contains('limit reached') || errorMessage.contains('Generation limit')) {
          // Parse usage and limit from error message if available (format: "Generation limit reached (19/3)")
          int? parsedUsage;
          int? parsedLimit;
          final match = RegExp(r'\((\d+)/(\d+)\)').firstMatch(errorMessage);
          if (match != null) {
            parsedUsage = int.tryParse(match.group(1) ?? '');
            parsedLimit = int.tryParse(match.group(2) ?? '');
          }
          
          // Show the limit reached modal to prompt upgrade
          _showLimitReachedModal(
            customUsage: parsedUsage,
            customLimit: parsedLimit,
          );
        } else {
          // Show generic error modal for other errors
          AIErrorModal.show(
            context,
            errorMessage: errorMessage,
          );
        }
      }
    }
  }

  Future<void> _loadUserCredits() async {
    final info = await _aiService.getUserCreditsInfo();
    if (mounted) {
      setState(() {
        _userCredits = info.remaining;
        _userSubscription = info.subscription;
        _userEmail = _aiService.currentUserEmail;
        _isLoggedIn = !_aiService.isAnonymous;
      });
      
      // Update analytics user properties
      _analytics.setUserId(_aiService.currentUserId);
      _analytics.setSubscriptionTier(_userSubscription);
      _analytics.setLoginStatus(_isLoggedIn);
    }
  }

  void _showLimitReachedModal({int? customUsage, int? customLimit}) {
    // Use parsed values from error or fall back to local state
    final usage = customUsage ?? (3 - _userCredits);
    final limit = customLimit ?? 3;
    
    // Track limit reached shown
    _analytics.logLimitReachedShown(currentUsage: usage, limit: limit);
    
    showDialog(
      context: context,
      builder: (context) => LimitReachedModal(
        userSubscription: _userSubscription,
        currentUsage: usage,
        limit: limit,
        onShowPricing: _showSubscriptionModal,
      ),
    );
  }

  /// Shows a prompt dialog for anonymous users to create an account
  /// Returns true if user wants to create account, false if they want to continue without
  Future<bool> _showCreateAccountPrompt() async {
    return await CreateAccountPromptModal.show(
      context,
      onCreateAccount: () {
        // Show the auth modal in sign up mode (initialIsLogin = false)
        _showAuthModal(false);
      },
    );
  }

  void _showSubscriptionModal() {
    // Track subscription modal opened
    _analytics.logSubscriptionModalOpened(source: 'menu');
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => SubscriptionModal(
          currentSubscription: _userSubscription,
          currentCredits: _userCredits,
          onPurchaseComplete: () {
            // Refresh user credits after purchase
            _loadUserCredits();
            
            // If user is anonymous, prompt them to secure their purchase
            if (_aiService.isAnonymous) {
              _showSecureAccountDialog();
            }
          },
        ),
      ),
    );
  }
  
  void _showSecureAccountDialog() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(LucideIcons.shieldCheck, color: AppColors.secondary500, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.secureYourSubscription,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.secureSubscriptionMessage,
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.later,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showAuthModal(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(l10n.loginNow),
          ),
        ],
      ),
    );
  }

  void _showMobileMenu() {
    // Track mobile menu opened
    _analytics.logMobileMenuOpened();
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
        onLogout: () async {
          // Track logout
          _analytics.logLogout();
          // Note: mobile menu already pops itself before calling this
          await _aiService.signOut();
          // Sign back in anonymously and refresh state
          await _aiService.ensureSignedIn();
          await _loadUserCredits();
          await _loadHistory();
          if (mounted) {
            _showToast(
              message: context.l10n.loggedOutSuccess,
              icon: LucideIcons.logOut,
              backgroundColor: AppColors.primary600,
            );
          }
        },
        onCouponClick: () {
          // Note: mobile menu already pops itself before calling this
          _showCouponModal();
        },
        onDeleteAccount: () {
          // Note: mobile menu already pops itself before calling this
          _handleDeleteAccount();
        },
        onLanguageChanged: () {
          // Language was changed, show toast
          if (mounted) {
            _showToast(
              message: context.l10n.languageChanged,
              icon: LucideIcons.globe,
              backgroundColor: Colors.cyan,
            );
          }
        },
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    final l10n = context.l10n;
    
    // Show loading toast
    _showToast(
      message: l10n.deletingAccount,
      icon: LucideIcons.loader,
      backgroundColor: AppColors.primary600,
      duration: const Duration(seconds: 10),
    );
    
    try {
      final result = await _aiService.deleteAccount();
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        // Track account deleted
        _analytics.logAccountDeleted();
        
        // Clear local history
        setState(() {
          _imageHistory.clear();
          _mainImage = _defaultAssetImage;
          _originalImage = _defaultAssetImage;
          _beforeImage = null;
          _objectImage = null;
        });
        
        // Refresh user state (now anonymous)
        await _loadUserCredits();
        
        _showToast(
          message: l10n.accountDeleted,
          icon: LucideIcons.checkCircle,
          backgroundColor: Colors.green.shade600,
        );
      } else {
        _showToast(
          message: result['error'] ?? l10n.errorDeletingAccount,
          icon: LucideIcons.alertCircle,
          backgroundColor: Colors.red.shade600,
        );
      }
    } catch (e) {
      if (mounted) {
        _showToast(
          message: l10n.errorDeletingAccount,
          icon: LucideIcons.alertCircle,
          backgroundColor: Colors.red.shade600,
        );
      }
    }
  }

  void _showCouponModal() {
    // Track coupon modal opened
    _analytics.logCouponModalOpened();
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => CouponModal(
          onRedeemCoupon: (code) async {
            // Call the actual server API to redeem the coupon
            return await _aiService.redeemCoupon(code);
          },
          onCouponSuccess: (credits) {
            // Track coupon redeemed
            _analytics.logCouponRedeemed(creditsAdded: credits);
            // Update local credits state
            setState(() {
              _userCredits += credits;
            });
            // Also refresh from server to ensure consistency
            _loadUserCredits();
            // Show success toast
            _showToast(
              message: context.l10n.creditsAddedToAccount(credits),
              icon: LucideIcons.gift,
              backgroundColor: const Color(0xFF10B981),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showAuthModal(bool isLogin) async {
    // Track auth modal opened
    if (isLogin) {
      _analytics.logLoginStarted();
    } else {
      _analytics.logSignupStarted();
    }
    
    final result = await Navigator.of(context).push<AuthResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AuthModal(
          initialIsLogin: isLogin,
          onPasswordReset: (email) async {
            // Track password reset requested
            _analytics.logPasswordResetRequested();
            final l10n = context.l10n;
            try {
              await _aiService.sendPasswordResetEmail(email);
              if (mounted) {
                _showToast(
                  message: l10n.passwordResetEmailSent,
                  icon: LucideIcons.mail,
                  backgroundColor: Colors.green.shade600,
                );
              }
            } catch (e) {
              if (mounted) {
                final errorString = e.toString().toLowerCase();
                String errorMessage = l10n.passwordResetError;
                
                if (errorString.contains('user-not-found')) {
                  errorMessage = l10n.userNotFound;
                } else if (errorString.contains('invalid-email')) {
                  errorMessage = l10n.invalidEmail;
                }
                
                _showToast(
                  message: errorMessage,
                  icon: LucideIcons.alertCircle,
                  backgroundColor: Colors.red.shade600,
                );
              }
            }
          },
        ),
      ),
    );

    // Handle auth result if user submitted
    if (result != null && mounted) {
      final l10n = context.l10n;
      try {
        // Show loading indicator
        _showToast(
          message: result.isLogin ? l10n.loggingIn : l10n.creatingAccount,
          icon: LucideIcons.loader,
          backgroundColor: AppColors.primary600,
        );

        // Actually perform Firebase authentication
        if (result.isLogin) {
          await _aiService.signInWithEmail(result.email, result.password);
          // Track login success
          _analytics.logLoginSuccess();
        } else {
          await _aiService.createAccountWithEmail(result.email, result.password);
          // Track signup success
          _analytics.logSignupSuccess();
        }
        
        // Set user properties in analytics
        _analytics.setUserId(_aiService.currentUserId);
        _analytics.setLoginStatus(true);

        // Refresh user data (credits, subscription, email)
        await _loadUserCredits();
        
        // Reload history for the logged-in user
        await _loadHistory();

        if (mounted) {
          // Show success toast
          _showToast(
            message: result.isLogin ? l10n.loginSuccess : l10n.accountCreated,
            icon: LucideIcons.checkCircle,
            backgroundColor: Colors.green.shade600,
          );
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = l10n.loginError;
          final errorString = e.toString().toLowerCase();
          String? errorCode;
          
          if (errorString.contains('user-not-found')) {
            errorMessage = l10n.userNotFound;
            errorCode = 'user-not-found';
          } else if (errorString.contains('wrong-password') || errorString.contains('invalid-credential')) {
            errorMessage = l10n.wrongPassword;
            errorCode = 'wrong-password';
          } else if (errorString.contains('email-already-in-use')) {
            errorMessage = l10n.emailInUse;
            errorCode = 'email-already-in-use';
          } else if (errorString.contains('weak-password')) {
            errorMessage = l10n.weakPassword;
            errorCode = 'weak-password';
          } else if (errorString.contains('invalid-email')) {
            errorMessage = l10n.invalidEmail;
            errorCode = 'invalid-email';
          }
          
          // Track auth failure
          if (result.isLogin) {
            _analytics.logLoginFailed(errorCode: errorCode);
          } else {
            _analytics.logSignupFailed(errorCode: errorCode);
          }

          _showToast(
            message: errorMessage,
            icon: LucideIcons.alertCircle,
            backgroundColor: Colors.red.shade600,
          );
        }
      }
    }
  }

  Future<void> _openImageModal({bool showComparison = false, bool isNewResult = false}) async {
    if (_mainImage == null) return;

    // Track image modal opened
    _analytics.logImageModalOpened(showComparison: showComparison);

    // Use _beforeImage for comparison (the image before last processing)
    // Fall back to _originalImage if _beforeImage is not set
    final comparisonImage = _beforeImage ?? _originalImage;

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ImageModal(
          imageUrl: _mainImage!,
          originalImageUrl: comparisonImage,
          prompt: _lastPrompt,
          initialShowComparison: showComparison,
          isNewResult: isNewResult,
          onKeepResult: isNewResult ? () => _onUserKeptResult() : null,
        ),
      ),
    );

    // Handle result after modal closes
    if (result == 'revert' && comparisonImage != null && mounted) {
      debugPrint('↩️ User reverted to before image');
      // Track AI result reverted
      _analytics.logAIResultReverted();
      setState(() {
        _mainImage = comparisonImage;
      });
    } else if (result == 'keep') {
      debugPrint('✅ User kept the AI result');
    }
  }

  /// Called when user clicks "Love it! Save" on a new AI result
  Future<void> _onUserKeptResult() async {
    debugPrint('✅ User kept the AI result');
    
    // Track AI result kept
    _analytics.logAIResultKept();
    
    // Get the current count of kept results
    final prefs = await SharedPreferences.getInstance();
    final keptCount = prefs.getInt('kept_results_count') ?? 0;
    final hasRated = prefs.getBool('has_rated_app') ?? false;
    
    // Increment the count
    final newCount = keptCount + 1;
    await prefs.setInt('kept_results_count', newCount);
    
    debugPrint('📊 User has kept $newCount results (hasRated: $hasRated)');
    
    // Show rating modal on the 2nd kept result (and hasn't rated before)
    if (newCount == 2 && !hasRated && mounted) {
      // Small delay to let the UI settle
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      
      // Track rate app shown
      _analytics.logRateAppShown();
      
      final rateResult = await RateAppModal.show(context);
      
      if (rateResult == RateAppResult.yes) {
        // Track rate app response
        _analytics.logRateAppResponse(response: 'yes');
        // User likes the app, show in-app review
        debugPrint('💖 User likes the app, showing in-app review');
        await prefs.setBool('has_rated_app', true);
        
        final inAppReview = InAppReview.instance;
        if (await inAppReview.isAvailable()) {
          await inAppReview.requestReview();
        }
      } else if (rateResult == RateAppResult.no) {
        // Track rate app response
        _analytics.logRateAppResponse(response: 'no');
        // User doesn't like it, mark as rated so we don't ask again
        debugPrint('😢 User doesn\'t like the app');
        await prefs.setBool('has_rated_app', true);
      } else if (rateResult == RateAppResult.later) {
        // Track rate app response
        _analytics.logRateAppResponse(response: 'later');
        // Reset count to ask again after 2 more kept results
        debugPrint('⏰ User wants to be asked later');
        await prefs.setInt('kept_results_count', 0);
      }
    }
  }

  void _openImageModalWithComparison() {
    _openImageModal(showComparison: true, isNewResult: true);
  }

  void _handleHistoryTap(HistoryEntry entry) {
    // Track history item selected
    _analytics.logHistoryItemSelected();
    setState(() {
      _mainImage = entry.imageUrl;
      _beforeImage = entry.originalImageUrl; // For comparison
      _lastPrompt = entry.prompt;
    });
  }

  List<OnboardingStep> _getOnboardingSteps(BuildContext context) {
    final l10n = context.l10n;
    return [
      OnboardingStep(
        title: l10n.onboardingUploadTitle,
        description: l10n.onboardingUploadDesc,
        targetKey: _uploadKey,
      ),
      OnboardingStep(
        title: l10n.onboardingStyleTitle,
        description: l10n.onboardingStyleDesc,
        targetKey: _redesignKey,
      ),
      OnboardingStep(
        title: l10n.onboardingCreateTitle,
        description: l10n.onboardingCreateDesc,
        targetKey: _promptKey,
      ),
      OnboardingStep(
        title: l10n.onboardingItemTipTitle,
        description: l10n.onboardingItemTipDesc,
        targetKey: _addItemKey,
      ),
    ];
  }

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
              steps: _getOnboardingSteps(context),
              onComplete: () {
                _analytics.logOnboardingComplete();
                setState(() => _showOnboarding = false);
              },
              onSkip: () {
                _analytics.logOnboardingSkipped();
                setState(() => _showOnboarding = false);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SizedBox(
        height: 48,
        child: Stack(
          children: [
            // Center - Logo (absolutely centered on screen)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primary300, Colors.white, AppColors.secondary300],
                    ).createShader(bounds),
                    child: Text(
                      context.l10n.appName,
                      style: const TextStyle(
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

            // Left side buttons - top left corner
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Help button
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
                  // Contact button
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
            ),

            // Right side - Avatar with credits badge - top right corner
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
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
                        child: _userEmail != null && _userEmail!.isNotEmpty
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFeedbackDialog() async {
    // Track contact modal opened
    _analytics.logContactModalOpened();
    
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const ContactModal(),
      ),
    );

    // Show success message if submission was successful
    if (result == true && mounted) {
      // Track feedback submitted
      _analytics.logFeedbackSubmitted();
      _showToast(
        message: context.l10n.messageSentSuccess,
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
          child: _mainImage == null
              ? _buildUploadArea()
              : _buildImageDisplay(),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    final l10n = context.l10n;
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
            Text(
              l10n.uploadImage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.clickToUploadImage,
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
                  label: l10n.gallery,
                  onTap: _pickImage,
                ),
                const SizedBox(width: 16),
                _buildUploadOption(
                  icon: LucideIcons.camera,
                  label: l10n.camera,
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
    // Track object image removed
    _analytics.logObjectImageRemoved();
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
          Text(context.l10n.errorDownloadingImage,
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildPromptInput() {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        key: _promptKey,
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
                decoration: InputDecoration(
                  hintText: l10n.whatToChange,
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
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          // Upload image button - Blue
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.upload,
              label: l10n.uploadImage,
              color: const Color(0xFF2196F3), // Blue
              onTap: _pickImage,
              buttonKey: _uploadKey,
            ),
          ),
          const SizedBox(width: 10),
          // Add item button - Green
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.plus,
              label: l10n.uploadItem,
              color: _objectImage != null ? AppColors.primary500 : const Color(0xFF4CAF50), // Green, or purple if has object
              onTap: _pickObjectImage,
              buttonKey: _addItemKey,
            ),
          ),
          const SizedBox(width: 10),
          // Redesign button - Purple
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.wand2,
              label: l10n.redesign,
              color: const Color(0xFF9C27B0), // Purple
              onTap: _showStyleSelector,
              buttonKey: _redesignKey,
            ),
          ),
          const SizedBox(width: 10),
          // More button - Opens bottom drawer
          Expanded(
            child: _buildActionButton(
              icon: LucideIcons.moreHorizontal,
              label: l10n.more,
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
    Key? buttonKey,
  }) {
    return GestureDetector(
      key: buttonKey,
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
    final l10n = context.l10n;
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
              l10n.history,
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
    // Track history opened
    _analytics.logHistoryOpened();
    final l10n = context.l10n;
    // Use ValueNotifier to properly track loading state across rebuilds
    final isLoadingMore = ValueNotifier<bool>(false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          Future<void> loadMoreInModal() async {
            if (isLoadingMore.value || !_hasMoreHistory || _lastHistoryDoc == null) return;
            
            isLoadingMore.value = true;
            setModalState(() {});
            
            try {
              final result = await _aiService.loadUserHistory(
                startAfterDoc: _lastHistoryDoc,
              );
              if (mounted) {
                setState(() {
                  _imageHistory.addAll(result.items.map((data) => HistoryEntry(
                    id: data['id'] ?? '',
                    imageUrl: data['storageUrl'] ?? data['imageUrl'] ?? '',
                    thumbnailUrl: data['thumbnailUrl'],
                    originalImageUrl: data['originalImageUrl'],
                    prompt: data['prompt'],
                    createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
                  )));
                  _hasMoreHistory = result.hasMore;
                  _lastHistoryDoc = result.lastDocument;
                });
                isLoadingMore.value = false;
                setModalState(() {});
              }
            } catch (e) {
              print('Error loading more history: $e');
              isLoadingMore.value = false;
              setModalState(() {});
            }
          }

          return Container(
            height: MediaQuery.of(modalContext).size.height * 0.5,
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
                          Text(
                            l10n.history,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(modalContext),
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
                                l10n.noHistoryYet,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.uploadedImagesWillAppear,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            // Load more when user scrolls near the bottom
                            if (scrollInfo.metrics.pixels >= 
                                scrollInfo.metrics.maxScrollExtent - 200) {
                              if (_hasMoreHistory && !isLoadingMore.value) {
                                loadMoreInModal();
                              }
                            }
                            return false;
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.0,
                            ),
                            // Add extra item for loading indicator when loading more
                            itemCount: _imageHistory.length + (isLoadingMore.value ? 1 : 0),
                            itemBuilder: (context, index) {
                              // Show loading indicator at the end
                              if (index == _imageHistory.length) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary400,
                                    ),
                                  ),
                                );
                              }
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
                ),
              ],
            ),
          );
        },
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
    // Track more options opened
    _analytics.logMoreOptionsOpened();
    final l10n = context.l10n;
    final designActions = _getDesignActions(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        height: MediaQuery.of(modalContext).size.height * 0.6,
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
                  Text(
                    l10n.moreOptions,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(modalContext),
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
                itemCount: designActions.length,
                itemBuilder: (gridContext, index) {
                  final action = designActions[index];
                  return _buildMoreOptionItem(
                    icon: action['icon'] as IconData,
                    label: action['label'] as String,
                    onTap: () {
                      Navigator.pop(modalContext);
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
    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerController, _pulseController, _iconRotateController]),
      builder: (context, child) {
        final shimmerValue = _shimmerController.value;
        final pulseValue = _pulseController.value;
        final rotateValue = _iconRotateController.value;
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withValues(alpha: 0.92),
                AppColors.primary900.withValues(alpha: 0.85),
                Colors.black.withValues(alpha: 0.92),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated background particles/sparkles
              ...List.generate(6, (index) {
                final offset = (shimmerValue + index * 0.15) % 1.0;
                final x = 0.1 + (index % 3) * 0.35;
                final y = offset;
                return Positioned(
                  left: MediaQuery.of(context).size.width * x,
                  top: MediaQuery.of(context).size.height * y,
                  child: Opacity(
                    opacity: (sin(offset * 3.14159) * 0.5 + 0.3).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.8 + pulseValue * 0.4,
                      child: Icon(
                        [LucideIcons.sparkles, LucideIcons.star, LucideIcons.wand2][index % 3],
                        size: 16 + (index % 3) * 4,
                        color: AppColors.primary300.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                );
              }),
              
              // Main content
              Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated icon container with glow
                      Transform.scale(
                        scale: 0.95 + pulseValue * 0.1,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary500.withValues(alpha: 0.2),
                                AppColors.primary600.withValues(alpha: 0.1),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.primary400.withValues(alpha: 0.3 + pulseValue * 0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary400.withValues(alpha: 0.2 + pulseValue * 0.15),
                                blurRadius: 30 + pulseValue * 15,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: AppColors.primary300.withValues(alpha: 0.1),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Rotating outer ring
                              Transform.rotate(
                                angle: rotateValue * 2 * 3.14159,
                                child: SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CustomPaint(
                                    painter: _ArcPainter(
                                      color: AppColors.primary400,
                                      strokeWidth: 3,
                                      progress: shimmerValue,
                                    ),
                                  ),
                                ),
                              ),
                              // Inner rotating icon
                              Transform.rotate(
                                angle: -rotateValue * 3.14159,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      AppColors.primary300,
                                      AppColors.primary400,
                                      Colors.white,
                                    ],
                                    stops: [
                                      shimmerValue.clamp(0.0, 0.4),
                                      shimmerValue.clamp(0.3, 0.7),
                                      shimmerValue.clamp(0.6, 1.0),
                                    ],
                                  ).createShader(bounds),
                                  child: const Icon(
                                    LucideIcons.wand2,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Animated title with shimmer
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.white,
                            AppColors.primary300,
                            Colors.white,
                          ],
                          stops: [
                            (shimmerValue - 0.3).clamp(0.0, 1.0),
                            shimmerValue,
                            (shimmerValue + 0.3).clamp(0.0, 1.0),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          '🎨  ${context.l10n.processingMagic}  ✨',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Status pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary400.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary400,
                                value: null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _processingStatus.isNotEmpty ? _processingStatus : context.l10n.processing,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primary300,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Fun phrase with fade animation
                      Builder(
                        builder: (phraseContext) {
                          final funPhrases = _getFunPhrases(phraseContext);
                          final safeIndex = _currentPhraseIndex % funPhrases.length;
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (child, animation) => FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            ),
                            child: Container(
                              key: ValueKey(safeIndex),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.05),
                                    Colors.white.withValues(alpha: 0.02),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Text(
                                funPhrases[safeIndex],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Animated dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final delay = index * 0.2;
                          final dotProgress = ((shimmerValue + delay) % 1.0);
                          final scale = 0.6 + (sin(dotProgress * 3.14159) * 0.4);
                          final opacity = 0.4 + (sin(dotProgress * 3.14159) * 0.6);
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary400.withValues(alpha: opacity),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary400.withValues(alpha: opacity * 0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Custom painter for the rotating arc
class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double progress;

  _ArcPainter({
    required this.color,
    required this.strokeWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    canvas.drawCircle(center, radius, paint);

    // Animated arc
    paint.color = color;
    final sweepAngle = 2.0; // ~120 degrees
    final startAngle = progress * 2 * 3.14159 * 2;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
    
    // Second arc on opposite side
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + 3.14159,
      sweepAngle * 0.7,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
