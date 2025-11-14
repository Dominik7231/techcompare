import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/airpods.dart';
import '../utils/settings.dart';

class AirPodsCompareScreen extends StatelessWidget {
  final List<AirPods> airpods;

  const AirPodsCompareScreen({super.key, required this.airpods});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFF5F5F5),
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
          'Compare AirPods',
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
            _buildHeader(isDark),
            _buildSummary(isDark),

            // Detailed comparisons
            _buildComparisonRow(
              'Chip',
              Icons.memory,
              airpods.map((a) => a.chip).toList(),
              isDark,
            ),
            _buildNumericRow(
              'Battery Life',
              Icons.battery_charging_full,
              airpods.map((a) => a.batteryLife).toList(),
              'hours',
              isDark,
            ),
            _buildComparisonRow(
              'Noise Cancellation',
              Icons.noise_control_off,
              airpods.map((a) => a.noiseCancellation ?? 'None').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Spatial Audio',
              Icons.surround_sound,
              airpods.map((a) => a.spatialAudio ?? 'Not supported').toList(),
              isDark,
            ),
            _buildNumericRow(
              'Case Battery',
              Icons.battery_std,
              airpods.map((a) => a.caseBatteryLife ?? 0).toList(),
              'hours',
              isDark,
            ),
            _buildComparisonRow(
              'Bluetooth',
              Icons.bluetooth,
              airpods.map((a) => a.bluetooth ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Water Resistance',
              Icons.water_drop,
              airpods.map((a) => a.waterResistance ?? 'None').toList(),
              isDark,
            ),
            _buildNumericRow(
              'Weight',
              Icons.scale,
              airpods.map((a) => a.weight ?? 0).toList(),
              'g',
              isDark,
            ),
            _buildComparisonRow(
              'Dimensions',
              Icons.straighten,
              airpods.map((a) => a.dimensions ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Charging Case',
              Icons.charging_station,
              airpods.map((a) => a.chargingCase ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Wireless Charging',
              Icons.battery_charging_full,
              airpods
                  .map(
                    (a) =>
                        a.hasWirelessCharging != null && a.hasWirelessCharging!
                        ? 'Yes'
                        : 'No',
                  )
                  .toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Driver Size',
              Icons.speaker,
              airpods
                  .map(
                    (a) => a.driverSize != null ? '${a.driverSize}mm' : 'N/A',
                  )
                  .toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Microphone',
              Icons.mic,
              airpods.map((a) => a.microphone ?? 'N/A').toList(),
              isDark,
            ),
            _buildNumericRow(
              'Charging Time',
              Icons.timer,
              airpods.map((a) => a.chargingTime ?? 0).toList(),
              'min',
              isDark,
            ),
            _buildComparisonRow(
              'Find My',
              Icons.location_on,
              airpods
                  .map(
                    (a) => a.hasFindMy != null && a.hasFindMy! ? 'Yes' : 'No',
                  )
                  .toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Audio Codec',
              Icons.music_note,
              airpods.map((a) => a.audioCodec ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Price',
              Icons.attach_money,
              airpods
                  .map((a) => AppSettings.formatPrice(a.price.toDouble()))
                  .toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Release Year',
              Icons.calendar_today,
              airpods.map((a) => a.releaseYear ?? 'N/A').toList(),
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
    final title = 'AirPods Comparison: ${airpods.map((a) => a.name).join(' vs ')}';
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
                leading: const Icon(Icons.close, color: Colors.white),
                iconColor: Colors.black,
                tileColor: Colors.black,
                textColor: Colors.white,
                title: const Text('Post on X'),
                subtitle: const Text('Open X to post full comparison'),
                onTap: () {
                  Navigator.pop(context);
                  _postOnX(context, plain);
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

  Future<void> _postOnX(BuildContext context, String tweetText) async {
    final encodedText = Uri.encodeComponent(tweetText);
    final xUrl = Uri.parse('https://x.com/intent/tweet?text=$encodedText');
    
    try {
      if (await canLaunchUrl(xUrl)) {
        await launchUrl(xUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open X. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening X: $e')),
        );
      }
    }
  }

  String _buildTweetText() {
    final names = airpods.map((a) => a.name).join(' vs ');
    final maxBattery = airpods.reduce((a, b) => a.batteryLife > b.batteryLife ? a : b);
    final text = 'AirPods Comparison: $names\n'
        'Longest Battery: ${maxBattery.name}\n'
        '#TechCompare';
    return text;
  }

  String _buildMarkdownText() {
    final buffer = StringBuffer();
    buffer.writeln('# AirPods Comparison');
    buffer.writeln('');
    buffer.writeln('**Models:** ${airpods.map((a) => a.name).join(' vs ')}');
    buffer.writeln('');
    for (var a in airpods) {
      buffer.writeln('- ${a.name}:');
      buffer.writeln('  - Chip: ${a.chip}');
      buffer.writeln('  - Battery Life: ${a.batteryLife} hours');
      buffer.writeln('  - Noise Cancellation: ${a.noiseCancellation ?? 'None'}');
      buffer.writeln('  - Spatial Audio: ${a.spatialAudio ?? 'Not supported'}');
      buffer.writeln('  - Bluetooth: ${a.bluetooth ?? 'N/A'}');
      if (a.weight != null) buffer.writeln('  - Weight: ${a.weight} g');
    }
    buffer.writeln('');
    buffer.writeln('Shared from Tech Compare');
    return buffer.toString();
  }

  String _buildQrPayload() {
    final names = airpods.map((a) => a.name).toList();
    final data = {
      'type': 'comparison',
      'category': 'AirPods',
      'names': names,
    };
    return jsonEncode(data);
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
              : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: airpods.map((airpod) {
          return Expanded(
            child: Column(
              children: [
                Text(airpod.image, style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 8),
                Text(
                  airpod.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  AppSettings.formatPrice(airpod.price.toDouble()),
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
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 28),
              const SizedBox(width: 8),
              Text(
                'Comparison: ${airpods.length} AirPods',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
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
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? Colors.white : const Color(0xFF6366F1),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF6366F1),
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
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? Colors.white : const Color(0xFF6366F1),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF6366F1),
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
                final isBest =
                    value == maxValue && maxValue != minValue && value > 0;
                final isWorst =
                    value == minValue && maxValue != minValue && value > 0;

                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isBest
                          ? (isDark
                                ? Colors.green.shade900
                                : Colors.green.shade100)
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
                                ? (isDark
                                      ? Colors.green.shade300
                                      : Colors.green.shade700)
                                : isWorst
                                ? (isDark
                                      ? Colors.red.shade300
                                      : Colors.red.shade700)
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                        if (isBest)
                          Icon(
                            Icons.emoji_events,
                            color: isDark
                                ? Colors.green.shade300
                                : Colors.green.shade700,
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
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.palette,
                  color: isDark ? Colors.white : const Color(0xFF6366F1),
                ),
                const SizedBox(width: 8),
                Text(
                  'Available Colors',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(airpods.length, (index) {
                final airpod = airpods[index];
                return Expanded(
                  child: Column(
                    children: airpod.colors.map((color) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          color,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.black87,
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
    final maxBattery = airpods.reduce(
      (a, b) => a.batteryLife > b.batteryLife ? a : b,
    );
    final minPrice = airpods.reduce((a, b) => a.price < b.price ? a : b);
    final maxCaseBattery =
        airpods.where((a) => a.caseBatteryLife != null).isNotEmpty
        ? airpods
              .where((a) => a.caseBatteryLife != null)
              .reduce(
                (a, b) =>
                    (a.caseBatteryLife ?? 0) > (b.caseBatteryLife ?? 0) ? a : b,
              )
        : null;
    final lightest =
        airpods.where((a) => a.weight != null && a.weight! > 0).isNotEmpty
        ? airpods
              .where((a) => a.weight != null && a.weight! > 0)
              .reduce((a, b) => (a.weight ?? 999) < (b.weight ?? 999) ? a : b)
        : null;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
              : [
                  const Color(0xFF6366F1).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                ],
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
          _buildWinnerItem(
            '🔋 Best Battery Life',
            maxBattery.name,
            '${maxBattery.batteryLife} hours',
            isDark,
          ),
          if (maxCaseBattery != null)
            _buildWinnerItem(
              '🔋 Best Case Battery',
              maxCaseBattery.name,
              '${maxCaseBattery.caseBatteryLife} hours',
              isDark,
            ),
          if (lightest != null)
            _buildWinnerItem(
              '⚖️ Lightest',
              lightest.name,
              '${lightest.weight}g',
              isDark,
            ),
          _buildWinnerItem(
            '💰 Best Price',
            minPrice.name,
            AppSettings.formatPrice(minPrice.price.toDouble()),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerItem(
    String category,
    String airpodsName,
    String value,
    bool isDark,
  ) {
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
                  airpodsName,
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
                    color: isDark
                        ? Colors.green.shade300
                        : Colors.green.shade700,
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
    buffer.writeln('🎧 AirPods Comparison\n');
    buffer.writeln('Comparing ${airpods.length} AirPods:\n');

    for (var airpod in airpods) {
      buffer.writeln('${airpod.name}:');
      buffer.writeln('  Chip: ${airpod.chip}');
      buffer.writeln('  Battery Life: ${airpod.batteryLife} hours');
      if (airpod.noiseCancellation != null)
        buffer.writeln('  Noise Cancellation: ${airpod.noiseCancellation}');
      if (airpod.spatialAudio != null)
        buffer.writeln('  Spatial Audio: ${airpod.spatialAudio}');
      if (airpod.caseBatteryLife != null)
        buffer.writeln('  Case Battery: ${airpod.caseBatteryLife} hours');
      if (airpod.bluetooth != null)
        buffer.writeln('  Bluetooth: ${airpod.bluetooth}');
      if (airpod.waterResistance != null)
        buffer.writeln('  Water Resistance: ${airpod.waterResistance}');
      buffer.writeln(
        '  Price: ${AppSettings.formatPrice(airpod.price.toDouble())}',
      );
      if (airpod.releaseYear != null)
        buffer.writeln('  Release Year: ${airpod.releaseYear}');
      buffer.writeln('');
    }

    final maxBattery = airpods.reduce(
      (a, b) => a.batteryLife > b.batteryLife ? a : b,
    );
    final minPrice = airpods.reduce((a, b) => a.price < b.price ? a : b);
    final maxCaseBattery =
        airpods.where((a) => a.caseBatteryLife != null).isNotEmpty
        ? airpods
              .where((a) => a.caseBatteryLife != null)
              .reduce(
                (a, b) =>
                    (a.caseBatteryLife ?? 0) > (b.caseBatteryLife ?? 0) ? a : b,
              )
        : null;

    buffer.writeln('🏆 Winners:');
    buffer.writeln(
      '  Best Battery Life: ${maxBattery.name} (${maxBattery.batteryLife} hours)',
    );
    if (maxCaseBattery != null) {
      buffer.writeln(
        '  Best Case Battery: ${maxCaseBattery.name} (${maxCaseBattery.caseBatteryLife} hours)',
      );
    }
    buffer.writeln(
      '  Best Price: ${minPrice.name} (${AppSettings.formatPrice(minPrice.price.toDouble())})',
    );
    buffer.writeln('\nShared from Tech Compare App');

    return buffer.toString();
  }
}
