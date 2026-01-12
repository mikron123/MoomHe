class StyleOption {
  final String name;
  final String value;
  final String? thumbnail;
  final String prompt;

  const StyleOption({
    required this.name,
    required this.value,
    this.thumbnail,
    required this.prompt,
  });

  static const List<StyleOption> interiorStyles = [
    StyleOption(
      name: 'ים תיכוני מודרני',
      value: 'mediterranean-modern',
      thumbnail: 'assets/styles/mediterranean.png',
      prompt: 'Transform this room into a Modern Mediterranean interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Use natural materials like Jerusalem stone walls, terracotta tiles, and light oak wood flooring.',
    ),
    StyleOption(
      name: 'מינימליזם חם',
      value: 'warm-minimalism',
      thumbnail: 'assets/styles/warm-minimalism.jpg',
      prompt: 'Transform this room into Warm Minimalism interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Keep the space clean and uncluttered but add warmth through natural materials.',
    ),
    StyleOption(
      name: 'ביופילי',
      value: 'biophilic',
      thumbnail: 'assets/styles/biophilic.jpg',
      prompt: 'Transform this room into Biophilic interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create a strong connection to nature inside the home.',
    ),
    StyleOption(
      name: 'מודרני יוקרתי',
      value: 'modern-luxury',
      thumbnail: 'assets/styles/modern-luxury.jpg',
      prompt: 'Transform this room into Modern Luxury interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create an elegant and sophisticated high-end space.',
    ),
    StyleOption(
      name: 'יפנדי',
      value: 'japandi',
      thumbnail: 'assets/styles/japandi.jpg',
      prompt: 'Transform this room into Japandi interior design style - a fusion of Japanese and Scandinavian aesthetics. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image.',
    ),
    StyleOption(
      name: 'סקנדינבי',
      value: 'scandinavian',
      thumbnail: 'assets/styles/scandinavian.jpg',
      prompt: 'Transform this room into Scandinavian interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Use a bright, airy color palette dominated by white and light gray walls.',
    ),
    StyleOption(
      name: 'בוהו שיק',
      value: 'boho-chic',
      thumbnail: 'assets/styles/boho.jpg',
      prompt: 'Transform this room into Bohemian Chic interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create an eclectic, artistic, and free-spirited space.',
    ),
    StyleOption(
      name: 'אינדוסטריאלי',
      value: 'industrial',
      thumbnail: 'assets/styles/industrial.jpg',
      prompt: 'Transform this room into Industrial interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Expose raw architectural elements.',
    ),
    StyleOption(
      name: 'טבעי וארצי',
      value: 'earthy-natural',
      thumbnail: 'assets/styles/earthy-natural.jpg',
      prompt: 'Transform this room into Earthy Natural interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create a grounded, organic, and serene space connected to nature.',
    ),
    StyleOption(
      name: 'ירושלמי',
      value: 'jerusalem',
      thumbnail: 'assets/styles/jerusalem.jpg',
      prompt: 'Transform this room into Contemporary Israeli interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create a bright, modern space that reflects Mediterranean living.',
    ),
    StyleOption(
      name: 'מינימליסטי',
      value: 'minimalist',
      thumbnail: 'assets/styles/minimalist.jpg',
      prompt: 'Transform this room into Minimalist interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Create a clean, uncluttered, and intentional space.',
    ),
    StyleOption(
      name: 'קלאסי עדכני',
      value: 'modern-classic',
      thumbnail: 'assets/styles/modern-classic.jpg',
      prompt: 'Transform this room into Modern Classic interior design style. CRITICAL: Preserve the exact room structure. Keep all existing windows and doors in their original positions and sizes. NEVER add new doors or windows - only redesign what already exists in the image. Blend timeless elegance with contemporary comfort.',
    ),
  ];
}
