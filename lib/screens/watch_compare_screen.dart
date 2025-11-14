import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/watch.dart';
import '../utils/settings.dart';

class WatchCompareScreen extends StatelessWidget {
  final List<Watch> watches;

  const WatchCompareScreen({super.key, required this.watches});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF2D3142) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF2D3142),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF2D3142),
        ),
        title: Text(
          'Compare Watches',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showShareOptions(context),
            tooltip: 'Share comparison',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(isDark, context),
            _buildSummary(isDark),

            _buildComparisonRow(
              'Chip',
              Icons.memory,
              watches.map((w) => w.chip).toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Display',
              Icons.watch,
              watches.map((w) => w.display).toList(),
              isDark,
            ),
            _buildNumericRow(
              'Battery Life',
              Icons.battery_charging_full,
              watches.map((w) => w.batteryLife).toList(),
              'hours',
              isDark,
            ),
            _buildComparisonRow(
              'Water Resistance',
              Icons.water_drop,
              watches.map((w) => w.waterResistance ?? 'None').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'GPS',
              Icons.gps_fixed,
              watches.map((w) => w.hasGPS != null && w.hasGPS! ? 'Yes' : 'No').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Cellular',
              Icons.network_cell,
              watches.map((w) => w.hasCellular != null && w.hasCellular! ? 'Yes' : 'No').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'ECG',
              Icons.favorite,
              watches.map((w) => w.hasECG != null && w.hasECG! ? 'Yes' : 'No').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Blood Oxygen',
              Icons.bloodtype,
              watches.map((w) => w.hasBloodOxygen != null && w.hasBloodOxygen! ? 'Yes' : 'No').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Temperature',
              Icons.thermostat,
              watches.map((w) => w.hasTemperature != null && w.hasTemperature! ? 'Yes' : 'No').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Always-On Display',
              Icons.visibility,
              watches.map((w) => w.hasAlwaysOnDisplay != null && w.hasAlwaysOnDisplay! ? 'Yes' : 'No').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Storage',
              Icons.storage,
              watches.map((w) => w.storage != null ? '${w.storage}GB' : 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Connectivity',
              Icons.bluetooth,
              watches.map((w) => w.connectivity ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Sensors',
              Icons.health_and_safety,
              watches.map((w) => w.sensors ?? 'N/A').toList(),
              isDark,
            ),
            _buildNumericRow(
              'Weight',
              Icons.scale,
              watches.map((w) => w.weight ?? 0).toList(),
              'g',
              isDark,
            ),
            _buildComparisonRow(
              'Dimensions',
              Icons.straighten,
              watches.map((w) => w.dimensions ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Price',
              Icons.attach_money,
              watches.map((w) => AppSettings.formatPrice(w.price.toDouble())).toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Release Year',
              Icons.calendar_today,
              watches.map((w) => w.releaseYear ?? 'N/A').toList(),
              isDark,
            ),
            _buildColorsComparison(isDark),
            _buildWinnerSummary(isDark),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    final title = 'Watch Comparison: ${watches.map((w) => w.name).join(' vs ')}';
    final plain = _buildComparisonText();
    final tweet = _buildTweetText();
    final markdown = _buildMarkdownText();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.text_snippet),
                title: const Text('Share as Plain Text'),
                onTap: () {
                  Navigator.pop(context);
                  Share.share(plain, subject: title);
                },
              ),
              ListTile(
                leading: const Icon(Icons.open_in_new),
                title: const Text('Share as Tweet (X)'),
                subtitle: const Text('Optimized for 280 characters'),
                onTap: () {
                  Navigator.pop(context);
                  Share.share(tweet, subject: title);
                },
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Share as Markdown'),
                onTap: () {
                  Navigator.pop(context);
                  Share.share(markdown, subject: title);
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('Share via QR Code'),
                onTap: () {
                  Navigator.pop(context);
                  final payload = _buildQrPayload();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Scan to Import'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: Center(
                          child: QrImageView(
                            data: payload,
                            version: QrVersions.auto,
                            size: 220,
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy to Clipboard (Tweet)'),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: tweet));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied tweet text to clipboard')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildTweetText() {
    final names = watches.map((w) => w.name).join(' vs ');
    final maxBattery = watches.reduce((a, b) => a.batteryLife > b.batteryLife ? a : b);
    var text = 'Watch Comparison: $names\n'
        'Longest Battery: ${maxBattery.name}\n'
        '#TechCompare';
    if (text.length > 280) {
      text = text.substring(0, 277) + '...';
    }
    return text;
  }

  String _buildMarkdownText() {
    final buffer = StringBuffer();
    buffer.writeln('# Watch Comparison');
    buffer.writeln('');
    buffer.writeln('**Models:** ${watches.map((w) => w.name).join(' vs ')}');
    buffer.writeln('');
    for (var w in watches) {
      buffer.writeln('- ${w.name}:');
      buffer.writeln('  - Chip: ${w.chip}');
      buffer.writeln('  - Display: ${w.display}');
      buffer.writeln('  - Battery Life: ${w.batteryLife} hours');
      if (w.waterResistance != null) buffer.writeln('  - Water Resistance: ${w.waterResistance}');
      if (w.connectivity != null) buffer.writeln('  - Connectivity: ${w.connectivity}');
      buffer.writeln('');
    }
    buffer.writeln('Shared from Tech Compare');
    return buffer.toString();
  }

  String _buildQrPayload() {
    final names = watches.map((w) => w.name).toList();
    final data = {
      'type': 'comparison',
      'category': 'Watches',
      'names': names,
    };
    return jsonEncode(data);
  }

  Widget _buildHeader(bool isDark, BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: watches.map((watch) {
          return Expanded(
            child: Column(
              children: [
                Text(watch.image, style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 8),
                Text(
                  watch.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  AppSettings.formatPrice(watch.price.toDouble()),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummary(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 28),
          const SizedBox(width: 8),
          Text(
            'Comparison: ${watches.length} Watches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String title,
    IconData icon,
    List<String> values,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF4A90E2)
                  : const Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? Colors.white : const Color(0xFF4A90E2),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF4A90E2),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: List.generate(values.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      values[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey.shade300 : Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericRow(
    String title,
    IconData icon,
    List<int> values,
    String unit,
    bool isDark,
  ) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF4A90E2)
                  : const Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? Colors.white : const Color(0xFF4A90E2),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF4A90E2),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: List.generate(values.length, (index) {
                final value = values[index];
                final isBest = value == maxValue && maxValue != minValue && value > 0;
                final isWorst = value == minValue && maxValue != minValue && value > 0;

                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isBest
                          ? (isDark ? Colors.green.shade900 : Colors.green.shade100)
                          : isWorst
                              ? (isDark ? Colors.red.shade900 : Colors.red.shade100)
                              : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          value > 0 ? '$value $unit' : 'N/A',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isBest
                                ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
                                : isWorst
                                    ? (isDark ? Colors.red.shade300 : Colors.red.shade700)
                                    : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                        if (isBest)
                          Icon(
                            Icons.emoji_events,
                            color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorsComparison(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF4A90E2)
                  : const Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.palette,
                  color: isDark ? Colors.white : const Color(0xFF4A90E2),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Available Colors',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(watches.length, (index) {
                final watch = watches[index];
                return Expanded(
                  child: Column(
                    children: watch.colors.map((color) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          color,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey.shade300 : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerSummary(bool isDark) {
    final maxBattery = watches.reduce((a, b) => a.batteryLife > b.batteryLife ? a : b);
    final minPrice = watches.reduce((a, b) => a.price < b.price ? a : b);
    final lightest = watches.where((w) => w.weight != null && w.weight! > 0).isNotEmpty
        ? watches
            .where((w) => w.weight != null && w.weight! > 0)
            .reduce((a, b) => (a.weight ?? 999) < (b.weight ?? 999) ? a : b)
        : null;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF4A90E2), const Color(0xFF357ABD)]
              : [const Color(0xFF4A90E2).withOpacity(0.1), const Color(0xFF357ABD).withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 28),
              const SizedBox(width: 8),
              Text(
                'Category Winners',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildWinnerItem('🔋 Best Battery Life', maxBattery.name, '${maxBattery.batteryLife} hours', isDark),
          if (lightest != null)
            _buildWinnerItem('⚖️ Lightest', lightest.name, '${lightest.weight}g', isDark),
          _buildWinnerItem('💰 Best Price', minPrice.name, AppSettings.formatPrice(minPrice.price.toDouble()), isDark),
        ],
      ),
    );
  }

  Widget _buildWinnerItem(String category, String name, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              category,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildComparisonText() {
    final buffer = StringBuffer();
    buffer.writeln('⌚ Watch Comparison\n');
    buffer.writeln('Comparing ${watches.length} Watches:\n');

    for (var w in watches) {
      buffer.writeln('${w.name}:');
      buffer.writeln('  Chip: ${w.chip}');
      buffer.writeln('  Display: ${w.display}');
      buffer.writeln('  Battery Life: ${w.batteryLife} hours');
      if (w.waterResistance != null) buffer.writeln('  Water Resistance: ${w.waterResistance}');
      buffer.writeln('  Price: ${AppSettings.formatPrice(w.price.toDouble())}');
      if (w.releaseYear != null) buffer.writeln('  Release Year: ${w.releaseYear}');
      buffer.writeln('');
    }

    final maxBattery = watches.reduce((a, b) => a.batteryLife > b.batteryLife ? a : b);
    final minPrice = watches.reduce((a, b) => a.price < b.price ? a : b);

    buffer.writeln('🏆 Winners:');
    buffer.writeln('  Best Battery Life: ${maxBattery.name} (${maxBattery.batteryLife} hours)');
    buffer.writeln('  Best Price: ${minPrice.name} (${AppSettings.formatPrice(minPrice.price.toDouble())})');
    buffer.writeln('\nShared from Tech Compare App');

    return buffer.toString();
  }
}

