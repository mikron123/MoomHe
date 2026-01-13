import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'app_localizations.dart';
import '../models/prompt_option.dart';
import '../models/style_option.dart';

/// Provides localized prompt options based on the current locale.
/// Prompts remain in English for the AI, only display names are localized.
class LocalizedOptions {
  final AppLocalizations l10n;

  LocalizedOptions(this.l10n);

  /// Get localized design action labels
  List<Map<String, dynamic>> get designActions => [
    {'label': l10n.designStyle, 'icon': LucideIcons.palette, 'action': 'style'},
    {'label': l10n.wallColor, 'icon': LucideIcons.paintbrush, 'action': 'color'},
    {'label': l10n.lighting, 'icon': LucideIcons.lamp, 'action': 'lighting'},
    {'label': l10n.furniture, 'icon': LucideIcons.sofa, 'action': 'furniture'},
    {'label': l10n.doorsWindows, 'icon': LucideIcons.home, 'action': 'doors_windows'},
    {'label': l10n.bathroom, 'icon': LucideIcons.droplets, 'action': 'bathroom'},
    {'label': l10n.repairs, 'icon': LucideIcons.hammer, 'action': 'repairs'},
    {'label': l10n.general, 'icon': LucideIcons.wand2, 'action': 'custom'},
  ];

  /// Get localized fun phrases for processing overlay
  List<String> get funPhrases => [
    l10n.funPhrase1,
    l10n.funPhrase2,
    l10n.funPhrase3,
    l10n.funPhrase4,
    l10n.funPhrase5,
    l10n.funPhrase6,
    l10n.funPhrase7,
    l10n.funPhrase8,
    l10n.funPhrase9,
    l10n.funPhrase10,
    l10n.funPhrase11,
    l10n.funPhrase12,
    l10n.funPhrase13,
    l10n.funPhrase14,
  ];

  /// Get localized lighting options
  List<PromptOption> get lightingOptions => [
    PromptOption(name: l10n.lightingRecessed, value: 'recessed lighting', prompt: l10n.lightingAddRecessed),
    PromptOption(name: l10n.lightingPendant, value: 'pendant lights', prompt: l10n.lightingAddPendant),
    PromptOption(name: l10n.lightingChandelier, value: 'chandeliers', prompt: l10n.lightingAddChandelier),
    PromptOption(name: l10n.lightingTableLamp, value: 'table lamps', prompt: l10n.lightingAddTableLamp),
    PromptOption(name: l10n.lightingFloorLamp, value: 'floor lamps', prompt: l10n.lightingAddFloorLamp),
    PromptOption(name: l10n.lightingWallSconce, value: 'wall sconces', prompt: l10n.lightingAddWallSconce),
    PromptOption(name: l10n.lightingTrack, value: 'track lighting', prompt: l10n.lightingAddTrack),
    PromptOption(name: l10n.lightingCeiling, value: 'ceiling fixtures', prompt: l10n.lightingAddCeiling),
    PromptOption(name: l10n.lightingUnderCabinet, value: 'under-cabinet lighting', prompt: l10n.lightingAddUnderCabinet),
    PromptOption(name: l10n.lightingDecorative, value: 'string lights', prompt: l10n.lightingAddDecorative),
    PromptOption(name: l10n.lightingDay, value: 'day', prompt: l10n.lightingChangeToDay),
    PromptOption(name: l10n.lightingNight, value: 'night', prompt: l10n.lightingChangeToNight),
    PromptOption(name: l10n.lightingSunset, value: 'sunset', prompt: l10n.lightingChangeToSunset),
    PromptOption(name: l10n.lightingSunrise, value: 'sunrise', prompt: l10n.lightingChangeToSunrise),
  ];

