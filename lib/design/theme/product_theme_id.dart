/// Stable product theme identifiers — persisted in Settings.
///
/// Suitable for future themes beyond Default and Vintage Diary.
enum ProductThemeId {
  /// Neutral black/white Quiet — fresh-install default.
  quietDefault('default', 'Default'),

  /// Vintage Diary parchment experience.
  vintageDiary('vintage_diary', 'Vintage Diary'),

  /// Neon Arcade — cool cream canvas, magenta/cyan HUD chrome.
  neonArcade('neon_arcade', 'Neon Arcade');

  const ProductThemeId(this.storageKey, this.label);

  /// Value stored in SQLite `settings.product_theme`.
  final String storageKey;

  /// Human-readable Settings label.
  final String label;

  static ProductThemeId fromStorage(String? value) {
    if (value == null || value.isEmpty) return ProductThemeId.quietDefault;
    for (final id in ProductThemeId.values) {
      if (id.storageKey == value) return id;
    }
    return ProductThemeId.quietDefault;
  }
}
