import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/color_option.dart';

class ColorPaletteModal extends StatefulWidget {
  final Function(ColorOption, String prompt) onColorSelect;

  const ColorPaletteModal({
    super.key,
    required this.onColorSelect,
  });

  @override
  State<ColorPaletteModal> createState() => _ColorPaletteModalState();
}

class _ColorPaletteModalState extends State<ColorPaletteModal> {
  int _activeCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                  'פלטת צבעים',
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

          // Category Tabs
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: ColorPalette.categories.length,
              itemBuilder: (context, index) {
                final category = ColorPalette.categories[index];
                final isActive = index == _activeCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeCategory = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary500
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary400
                              : Colors.white.withValues(alpha: 0.05),
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.primary500.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: category.categoryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isActive ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Color Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: ColorPalette.categories[_activeCategory].colors.length,
              itemBuilder: (context, index) {
                final color = ColorPalette.categories[_activeCategory].colors[index];
                return _buildColorCard(color);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorCard(ColorOption colorOption) {
    return GestureDetector(
      onTap: () => _showColorDialog(colorOption),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorOption.color,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: colorOption.color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6, bottom: 8),
              child: Column(
                children: [
                  Text(
                    colorOption.name,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    colorOption.ral,
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorDialog(ColorOption colorOption) {
    showDialog(
      context: context,
      builder: (dialogContext) => ColorApplicationDialog(
        colorOption: colorOption,
        onApply: (prompt) {
          Navigator.pop(dialogContext); // Close dialog
          Navigator.pop(context); // Close modal
          widget.onColorSelect(colorOption, prompt);
        },
      ),
    );
  }
}

class ColorApplicationDialog extends StatefulWidget {
  final ColorOption colorOption;
  final Function(String) onApply;

  const ColorApplicationDialog({
    super.key,
    required this.colorOption,
    required this.onApply,
  });

  @override
  State<ColorApplicationDialog> createState() => _ColorApplicationDialogState();
}

class _ColorApplicationDialogState extends State<ColorApplicationDialog> {
  String _mode = 'all'; // 'all' or 'custom'
  String _customTarget = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.colorOption.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'שינוי צבע',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Options
            _buildOption(
              value: 'all',
              title: 'כל הקירות',
              subtitle: 'צבע את כל הקירות בחדר',
            ),
            const SizedBox(height: 12),
            _buildOption(
              value: 'custom',
              title: 'אובייקט ספציפי',
              subtitle: 'בחר מה תרצה לצבוע',
            ),

            // Custom target input
            if (_mode == 'custom') ...[
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => setState(() => _customTarget = value),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'לדוגמה: ספה, תקרה, ארון...',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary500.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'ביטול',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: (_mode == 'custom' && _customTarget.trim().isEmpty)
                      ? null
                      : _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary600,
                    disabledBackgroundColor: AppColors.primary600.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('אישור', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 8),
                      Icon(Icons.check, size: 18, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required String value,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _mode == value;
    return GestureDetector(
      onTap: () => setState(() => _mode = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary500.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary500 : Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primary500,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleConfirm() {
    final rgb = widget.colorOption.color;
    final r = (rgb.r * 255).round();
    final g = (rgb.g * 255).round();
    final b = (rgb.b * 255).round();
    final rgbString = 'RGB($r, $g, $b)';
    
    String prompt;
    if (_mode == 'all') {
      prompt = 'Change the color of all walls to ${widget.colorOption.value} (${widget.colorOption.ral}, $rgbString) completely and opaquely, covering the original color entirely';
    } else {
      prompt = 'Paint the $_customTarget in ${widget.colorOption.value} (${widget.colorOption.ral}, $rgbString) color completely and opaquely, covering the original color entirely';
    }
    
    widget.onApply(prompt);
  }
}