  /// Get localized furniture options
  List<PromptOption> get furnitureOptions => [
    PromptOption(name: l10n.furnitureSofa, value: 'sofa', prompt: l10n.furnitureAddSofa),
    PromptOption(name: l10n.furnitureSectional, value: 'sectional sofa', prompt: l10n.furnitureAddSectional),
    PromptOption(name: l10n.furnitureArmchair, value: 'armchair', prompt: l10n.furnitureAddArmchair),
    PromptOption(name: l10n.furnitureAccentChair, value: 'accent chair', prompt: l10n.furnitureAddAccentChair),
    PromptOption(name: l10n.furnitureDiningChair, value: 'dining chair', prompt: l10n.furnitureAddDiningChair),
    PromptOption(name: l10n.furnitureBarStool, value: 'bar stool', prompt: l10n.furnitureAddBarStool),
    PromptOption(name: l10n.furnitureSingleBed, value: 'single bed', prompt: l10n.furnitureAddSingleBed),
    PromptOption(name: l10n.furnitureDoubleBed, value: 'double bed', prompt: l10n.furnitureAddDoubleBed),
    PromptOption(name: l10n.furnitureBeanbag, value: 'beanbag', prompt: l10n.furnitureAddBeanbag),
    PromptOption(name: l10n.furnitureOttoman, value: 'ottoman', prompt: l10n.furnitureAddOttoman),
    PromptOption(name: l10n.furnitureBench, value: 'bench', prompt: l10n.furnitureAddBench),
    PromptOption(name: l10n.furnitureCoffeeTable, value: 'coffee table', prompt: l10n.furnitureAddCoffeeTable),
    PromptOption(name: l10n.furnitureEndTable, value: 'end table', prompt: l10n.furnitureAddEndTable),
    PromptOption(name: l10n.furnitureNightstand, value: 'nightstand', prompt: l10n.furnitureAddNightstand),
    PromptOption(name: l10n.furnitureDiningTable, value: 'dining table', prompt: l10n.furnitureAddDiningTable),
    PromptOption(name: l10n.furnitureDesk, value: 'desk', prompt: l10n.furnitureAddDesk),
    PromptOption(name: l10n.furnitureDresser, value: 'dresser', prompt: l10n.furnitureAddDresser),
    PromptOption(name: l10n.furnitureWardrobe, value: 'wardrobe', prompt: l10n.furnitureAddWardrobe),
    PromptOption(name: l10n.furnitureBookcase, value: 'bookcase', prompt: l10n.furnitureAddBookcase),
    PromptOption(name: l10n.furnitureTvStand, value: 'tv stand', prompt: l10n.furnitureAddTvStand),
    PromptOption(name: l10n.furnitureCabinets, value: 'cabinetry', prompt: l10n.furnitureAddCabinets),
  ];

  /// Get localized repairs options
  List<PromptOption> get repairsOptions => [
    PromptOption(name: l10n.repairsFixEverything, value: 'repair everything', prompt: l10n.repairsRepairAll),
    PromptOption(name: l10n.repairsRepairAll, value: 'fix and repair everything', prompt: l10n.repairsRepairAll),
    PromptOption(name: l10n.repairsMessUp, value: 'mess up everything', prompt: l10n.repairsDestroy),
    PromptOption(name: l10n.repairsDestroy, value: 'destroy and cause damage to everything', prompt: l10n.repairsDestroy),
  ];

  /// Get localized doors and windows options
  List<PromptOptionGroup> get doorsWindowsGroups => [
    PromptOptionGroup(
      title: l10n.windowOptions,
      items: [
        PromptOption(name: l10n.windowPicture, value: 'picture window', prompt: l10n.windowAddPicture, icon: LucideIcons.home),
        PromptOption(name: l10n.windowSliding, value: 'sliding window', prompt: l10n.windowAddSliding, icon: LucideIcons.home),
        PromptOption(name: l10n.windowCasement, value: 'casement window', prompt: l10n.windowAddCasement, icon: LucideIcons.home),
        PromptOption(name: l10n.windowTiltTurn, value: 'tilt and turn window', prompt: l10n.windowAddTiltTurn, icon: LucideIcons.home),
        PromptOption(name: l10n.windowAwning, value: 'awning window', prompt: l10n.windowAddAwning, icon: LucideIcons.home),
        PromptOption(name: l10n.windowSash, value: 'sash window', prompt: l10n.windowAddSash, icon: LucideIcons.home),
        PromptOption(name: l10n.windowPocket, value: 'pocket window', prompt: l10n.windowAddPocket, icon: LucideIcons.home),
        PromptOption(name: l10n.windowArched, value: 'arched window', prompt: l10n.windowAddArched, icon: LucideIcons.home),
      ],
    ),
    PromptOptionGroup(
      title: l10n.doorOptions,
      items: [
        PromptOption(name: l10n.doorPocket, value: 'pocket door', prompt: l10n.doorAddPocket, icon: LucideIcons.home),
        PromptOption(name: l10n.doorFrench, value: 'french doors', prompt: l10n.doorAddFrench, icon: LucideIcons.home),
        PromptOption(name: l10n.doorLouvered, value: 'louvered door', prompt: l10n.doorAddLouvered, icon: LucideIcons.home),
        PromptOption(name: l10n.doorBarn, value: 'barn door', prompt: l10n.doorAddBarn, icon: LucideIcons.home),
      ],
    ),
  ];

