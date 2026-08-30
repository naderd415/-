import 'dart:convert';
import 'cup_stock_item.dart';

class StockRecord {
  final int? id;
  final String date; // YYYY-MM-DD
  final List<CupStockItem> items;
  final String notes;

  StockRecord({
    this.id,
    required this.date,
    required this.items,
    this.notes = '',
  });

  // Aggregated totals across all cup sizes
  double get totalYesterdayStock =>
      items.fold(0.0, (sum, item) => sum + item.yesterdayStock);

  double get totalOperatingUnits =>
      items.fold(0.0, (sum, item) => sum + item.operatingUnits);

  double get totalCurrentStock =>
      items.fold(0.0, (sum, item) => sum + item.currentStock);

  double get totalActualConsumption =>
      items.fold(0.0, (sum, item) => sum + item.actualConsumption);

  double get totalVariance =>
      items.fold(0.0, (sum, item) => sum + item.variance);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'items_json': json.encode(items.map((x) => x.toMap()).toList()),
      'total_yesterday_stock': totalYesterdayStock,
      'total_operating_units': totalOperatingUnits,
      'total_current_stock': totalCurrentStock,
      'total_actual_consumption': totalActualConsumption,
      'total_variance': totalVariance,
      'notes': notes,
    };
  }

  factory StockRecord.fromMap(Map<String, dynamic> map) {
    List<CupStockItem> loadedItems = [];
    if (map['items_json'] != null) {
      final List parsedJson = json.decode(map['items_json'] as String);
      loadedItems = parsedJson
          .map((x) => CupStockItem.fromMap(x as Map<String, dynamic>))
          .toList();
    }

    return StockRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      items: loadedItems,
      notes: (map['notes'] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory StockRecord.fromJson(String source) =>
      StockRecord.fromMap(json.decode(source) as Map<String, dynamic>);
}
