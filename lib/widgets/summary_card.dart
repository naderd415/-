import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import 'glass_card.dart';

class SummaryCard extends StatelessWidget {
  final double yesterday;
  final double current;
  final double operating;
  final double actualConsumption;
  final double variance;

  const SummaryCard({
    Key? key,
    required this.yesterday,
    required this.current,
    required this.operating,
    required this.actualConsumption,
    required this.variance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Variance logic:
    // Actual Consumption = Yesterday's Stock - Current Stock
    // Variance = Actual Consumption - Operating Units
    // If Variance > 0 -> Shortage (We consumed more stock than we logged as operated) -> Red
    // If Variance < 0 -> Surplus (We consumed less stock than we logged as operated) -> Teal / Blue
    // If Variance == 0 -> Match / Accurate -> Green
    
    Color statusColor;
    String statusTextKey;
    IconData statusIcon;

    if (variance > 0) {
      statusColor = Colors.redAccent;
      statusTextKey = 'shortage';
      statusIcon = Icons.warning_amber_rounded;
    } else if (variance < 0) {
      statusColor = Colors.tealAccent;
      statusTextKey = 'surplus';
      statusIcon = Icons.info_outline;
    } else {
      statusColor = Colors.greenAccent;
      statusTextKey = 'accurate';
      statusIcon = Icons.check_circle_outline;
    }

    final double displayVariance = variance.abs();

    return GlassCard(
      borderRadius: 24.0,
      opacity: 0.12,
      border: Border.all(
        color: statusColor.withOpacity(0.4),
        width: 2.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.translate('actual_consumption'),
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(color: statusColor.withOpacity(0.3), width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16.0),
                    const SizedBox(width: 6.0),
                    Text(
                      context.translate(statusTextKey),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Actual Consumption Value
          Text(
            actualConsumption.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), ''),
            style: TextStyle(
              fontSize: 48.0,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const Divider(height: 30.0, thickness: 1.0),

          // Secondary inputs detail
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Formula breakdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.translate('variance'),
                    style: TextStyle(
                      fontSize: 13.0,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    displayVariance.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), ''),
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              // Yesterday / Today details
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(width: 8.0, height: 8.0, decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle)),
                      const SizedBox(width: 6.0),
                      Text(
                        "${context.translate('yesterday_stock')}: ${yesterday.toStringAsFixed(0)}",
                        style: TextStyle(fontSize: 12.0, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Container(width: 8.0, height: 8.0, decoration: const BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle)),
                      const SizedBox(width: 6.0),
                      Text(
                        "${context.translate('current_stock')}: ${current.toStringAsFixed(0)}",
                        style: TextStyle(fontSize: 12.0, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Container(width: 8.0, height: 8.0, decoration: const BoxDecoration(color: Colors.purpleAccent, shape: BoxShape.circle)),
                      const SizedBox(width: 6.0),
                      Text(
                        "${context.translate('operating_units')}: ${operating.toStringAsFixed(0)}",
                        style: TextStyle(fontSize: 12.0, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