  /// Get localized bathroom options
  List<PromptOptionGroup> get bathroomGroups => [
    PromptOptionGroup(
      title: l10n.toiletOptions,
      items: [
        PromptOption(name: l10n.toiletBidet, value: 'bidet toilet', prompt: l10n.toiletAddBidet, icon: LucideIcons.droplets),
        PromptOption(name: l10n.toiletSeat, value: 'toilet seat', prompt: l10n.toiletAddSeat, icon: LucideIcons.droplets),
      ],
    ),
    PromptOptionGroup(
      title: l10n.bathtubOptions,
      items: [
        PromptOption(name: l10n.tubFreestanding, value: 'freestanding tub', prompt: l10n.tubAddFreestanding, icon: LucideIcons.droplets),
        PromptOption(name: l10n.tubVintage, value: 'vintage tub', prompt: l10n.tubAddVintage, icon: LucideIcons.droplets),
        PromptOption(name: l10n.tubStandard, value: 'standard tub', prompt: l10n.tubAddStandard, icon: LucideIcons.droplets),
      ],
    ),
    PromptOptionGroup(
      title: l10n.showerOptions,
      items: [
        PromptOption(name: l10n.showerRain, value: 'rain shower', prompt: l10n.showerAddRain, icon: LucideIcons.droplets),
        PromptOption(name: l10n.showerEnclosure, value: 'shower enclosure', prompt: l10n.showerAddEnclosure, icon: LucideIcons.droplets),
        PromptOption(name: l10n.showerSliding, value: 'sliding shower doors', prompt: l10n.showerAddSliding, icon: LucideIcons.droplets),
      ],
    ),
    PromptOptionGroup(
      title: l10n.sinkOptions,
      items: [
        PromptOption(name: l10n.sinkPedestal, value: 'pedestal sink', prompt: l10n.sinkAddPedestal, icon: LucideIcons.droplets),
        PromptOption(name: l10n.sinkStainless, value: 'stainless steel sink', prompt: l10n.sinkAddStainless, icon: LucideIcons.droplets),
        PromptOption(name: l10n.sinkUndermount, value: 'undermount sink', prompt: l10n.sinkAddUndermount, icon: LucideIcons.droplets),
      ],
    ),
    PromptOptionGroup(
      title: l10n.jacuzziOptions,
      items: [
        PromptOption(name: l10n.jacuzziBuiltIn, value: 'built-in jacuzzi', prompt: l10n.jacuzziAddBuiltIn, icon: LucideIcons.droplets),
        PromptOption(name: l10n.jacuzziPortable, value: 'portable jacuzzi', prompt: l10n.jacuzziAddPortable, icon: LucideIcons.droplets),
      ],
    ),
    PromptOptionGroup(
      title: l10n.poolOptions,
      items: [
        PromptOption(name: l10n.poolInground, value: 'inground pool', prompt: l10n.poolAddInground, icon: LucideIcons.droplets),
        PromptOption(name: l10n.poolAboveGround, value: 'above ground pool', prompt: l10n.poolAddAboveGround, icon: LucideIcons.droplets),
      ],
    ),
  ];

