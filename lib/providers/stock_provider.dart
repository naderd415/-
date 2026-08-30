import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import '../models/stock_record.dart';
import '../models/cup_preset.dart';
import '../models/cup_stock_item.dart';
import '../services/db_service.dart';
import '../services/ocr_service.dart';
import '../services/tflite_service.dart';
import '../services/speech_service.dart';

class StockProvider extends ChangeNotifier {
  // Offline Services
  final DBService _dbService = DBService.instance;
  final OCRService _ocrService = OCRService();
  final TFLiteService _tfliteService = TFLiteService();
  final SpeechService _speechService = SpeechService();

  // Application Settings
  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.dark;

  // Cup Presets & Multi-Item Dashboard Entries
  List<CupPreset> _presets = [];
  List<CupStockItem> _cupStockItems = [];
  Map<int, Map<String, TextEditingController>> _itemControllers = {};

  // Additional Notes Controller
  final TextEditingController notesController = TextEditingController();

  // History Records
  List<StockRecord> _records = [];

  // Service States
  bool _isListening = false;
  bool _isScanning = false;
  bool _isTfliteLoading = false;
  String _speechTranscript = "";

  // Getters
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  List<CupPreset> get presets => _presets;
  List<CupStockItem> get cupStockItems => _cupStockItems;
  List<StockRecord> get records => _records;
  bool get isListening => _isListening;
  bool get isScanning => _isScanning;
  bool get isTfliteLoading => _isTfliteLoading;
  String get speechTranscript => _speechTranscript;
  TFLiteService get tfliteService => _tfliteService;

  // Aggregated Inventory Totals
  double get totalYesterdayStock =>
      _cupStockItems.fold(0.0, (sum, item) => sum + item.yesterdayStock);

  double get totalOperatingUnits =>
      _cupStockItems.fold(0.0, (sum, item) => sum + item.operatingUnits);

  double get totalCurrentStock =>
      _cupStockItems.fold(0.0, (sum, item) => sum + item.currentStock);

  double get totalActualConsumption =>
      _cupStockItems.fold(0.0, (sum, item) => sum + item.actualConsumption);

  double get totalVariance =>
      _cupStockItems.fold(0.0, (sum, item) => sum + item.variance);

  bool get hasLowStockAlerts =>
      _cupStockItems.any((item) => item.isLowStock && item.currentStock > 0);

  StockProvider() {
    _initProvider();
  }

  Future<void> _initProvider() async {
    await loadCupPresets();
    await refreshRecords();

    _isTfliteLoading = true;
    notifyListeners();
    await _tfliteService.loadModel();
    _isTfliteLoading = false;

    await _speechService.initialize();
    notifyListeners();
  }

  // Load Presets & initialize separate text controllers per cup size
  Future<void> loadCupPresets() async {
    _presets = await _dbService.getAllCupPresets();

    _cupStockItems = _presets.map((preset) {
      return CupStockItem(preset: preset);
    }).toList();

    // Re-create text field controllers for each cup preset
    _itemControllers.clear();
    for (var item in _cupStockItems) {
      final pId = item.preset.id ?? item.preset.ounces.toInt();
      final controllers = {
        'yesterday': TextEditingController(),
        'operating': TextEditingController(),
        'current': TextEditingController(),
      };

      controllers['yesterday']!.addListener(() => _updateItemValues(item, controllers));
      controllers['operating']!.addListener(() => _updateItemValues(item, controllers));
      controllers['current']!.addListener(() => _updateItemValues(item, controllers));

      _itemControllers[pId] = controllers;
    }

    notifyListeners();
  }

  TextEditingController getController(CupStockItem item, String fieldKey) {
    final pId = item.preset.id ?? item.preset.ounces.toInt();
    return _itemControllers[pId]?[fieldKey] ?? TextEditingController();
  }

  void _updateItemValues(CupStockItem item, Map<String, TextEditingController> controllers) {
    item.yesterdayStock = double.tryParse(controllers['yesterday']!.text) ?? 0.0;
    item.operatingUnits = double.tryParse(controllers['operating']!.text) ?? 0.0;
    item.currentStock = double.tryParse(controllers['current']!.text) ?? 0.0;
    notifyListeners();
  }

  Future<void> refreshRecords() async {
    _records = await _dbService.getAllRecords();
    notifyListeners();
  }

  Future<void> deleteHistoryRecord(int id) async {
    await _dbService.deleteRecord(id);
    await refreshRecords();
  }

