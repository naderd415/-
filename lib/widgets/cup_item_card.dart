import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cup_stock_item.dart';
import '../providers/stock_provider.dart';
import '../localization/app_localizations.dart';
import 'glass_card.dart';
import 'custom_text_field.dart';

class CupItemCard extends StatelessWidget {
  final CupStockItem item;

  const CupItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = context.isRtl;

    final yesterdayController = provider.getController(item, 'yesterday');
    final operatingController = provider.getController(item, 'operating');
    final currentController = provider.getController(item, 'current');

    Color statusColor = Colors.greenAccent;
    if (item.variance > 0) {
      statusColor = Colors.redAccent;
    } else if (item.variance < 0) {
      statusColor = Colors.tealAccent;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GlassCard(
        borderRadius: 24.0,
        opacity: 0.1,
        border: Border.all(
          color: item.isLowStock && item.currentStock > 0
              ? Colors.orangeAccent
              : (isDark ? Colors.white12 : Colors.black12),
          width: item.isLowStock ? 2.0 : 1.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Title Header with Dual-Unit Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_cafe, color: Colors.tealAccent, size: 20.0),
                    ),
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.preset.getLocalizedName(Localizations.localeOf(context).languageCode),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                        Text(
                          item.preset.displayLabel,
                          style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),

                // Low Stock Warning Alert Badge
                if (item.isLowStock && item.currentStock > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100.0),
                      border: Border.all(color: Colors.orangeAccent),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 14.0),
                        const SizedBox(width: 4.0),
                        Text(
                          context.translate('low_stock_warning'),
                          style: const TextStyle(color: Colors.orangeAccent, fontSize: 10.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Independent inputs for this cup size
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: yesterdayController,
                    labelKey: 'yesterday_stock',
                    prefixIcon: Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: CustomTextField(
                    controller: operatingController,
                    labelKey: 'operating_units',
                    prefixIcon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: CustomTextField(
                    controller: currentController,
                    labelKey: 'current_stock',
                    prefixIcon: Icons.inventory_2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.0),

            // Live Per-Cup Calculation Metrics Bar
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${context.translate('actual_consumption')}: ${item.actualConsumption.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  Text(
                    "${context.translate('variance')}: ${item.variance.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
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
}
