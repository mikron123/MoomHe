import 'package:flutter/material.dart';

class ColorOption {
  final String name;
  final String value;
  final String hex;
  final String ral;

  const ColorOption({
    required this.name,
    required this.value,
    required this.hex,
    required this.ral,
  });

  Color get color => Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
}

class ColorCategory {
  final String name;
  final String categoryHex;
  final List<ColorOption> colors;

  const ColorCategory({
    required this.name,
    required this.categoryHex,
    required this.colors,
  });

  Color get categoryColor => Color(int.parse(categoryHex.substring(1), radix: 16) + 0xFF000000);
}

class ColorPalette {
  static const List<ColorCategory> categories = [
    ColorCategory(
      name: 'אדומים',
      categoryHex: '#C1121C',
      colors: [
        ColorOption(name: 'Flame red', value: 'flame red', hex: '#C1121C', ral: 'RAL 3000'),
        ColorOption(name: 'Signal red', value: 'signal red', hex: '#A52019', ral: 'RAL 3001'),
        ColorOption(name: 'Carmine red', value: 'carmine red', hex: '#A2231D', ral: 'RAL 3002'),
        ColorOption(name: 'Ruby red', value: 'ruby red', hex: '#9B111E', ral: 'RAL 3003'),
        ColorOption(name: 'Wine red', value: 'wine red', hex: '#5E2129', ral: 'RAL 3005'),
        ColorOption(name: 'Coral red', value: 'coral red', hex: '#B32821', ral: 'RAL 3016'),
        ColorOption(name: 'Traffic red', value: 'traffic red', hex: '#CC0605', ral: 'RAL 3020'),
        ColorOption(name: 'Light pink', value: 'light pink', hex: '#EA899A', ral: 'RAL 3015'),
      ],
    ),
    ColorCategory(
      name: 'כתומים',
      categoryHex: '#FF7514',
      colors: [
        ColorOption(name: 'Red orange', value: 'red orange', hex: '#C93C20', ral: 'RAL 2001'),
        ColorOption(name: 'Vermilion', value: 'vermilion', hex: '#CB2821', ral: 'RAL 2002'),
        ColorOption(name: 'Pastel orange', value: 'pastel orange', hex: '#FF7514', ral: 'RAL 2003'),
        ColorOption(name: 'Pure orange', value: 'pure orange', hex: '#F44611', ral: 'RAL 2004'),
        ColorOption(name: 'Traffic orange', value: 'traffic orange', hex: '#F54021', ral: 'RAL 2009'),
        ColorOption(name: 'Deep orange', value: 'deep orange', hex: '#EC7C26', ral: 'RAL 2011'),
      ],
    ),
    ColorCategory(
      name: 'צהובים',
      categoryHex: '#E5BE01',
      colors: [
        ColorOption(name: 'Beige', value: 'beige', hex: '#C2B078', ral: 'RAL 1001'),
        ColorOption(name: 'Sand yellow', value: 'sand yellow', hex: '#C6A664', ral: 'RAL 1002'),
        ColorOption(name: 'Signal yellow', value: 'signal yellow', hex: '#E5BE01', ral: 'RAL 1003'),
        ColorOption(name: 'Golden yellow', value: 'golden yellow', hex: '#CDA434', ral: 'RAL 1004'),
        ColorOption(name: 'Honey yellow', value: 'honey yellow', hex: '#A98307', ral: 'RAL 1005'),
        ColorOption(name: 'Lemon yellow', value: 'lemon yellow', hex: '#C7B446', ral: 'RAL 1012'),
        ColorOption(name: 'Ivory', value: 'ivory', hex: '#E1CC4F', ral: 'RAL 1014'),
        ColorOption(name: 'Sun yellow', value: 'sun yellow', hex: '#F39F18', ral: 'RAL 1037'),
      ],
    ),
    ColorCategory(
      name: 'ירוקים',
      categoryHex: '#287233',
      colors: [
        ColorOption(name: 'Patina green', value: 'patina green', hex: '#316650', ral: 'RAL 6000'),
        ColorOption(name: 'Emerald green', value: 'emerald green', hex: '#287233', ral: 'RAL 6001'),
        ColorOption(name: 'Leaf green', value: 'leaf green', hex: '#2D572C', ral: 'RAL 6002'),
        ColorOption(name: 'Olive green', value: 'olive green', hex: '#424632', ral: 'RAL 6003'),
        ColorOption(name: 'Moss green', value: 'moss green', hex: '#2F4538', ral: 'RAL 6005'),
        ColorOption(name: 'Pastel green', value: 'pastel green', hex: '#BDECB6', ral: 'RAL 6019'),
        ColorOption(name: 'Mint green', value: 'mint green', hex: '#20603D', ral: 'RAL 6029'),
      ],
    ),
    ColorCategory(
      name: 'כחולים',
      categoryHex: '#1E2460',
      colors: [
        ColorOption(name: 'Violet blue', value: 'violet blue', hex: '#354D73', ral: 'RAL 5000'),
        ColorOption(name: 'Ultramarine blue', value: 'ultramarine blue', hex: '#20214F', ral: 'RAL 5002'),
        ColorOption(name: 'Signal blue', value: 'signal blue', hex: '#1E2460', ral: 'RAL 5005'),
        ColorOption(name: 'Brillant blue', value: 'brillant blue', hex: '#3E5F8A', ral: 'RAL 5007'),
        ColorOption(name: 'Light blue', value: 'light blue', hex: '#3B83BD', ral: 'RAL 5012'),
        ColorOption(name: 'Sky blue', value: 'sky blue', hex: '#2271B3', ral: 'RAL 5015'),
        ColorOption(name: 'Turquoise blue', value: 'turquoise blue', hex: '#3F888F', ral: 'RAL 5018'),
        ColorOption(name: 'Pastel blue', value: 'pastel blue', hex: '#5D9B9B', ral: 'RAL 5024'),
      ],
    ),
    ColorCategory(
      name: 'סגולים',
      categoryHex: '#6D3F5B',
      colors: [
        ColorOption(name: 'Red lilac', value: 'red lilac', hex: '#6D3F5B', ral: 'RAL 4001'),
        ColorOption(name: 'Red violet', value: 'red violet', hex: '#922B3E', ral: 'RAL 4002'),
        ColorOption(name: 'Heather violet', value: 'heather violet', hex: '#DE4C8A', ral: 'RAL 4003'),
        ColorOption(name: 'Blue lilac', value: 'blue lilac', hex: '#6C4675', ral: 'RAL 4005'),
        ColorOption(name: 'Traffic purple', value: 'traffic purple', hex: '#A03472', ral: 'RAL 4006'),
        ColorOption(name: 'Signal violet', value: 'signal violet', hex: '#924E7D', ral: 'RAL 4008'),
        ColorOption(name: 'Telemagenta', value: 'telemagenta', hex: '#CF3476', ral: 'RAL 4010'),
      ],
    ),
    ColorCategory(
      name: 'אפורים',
      categoryHex: '#78858B',
      colors: [
        ColorOption(name: 'Silver grey', value: 'silver grey', hex: '#8A9597', ral: 'RAL 7001'),
        ColorOption(name: 'Signal grey', value: 'signal grey', hex: '#969992', ral: 'RAL 7004'),
        ColorOption(name: 'Anthracite grey', value: 'anthracite grey', hex: '#293133', ral: 'RAL 7016'),
        ColorOption(name: 'Concrete grey', value: 'concrete grey', hex: '#686C5E', ral: 'RAL 7023'),
        ColorOption(name: 'Stone grey', value: 'stone grey', hex: '#8B8C7A', ral: 'RAL 7030'),
        ColorOption(name: 'Light grey', value: 'light grey', hex: '#D7D7D7', ral: 'RAL 7035'),
        ColorOption(name: 'Platinum grey', value: 'platinum grey', hex: '#7F7679', ral: 'RAL 7036'),
      ],
    ),
    ColorCategory(
      name: 'לבנים ושחורים',
      categoryHex: '#F4F4F4',
      colors: [
        ColorOption(name: 'Cream', value: 'cream', hex: '#FDF4E3', ral: 'RAL 9001'),
        ColorOption(name: 'Grey white', value: 'grey white', hex: '#E7EBDA', ral: 'RAL 9002'),
        ColorOption(name: 'Signal white', value: 'signal white', hex: '#F4F4F4', ral: 'RAL 9003'),
        ColorOption(name: 'Simply white', value: 'simply white', hex: '#FFFFFF', ral: 'RAL 9010'),
        ColorOption(name: 'Signal black', value: 'signal black', hex: '#282828', ral: 'RAL 9004'),
        ColorOption(name: 'Jet black', value: 'jet black', hex: '#0A0A0A', ral: 'RAL 9005'),
        ColorOption(name: 'Traffic black', value: 'traffic black', hex: '#1E1E1E', ral: 'RAL 9017'),
      ],
    ),
  ];
}
