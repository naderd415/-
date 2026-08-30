import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../localization/app_localizations.dart';
import '../widgets/glass_card.dart';

class ForecastingScreen extends StatelessWidget {
  const ForecastingScreen({Key? key}) : super(key: key);

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
            context.translate('forecasting'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Subtitle Banner
              GlassCard(
                borderRadius: 20.0,
                opacity: 0.1,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: const BoxDecoration(
                        color: Colors.tealAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.analytics_outlined, color: Colors.black, size: 28.0),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('forecasting'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            context.translate('forecasting_subtitle'),
                            style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Cup Preset Predictions List
              Text(
                context.translate('cup_presets'),
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14.0),

              ...provider.presets.map((preset) {
                final forecastMap = provider.predictDemandForCup(preset);
                final double predictedDemand = forecastMap['predictedDemand'] as double;
                final double recommendedReorder = forecastMap['recommendedReorder'] as double;
                final String status = forecastMap['status'] as String;
                final double avgDaily = forecastMap['avgDaily'] as double;

                Color flagColor;
                String statusKey;
                IconData flagIcon;

                if (status == 'critical') {
                  flagColor = Colors.redAccent;
                  statusKey = 'status_critical';
                  flagIcon = Icons.error_outline;
                } else if (status == 'orderSoon') {
                  flagColor = Colors.amberAccent;
                  statusKey = 'status_order_soon';
                  flagIcon = Icons.warning_amber_rounded;
                } else {
                  flagColor = Colors.greenAccent;
                  statusKey = 'status_safe';
                  flagIcon = Icons.check_circle_outline;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GlassCard(
                    borderRadius: 20.0,
                    border: Border.all(color: flagColor.withOpacity(0.4), width: 1.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Preset Title & Visual Reorder Status Tag
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              preset.getLocalizedName(Localizations.localeOf(context).languageCode),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: flagColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(100.0),
                                border: Border.all(color: flagColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(flagIcon, color: flagColor, size: 14.0),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    context.translate(statusKey),
                                    style: TextStyle(
                                      color: flagColor,
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20.0),

                        // Analytics Grid Values
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Predicted Demand Tomorrow
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.translate('predicted_demand'),
                                  style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  "${predictedDemand.toStringAsFixed(0)} units",
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.tealAccent,
                                  ),
                                ),
                              ],
                            ),
                            // Recommended Reorder Quantity
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  context.translate('recommended_reorder'),
                                  style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  "+${recommendedReorder.toStringAsFixed(0)} units",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: flagColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          "Moving Daily Avg: ${avgDaily.toStringAsFixed(1)} units/day",
                          style: const TextStyle(fontSize: 11.0, fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
