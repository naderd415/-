import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/stock_provider.dart';
import '../localization/app_localizations.dart';
import '../widgets/cup_item_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/add_cup_dialog.dart';
import 'reports_screen.dart';
import 'forecasting_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  void _showOcrBottomSheet(BuildContext context, StockProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            List<double> detectedNumbers = [120.0, 30.0, 90.0, 200.0, 45.0, 155.0];
            bool isProcessing = false;

            return Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32.0),
                  topRight: Radius.circular(32.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 50.0,
                      height: 5.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    context.translate('camera_scan'),
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    context.translate('scan_instructions'),
                    style: const TextStyle(color: Colors.grey, fontSize: 13.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20.0),
                  if (isProcessing)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    Text(
                      context.translate('detected_value'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                    ),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: detectedNumbers.map((number) {
                        final valStr = number.toStringAsFixed(0);
                        return ActionChip(
                          avatar: const Icon(Icons.pin, size: 16.0),
                          label: Text(valStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            _showAssignDialog(context, provider, number);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24.0),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    onPressed: () async {
                      setModalState(() => isProcessing = true);
                      await Future.delayed(const Duration(milliseconds: 800));
                      setModalState(() {
                        isProcessing = false;
                        detectedNumbers = [160, 50, 110, 240, 60, 180];
                      });
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: Text(context.translate('camera_scan')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAssignDialog(BuildContext context, StockProvider provider, double value) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("${context.translate('assign_to')} $value"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: provider.cupStockItems.map((item) {
                return ListTile(
                  title: Text(item.preset.displayLabel),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () {
                          provider.assignOCRValueToCup(item, 'yesterday', value);
                          Navigator.pop(ctx);
                        },
                        child: const Text('أمس'),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.assignOCRValueToCup(item, 'current', value);
                          Navigator.pop(ctx);
                        },
                        child: const Text('استوك'),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = context.isRtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.translate('app_title'),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18.0),
          ),
          actions: [
            // Database Backup/Restore Button
            PopupMenuButton<String>(
              icon: const Icon(Icons.settings),
              onSelected: (val) async {
                if (val == 'backup') {
                  final path = await provider.backupDatabase();
                  if (path != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${context.translate('backup_success')}\nPath: $path"), backgroundColor: Colors.green),
                    );
                  }
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'backup',
                  child: Row(
                    children: [
                      const Icon(Icons.backup, color: Colors.teal),
                      const SizedBox(width: 8.0),
                      Text(context.translate('backup_db')),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(provider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
              onPressed: provider.toggleTheme,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.tealAccent : Colors.teal,
                  side: BorderSide(color: isDark ? Colors.tealAccent : Colors.teal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                ),
                onPressed: provider.toggleLanguage,
                child: Text(isRtl ? 'EN' : 'عربي', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Aggregated Total Stock Summary Card
              SummaryCard(
                yesterday: provider.totalYesterdayStock,
                current: provider.totalCurrentStock,
                operating: provider.totalOperatingUnits,
                actualConsumption: provider.totalActualConsumption,
                variance: provider.totalVariance,
              ),
              const SizedBox(height: 20.0),

              // Action Toolbar: Add Custom Cup & Forecasting Navigation
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.withOpacity(0.2),
                        foregroundColor: isDark ? Colors.tealAccent : Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => const AddCupDialog(),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text(context.translate('add_custom_size'), style: const TextStyle(fontSize: 12.0)),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.withOpacity(0.2),
                        foregroundColor: Colors.purpleAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForecastingScreen()),
                        );
                      },
                      icon: const Icon(Icons.analytics),
                      label: Text(context.translate('forecasting'), style: const TextStyle(fontSize: 12.0)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),

              // Multi-Item Dedicated Cards List for EACH Cup Size Preset
              Text(
                context.translate('cup_presets'),
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14.0),

              ...provider.cupStockItems.map((item) {
                return CupItemCard(item: item);
              }).toList(),

              const SizedBox(height: 20.0),

              // Global Save Record Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent.shade400,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                ),
                onPressed: () async {
                  final success = await provider.saveCurrentClosing();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? context.translate('record_saved') : context.translate('invalid_inputs')),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                },
                child: Text(
                  context.translate('save_record'),
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 12.0),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportsScreen()),
                  );
                },
                icon: const Icon(Icons.history_edu),
                label: Text(context.translate('reports')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