  void toggleLanguage() {
    _locale = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // --- MANUAL CUSTOM CUP PRESET CREATION ---
  Future<void> addCustomCupPreset({
    required double ounces,
    required double milliliters,
    required String nameAr,
    required String nameEn,
    required double lowStockThreshold,
  }) async {
    final preset = CupPreset(
      ounces: ounces,
      milliliters: milliliters,
      nameAr: nameAr,
      nameEn: nameEn,
      isCustom: true,
      lowStockThreshold: lowStockThreshold,
    );

    await _dbService.insertCupPreset(preset);
    await loadCupPresets();
  }

  Future<void> deleteCustomCupPreset(int id) async {
    await _dbService.deleteCupPreset(id);
    await loadCupPresets();
  }

  // --- DEMAND FORECASTING ALGORITHM ---
  // Calculates moving average daily consumption for a cup size and recommends reorder quantity
  Map<String, dynamic> predictDemandForCup(CupPreset preset) {
    if (_records.isEmpty) {
      return {
        'predictedDemand': 0.0,
        'recommendedReorder': 0.0,
        'status': 'safe',
      };
    }

    double totalHistoricalConsumption = 0.0;
    int sampleDays = 0;

    for (var record in _records) {
      final matchingItems = record.items.where(
        (item) => item.preset.ounces == preset.ounces && item.preset.milliliters == preset.milliliters,
      );
      for (var item in matchingItems) {
        totalHistoricalConsumption += item.actualConsumption;
        sampleDays++;
      }
    }

    final double avgDailyConsumption = sampleDays > 0 ? (totalHistoricalConsumption / sampleDays) : 0.0;
    
    // Find current stock for this preset on dashboard
    final currentItem = _cupStockItems.firstWhere(
      (item) => item.preset.ounces == preset.ounces,
      orElse: () => CupStockItem(preset: preset),
    );

    final double currentStockVal = currentItem.currentStock;
    final double predictedDemandTomorrow = avgDailyConsumption > 0 ? avgDailyConsumption : 20.0; // Baseline
    
    // Recommended Reorder = (Predicted Demand for 3 days buffer) - Current Stock
    final double targetBufferStock = predictedDemandTomorrow * 2.5;
    final double recommendedReorder = (targetBufferStock - currentStockVal).clamp(0.0, 9999.0);

    String status = 'safe';
    if (currentStockVal < predictedDemandTomorrow) {
      status = 'critical';
    } else if (currentStockVal < targetBufferStock * 0.6) {
      status = 'orderSoon';
    }

    return {
      'predictedDemand': predictedDemandTomorrow,
      'recommendedReorder': recommendedReorder,
      'status': status,
      'avgDaily': avgDailyConsumption,
    };
  }

  // Populate numeric values from OCR paper scanner into specific cup size fields
  void assignOCRValueToCup(CupStockItem item, String fieldKey, double value) {
    final valStr = value.toStringAsFixed(0).replaceAll(RegExp(r'\.0$'), '');
    final controller = getController(item, fieldKey);
    controller.text = valStr;
    notifyListeners();
  }

  // --- SAVE MULTI-ITEM CLOSING ---
  Future<bool> saveCurrentClosing() async {
    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final StockRecord record = StockRecord(
      date: todayDate,
      items: _cupStockItems,
      notes: notesController.text,
    );

    await _dbService.insertRecord(record);

    // Reset controllers
    for (var controllers in _itemControllers.values) {
      controllers['yesterday']?.clear();
      controllers['operating']?.clear();
      controllers['current']?.clear();
    }
    notesController.clear();

    await loadCupPresets();
    await refreshRecords();
    return true;
  }

  // --- OFFLINE BACKUP & RESTORE ---
  Future<String?> backupDatabase() async {
    return await _dbService.backupDatabaseToJSON();
  }

  Future<bool> restoreDatabase(String jsonStr) async {
    final success = await _dbService.restoreDatabaseFromJSON(jsonStr);
    if (success) {
      await loadCupPresets();
      await refreshRecords();
    }
    return success;
  }

  // --- CSV EXPORT ---
  Future<String?> exportToCSV() async {
    if (_records.isEmpty) return null;

    try {
      final List<List<dynamic>> rows = [];

      rows.add([
        "Record ID",
        "Date",
        "Cup Size (Dual Unit)",
        "Yesterday Stock (مخزون أمس)",
        "Operating Units (التشغيل)",
        "Current Stock (الاستوك الحالي)",
        "Actual Consumption (الاستهلاك الفعلي)",
        "Variance / Discrepancy (الفارق)",
        "Notes"
      ]);

      for (var record in _records) {
        for (var item in record.items) {
          rows.add([
            record.id,
            record.date,
            item.preset.displayLabel,
            item.yesterdayStock,
            item.operatingUnits,
            item.currentStock,
            item.actualConsumption,
            item.variance,
            record.notes,
          ]);
        }
      }

      final String csvData = const ListToCsvConverter().convert(rows);

      final Directory? directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      if (directory == null) return null;

      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String filePath = "${directory.path}/MultiCup_StockReport_$timestamp.csv";

      final File file = File(filePath);
      await file.writeAsString(csvData);

      return filePath;
    } catch (e) {
      print("CSV Export Exception: $e");
      return null;
    }
  }

  @override
  void dispose() {
    for (var controllers in _itemControllers.values) {
      controllers['yesterday']?.dispose();
      controllers['operating']?.dispose();
      controllers['current']?.dispose();
    }
    notesController.dispose();
    _ocrService.dispose();
    _tfliteService.dispose();
    super.dispose();
  }
}
