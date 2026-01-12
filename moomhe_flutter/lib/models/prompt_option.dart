import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Represents a prompt option with name, value, and prompt text
class PromptOption {
  final String name;
  final String value;
  final String prompt;
  final IconData? icon;

  const PromptOption({
    required this.name,
    required this.value,
    required this.prompt,
    this.icon,
  });
}

/// Represents a group of prompt options (for categorized modals)
class PromptOptionGroup {
  final String title;
  final List<PromptOption> items;

  const PromptOptionGroup({
    required this.title,
    required this.items,
  });
}

/// Lighting options from web version
class LightingOptions {
  static const List<PromptOption> options = [
    PromptOption(name: 'תאורה מוסתרת', value: 'recessed lighting', prompt: 'הוסף תאורה מוסתרת'),
    PromptOption(name: 'נברשת', value: 'pendant lights', prompt: 'הוסף נברשת'),
    PromptOption(name: 'נברשת גדולה', value: 'chandeliers', prompt: 'הוסף נברשת גדולה'),
    PromptOption(name: 'מנורת שולחן', value: 'table lamps', prompt: 'הוסף מנורת שולחן'),
    PromptOption(name: 'מנורת רצפה', value: 'floor lamps', prompt: 'הוסף מנורת רצפה'),
    PromptOption(name: 'מנורת קיר', value: 'wall sconces', prompt: 'הוסף מנורת קיר'),
    PromptOption(name: 'תאורת מסילה', value: 'track lighting', prompt: 'הוסף תאורת מסילה'),
    PromptOption(name: 'תאורת תקרה', value: 'ceiling fixtures', prompt: 'הוסף תאורת תקרה'),
    PromptOption(name: 'תאורת מטבח', value: 'under-cabinet lighting', prompt: 'הוסף תאורת מטבח'),
    PromptOption(name: 'תאורה דקורטיבית', value: 'string lights', prompt: 'הוסף תאורה דקורטיבית'),
    PromptOption(name: 'יום', value: 'day', prompt: 'שנה את התאורה לתאורת יום'),
    PromptOption(name: 'לילה', value: 'night', prompt: 'שנה את התאורה לתאורת לילה'),
    PromptOption(name: 'שקיעה', value: 'sunset', prompt: 'שנה את התאורה לתאורת שקיעה'),
    PromptOption(name: 'זריחה', value: 'sunrise', prompt: 'שנה את התאורה לתאורת זריחה'),
  ];
}

/// Furniture options from web version
class FurnitureOptions {
  static const List<PromptOption> options = [
    PromptOption(name: 'ספה', value: 'sofa', prompt: 'הוסף ספה'),
    PromptOption(name: 'ספה פינתית', value: 'sectional sofa', prompt: 'הוסף ספה פינתית'),
    PromptOption(name: 'כורסא', value: 'armchair', prompt: 'הוסף כורסא'),
    PromptOption(name: 'כיסא דקורטיבי', value: 'accent chair', prompt: 'הוסף כיסא דקורטיבי'),
    PromptOption(name: 'כיסא אוכל', value: 'dining chair', prompt: 'הוסף כיסא אוכל'),
    PromptOption(name: 'שרפרף', value: 'bar stool', prompt: 'הוסף שרפרף'),
    PromptOption(name: 'מיטה יחידה', value: 'single bed', prompt: 'הוסף מיטה יחידה'),
    PromptOption(name: 'מיטה זוגית', value: 'double bed', prompt: 'הוסף מיטה זוגית'),
    PromptOption(name: 'פוף', value: 'beanbag', prompt: 'הוסף פוף'),
    PromptOption(name: 'הדום', value: 'ottoman', prompt: 'הוסף הדום'),
    PromptOption(name: 'ספסל', value: 'bench', prompt: 'הוסף ספסל'),
    PromptOption(name: 'שולחן קפה', value: 'coffee table', prompt: 'הוסף שולחן קפה'),
    PromptOption(name: 'שולחן צד', value: 'end table', prompt: 'הוסף שולחן צד'),
    PromptOption(name: 'שולחן לילה', value: 'nightstand', prompt: 'הוסף שולחן לילה'),
    PromptOption(name: 'שולחן אוכל', value: 'dining table', prompt: 'הוסף שולחן אוכל'),
    PromptOption(name: 'שולחן עבודה', value: 'desk', prompt: 'הוסף שולחן עבודה'),
    PromptOption(name: 'שידה', value: 'dresser', prompt: 'הוסף שידה'),
    PromptOption(name: 'ארון בגדים', value: 'wardrobe', prompt: 'הוסף ארון בגדים'),
    PromptOption(name: 'מדף ספרים', value: 'bookcase', prompt: 'הוסף מדף ספרים'),
    PromptOption(name: 'עמדת טלוויזיה', value: 'tv stand', prompt: 'הוסף עמדת טלוויזיה'),
    PromptOption(name: 'ארונות מטבח', value: 'cabinetry', prompt: 'הוסף ארונות מטבח'),
  ];
}

/// Repairs options from web version
class RepairsOptions {
  static const List<PromptOption> options = [
    PromptOption(name: 'בצע תיקונים להכל', value: 'repair everything', prompt: 'בצע תיקונים להכל'),
    PromptOption(name: 'תסדר ותקנה את הכל', value: 'fix and repair everything', prompt: 'תסדר ותקנה את הכל'),
    PromptOption(name: 'תבלגן את הכל', value: 'mess up everything', prompt: 'תבלגן את הכל'),
    PromptOption(name: 'תהרוס ותגרום נזקים להכל', value: 'destroy and cause damage to everything', prompt: 'תהרוס ותגרום נזקים להכל'),
  ];
}

