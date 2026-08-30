import 'dart:convert';

class CupPreset {
  final int? id;
  final double ounces;
  final double milliliters;
  final String nameAr;
  final String nameEn;
  final bool isCustom;
  final double lowStockThreshold; // Treshold alert limit

  CupPreset({
    this.id,
    required this.ounces,
    required this.milliliters,
    required this.nameAr,
    required this.nameEn,
    this.isCustom = false,
    this.lowStockThreshold = 20.0,
  });

  // Returns dual-unit display label e.g., "4 oz (120 ml)"
  String get displayLabel {
    final ozStr = ounces.toStringAsFixed(0).replaceAll(RegExp(r'\.0$'), '');
    final mlStr = milliliters.toStringAsFixed(0).replaceAll(RegExp(r'\.0$'), '');
    return "$ozStr oz ($mlStr ml)";
  }

  // Returns localized title
  String getLocalizedName(String langCode) {
    if (langCode == 'ar') {
      return "$nameAr $displayLabel";
    }
    return "$nameEn $displayLabel";
  }

  // Built-in default cup presets strictly adhering to requirements
  static List<CupPreset> get defaultPresets => [
        CupPreset(
          ounces: 4,
          milliliters: 120,
          nameAr: "كوب صغيراً جداً",
          nameEn: "Extra Small Cup",
          lowStockThreshold: 15,
        ),
        CupPreset(
          ounces: 7,
          milliliters: 200,
          nameAr: "كوب صغير",
          nameEn: "Small Cup",
          lowStockThreshold: 20,
        ),
        CupPreset(
          ounces: 8,
          milliliters: 240,
          nameAr: "كوب وسط",
          nameEn: "Medium Cup",
          lowStockThreshold: 25,
        ),
        CupPreset(
          ounces: 12,
          milliliters: 355,
          nameAr: "كوب كبير",
          nameEn: "Large Cup",
          lowStockThreshold: 30,
        ),
        CupPreset(
          ounces: 16,
          milliliters: 475,
          nameAr: "كوب كبير جداً",
          nameEn: "Extra Large Cup",
          lowStockThreshold: 35,
        ),
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ounces': ounces,
      'milliliters': milliliters,
      'name_ar': nameAr,
      'name_en': nameEn,
      'is_custom': isCustom ? 1 : 0,
      'low_stock_threshold': lowStockThreshold,
    };
  }

  factory CupPreset.fromMap(Map<String, dynamic> map) {
    return CupPreset(
      id: map['id'] as int?,
      ounces: (map['ounces'] as num).toDouble(),
      milliliters: (map['milliliters'] as num).toDouble(),
      nameAr: map['name_ar'] as String,
      nameEn: map['name_en'] as String,
      isCustom: (map['is_custom'] as int?) == 1,
      lowStockThreshold: (map['low_stock_threshold'] as num?)?.toDouble() ?? 20.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory CupPreset.fromJson(String source) =>
      CupPreset.fromMap(json.decode(source) as Map<String, dynamic>);
}
