import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../localization/app_localizations.dart';
import '../widgets/glass_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

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
            context.translate('history'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download_for_offline, color: Colors.tealAccent),
              onPressed: () async {
                final filePath = await provider.exportToCSV();
                if (filePath != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${context.translate('csv_exported')}\nPath: $filePath"),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.translate('no_records')), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          ],
        ),
        body: provider.records.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 72.0, color: isDark ? Colors.white30 : Colors.black26),
                    const SizedBox(height: 16.0),
                    Text(
                      context.translate('no_records'),
                      style: TextStyle(fontSize: 16.0, color: isDark ? Colors.white60 : Colors.black54),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: provider.records.length,
                itemBuilder: (context, index) {
                  final record = provider.records[index];

                  Color varianceColor = Colors.greenAccent;
                  if (record.totalVariance > 0) {
                    varianceColor = Colors.redAccent;
                  } else if (record.totalVariance < 0) {
                    varianceColor = Colors.tealAccent;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Dismissible(
                      key: Key('record_${record.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (dir) {
                        if (record.id != null) {
                          provider.deleteHistoryRecord(record.id!);
                        }
                      },
                      child: GlassCard(
                        padding: const EdgeInsets.all(16.0),
                        borderRadius: 20.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(record.date, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  "Total Variance: ${record.totalVariance.toStringAsFixed(0)}",
                                  style: TextStyle(color: varianceColor, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Divider(height: 20.0),
                            ...record.items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item.preset.displayLabel, style: const TextStyle(fontSize: 13.0)),
                                    Text(
                                      "Used: ${item.actualConsumption.toStringAsFixed(0)} | Stock: ${item.currentStock.toStringAsFixed(0)}",
                                      style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