  /// Get localized style options
  /// Note: Style prompts use detailed English instructions for optimal AI results
  /// since style selection triggers processing immediately.
  List<StyleOption> get interiorStyles => [
    StyleOption(
      name: l10n.styleMediterranean,
      value: 'mediterranean-modern',
      thumbnail: 'assets/styles/mediterranean.png',
      prompt: 'Transform this room into a Modern Mediterranean interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Use natural materials like Jerusalem stone walls, terracotta tiles, and light oak wood flooring.',
    ),
    StyleOption(
      name: l10n.styleWarmMinimalism,
      value: 'warm-minimalism',
      thumbnail: 'assets/styles/warm-minimalism.jpg',
      prompt: 'Transform this room into Warm Minimalism interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Keep the space clean and uncluttered but add warmth through natural materials.',
    ),
    StyleOption(
      name: l10n.styleBiophilic,
      value: 'biophilic',
      thumbnail: 'assets/styles/biophilic.jpg',
      prompt: 'Transform this room into Biophilic interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create a strong connection to nature inside the home.',
    ),
    StyleOption(
      name: l10n.styleModernLuxury,
      value: 'modern-luxury',
      thumbnail: 'assets/styles/modern-luxury.jpg',
      prompt: 'Transform this room into Modern Luxury interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create an elegant and sophisticated high-end space.',
    ),
    StyleOption(
      name: l10n.styleJapandi,
      value: 'japandi',
      thumbnail: 'assets/styles/japandi.jpg',
      prompt: 'Transform this room into Japandi interior design style - a fusion of Japanese and Scandinavian aesthetics. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image.',
    ),
    StyleOption(
      name: l10n.styleScandinavian,
      value: 'scandinavian',
      thumbnail: 'assets/styles/scandinavian.jpg',
      prompt: 'Transform this room into Scandinavian interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Use a bright, airy color palette dominated by white and light gray walls.',
    ),
    StyleOption(
      name: l10n.styleBohoChic,
      value: 'boho-chic',
      thumbnail: 'assets/styles/boho.jpg',
      prompt: 'Transform this room into Bohemian Chic interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create an eclectic, artistic, and free-spirited space.',
    ),
    StyleOption(
      name: l10n.styleIndustrial,
      value: 'industrial',
      thumbnail: 'assets/styles/industrial.jpg',
      prompt: 'Transform this room into Industrial interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Expose raw architectural elements.',
    ),
    StyleOption(
      name: l10n.styleEarthyNatural,
      value: 'earthy-natural',
      thumbnail: 'assets/styles/earthy-natural.jpg',
      prompt: 'Transform this room into Earthy Natural interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create a grounded, organic, and serene space connected to nature.',
    ),
    StyleOption(
      name: l10n.styleJerusalem,
      value: 'jerusalem',
      thumbnail: 'assets/styles/jerusalem.jpg',
      prompt: 'Transform this room into Contemporary Israeli interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create a bright, modern space that reflects Mediterranean living.',
    ),
    StyleOption(
      name: l10n.styleMinimalist,
      value: 'minimalist',
      thumbnail: 'assets/styles/minimalist.jpg',
      prompt: 'Transform this room into Minimalist interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create a clean, uncluttered, and intentional space.',
    ),
    StyleOption(
      name: l10n.styleModernClassic,
      value: 'modern-classic',
      thumbnail: 'assets/styles/modern-classic.jpg',
      prompt: 'Transform this room into Modern Classic interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Blend timeless elegance with contemporary comfort.',
    ),
  ];

  /// Get localized color category names
  List<String> get colorCategoryNames => [
    l10n.colorCategoryReds,
    l10n.colorCategoryOranges,
    l10n.colorCategoryYellows,
    l10n.colorCategoryGreens,
    l10n.colorCategoryBlues,
    l10n.colorCategoryPurples,
    l10n.colorCategoryGrays,
    l10n.colorCategoryWhitesBlacks,
  ];
}

/// Extension to easily get localized options from BuildContext
extension LocalizedOptionsExtension on BuildContext {
  LocalizedOptions get localizedOptions {
    final l10n = AppLocalizations.of(this)!;
    return LocalizedOptions(l10n);
  }
  
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