/// Doors and Windows options from web version (grouped)
class DoorsWindowsOptions {
  static const List<PromptOptionGroup> groups = [
    PromptOptionGroup(
      title: 'אפשרויות חלונות',
      items: [
        PromptOption(name: 'חלון קבוע', value: 'picture window', prompt: 'הוסף חלון תמונה גדול עם נוף קבוע', icon: LucideIcons.home),
        PromptOption(name: 'חלון הזזה', value: 'sliding window', prompt: 'הוסף חלון הזזה', icon: LucideIcons.home),
        PromptOption(name: 'חלון כנף', value: 'casement window', prompt: 'הוסף חלון כנף', icon: LucideIcons.home),
        PromptOption(name: 'חלון דריי-קיפ', value: 'tilt and turn window', prompt: 'הוסף חלון דריי-קיפ (הטיה ופתיחה)', icon: LucideIcons.home),
        PromptOption(name: 'חלון ציר עליון', value: 'awning window', prompt: 'הוסף חלון ציר עליון (אוונינג)', icon: LucideIcons.home),
        PromptOption(name: 'חלון גליוטינה', value: 'sash window', prompt: 'הוסף חלון גליוטינה', icon: LucideIcons.home),
        PromptOption(name: 'חלון כיס', value: 'pocket window', prompt: 'הוסף חלון כיס', icon: LucideIcons.home),
        PromptOption(name: 'חלון קשת', value: 'arched window', prompt: 'הוסף חלון קשת שמגדיל את החלל', icon: LucideIcons.home),
      ],
    ),
    PromptOptionGroup(
      title: 'אפשרויות דלתות',
      items: [
        PromptOption(name: 'דלת כיס', value: 'pocket door', prompt: 'הוסף דלת כיס שנכנסת לתוך הקיר', icon: LucideIcons.home),
        PromptOption(name: 'דלתות צרפתיות', value: 'french doors', prompt: 'הוסף דלתות צרפתיות עם זכוכית', icon: LucideIcons.home),
        PromptOption(name: 'דלת לובר', value: 'louvered door', prompt: 'הוסף דלת לובר עם סורגים לאוורור', icon: LucideIcons.home),
        PromptOption(name: 'דלת אסם', value: 'barn door', prompt: 'הוסף דלת אסם עם מסילה גלויה', icon: LucideIcons.home),
      ],
    ),
  ];
}

/// Bathroom options from web version (grouped)
class BathroomOptions {
  static const List<PromptOptionGroup> groups = [
    PromptOptionGroup(
      title: 'אפשרויות אסלה',
      items: [
        PromptOption(name: 'בידה מחומם', value: 'bidet toilet', prompt: 'הוסף מושב אסלה עם בידה', icon: LucideIcons.droplets),
        PromptOption(name: 'מושב אסלה', value: 'toilet seat', prompt: 'הוסף מושב אסלה', icon: LucideIcons.droplets),
      ],
    ),
    PromptOptionGroup(
      title: 'אפשרויות אמבטיה',
      items: [
        PromptOption(name: 'אמבטיה עומדת', value: 'freestanding tub', prompt: 'הוסף אמבטיה עומדת', icon: LucideIcons.droplets),
        PromptOption(name: 'אמבטיה וינטג', value: 'vintage tub', prompt: 'הוסף אמבטיית vintage', icon: LucideIcons.droplets),
        PromptOption(name: 'אמבטיה סטנדרטית', value: 'standard tub', prompt: 'הוסף אמבטיה סטנדרטית', icon: LucideIcons.droplets),
      ],
    ),
    PromptOptionGroup(
      title: 'אפשרויות מקלחת',
      items: [
        PromptOption(name: 'מקלחת גשם', value: 'rain shower', prompt: 'הוסף מקלחת עם מערכת ראש גשם', icon: LucideIcons.droplets),
        PromptOption(name: 'מקלחון', value: 'shower enclosure', prompt: 'הוסף מקלחון', icon: LucideIcons.droplets),
        PromptOption(name: 'מקלחת דלתות', value: 'sliding shower doors', prompt: 'הוסף מקלחון עם דלתות הזזה', icon: LucideIcons.droplets),
      ],
    ),
    PromptOptionGroup(
      title: 'אפשרויות כיור',
      items: [
        PromptOption(name: 'כיור עמוד', value: 'pedestal sink', prompt: 'הוסף כיור עמוד בסגנון קלאסי', icon: LucideIcons.droplets),
        PromptOption(name: 'כיור נירוסטה', value: 'stainless steel sink', prompt: 'הוסף כיור נירוסטה', icon: LucideIcons.droplets),
        PromptOption(name: 'כיור מובנה', value: 'undermount sink', prompt: 'הוסף כיור מובנה קרמי לבן', icon: LucideIcons.droplets),
      ],
    ),
    PromptOptionGroup(
      title: "אפשרויות ג'קוזי/ספא",
      items: [
        PromptOption(name: "ג'קוזי מובנה", value: 'built-in jacuzzi', prompt: "הוסף ג'קוזי מובנה עם אריחים", icon: LucideIcons.droplets),
        PromptOption(name: "ג'קוזי נייד", value: 'portable jacuzzi', prompt: 'הוסף ג׳קוזי סטנדרטי', icon: LucideIcons.droplets),
      ],
    ),
    PromptOptionGroup(
      title: 'אפשרויות בריכה',
      items: [
        PromptOption(name: 'בריכה בתוך הקרקע', value: 'inground pool', prompt: 'הוסף בריכה בתוך הקרקע מבטון מותאמת אישית', icon: LucideIcons.droplets),
        PromptOption(name: 'בריכה מעל הקרקע', value: 'above ground pool', prompt: 'הוסף בריכה מעל הקרקע עם מסגרת מתכת', icon: LucideIcons.droplets),
      ],
    ),
  ];
}
