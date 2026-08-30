import 'dart:convert';
import 'cup_preset.dart';

class CupStockItem {
  final CupPreset preset;
  double yesterdayStock;
  double operatingUnits;
  double currentStock;

  CupStockItem({
    required this.preset,
    this.yesterdayStock = 0.0,
    this.operatingUnits = 0.0,
    this.currentStock = 0.0,
  });

  // Equation 1: Actual Consumption = Yesterday's Stock - Current Stock
  double get actualConsumption => yesterdayStock - currentStock;

  // Equation 2: Variance / Discrepancy = Actual Consumption - Operating Units
  double get variance => actualConsumption - operatingUnits;

  // Low stock threshold condition check
  bool get isLowStock => currentStock <= preset.lowStockThreshold;

  Map<String, dynamic> toMap() {
    return {
      'preset': preset.toMap(),
      'yesterday_stock': yesterdayStock,
      'operating_units': operatingUnits,
      'current_stock': currentStock,
      'actual_consumption': actualConsumption,
      'variance': variance,
      'is_low_stock': isLowStock ? 1 : 0,
    };
  }

  factory CupStockItem.fromMap(Map<String, dynamic> map) {
    return CupStockItem(
      preset: CupPreset.fromMap(map['preset'] as Map<String, dynamic>),
      yesterdayStock: (map['yesterday_stock'] as num).toDouble(),
      operatingUnits: (map['operating_units'] as num).toDouble(),
      currentStock: (map['current_stock'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CupStockItem.fromJson(String source) =>
      CupStockItem.fromMap(json.decode(source) as Map<String, dynamic>);
}
