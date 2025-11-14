import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/laptop.dart';
import '../utils/settings.dart';

class LaptopCompareScreen extends StatelessWidget {
  final List<Laptop> laptops;

  const LaptopCompareScreen({super.key, required this.laptops});

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
          'Compare Laptops',
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

            _buildComparisonRow('Processor', Icons.memory, laptops.map((l) => l.processor).toList(), isDark),
            _buildComparisonRow('Display', Icons.laptop, laptops.map((l) => l.display).toList(), isDark),
            _buildComparisonRow('GPU', Icons.videogame_asset, laptops.map((l) => l.gpu ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Display Tech', Icons.tv, laptops.map((l) => l.displayTech ?? 'N/A').toList(), isDark),
            _buildNumericRow('Refresh Rate', Icons.refresh, laptops.map((l) => l.refreshRate ?? 0).toList(), 'Hz', isDark),
            _buildNumericRow('Peak Brightness', Icons.brightness_high, laptops.map((l) => l.peakBrightness ?? 0).toList(), 'nits', isDark),
            _buildNumericRow('Battery Life', Icons.battery_charging_full, laptops.map((l) => l.batteryHours ?? 0).toList(), 'hours', isDark),
            _buildComparisonRow('Ports', Icons.usb, laptops.map((l) => l.ports ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Operating System', Icons.settings, laptops.map((l) => l.os ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Touchscreen', Icons.touch_app, laptops.map((l) => l.hasTouchscreen != null && l.hasTouchscreen! ? 'Yes' : 'No').toList(), isDark),
            _buildComparisonRow('Keyboard', Icons.keyboard, laptops.map((l) => l.keyboard ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Trackpad', Icons.touch_app_outlined, laptops.map((l) => l.trackpad ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Webcam', Icons.videocam, laptops.map((l) => l.webcam ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Audio', Icons.music_note, laptops.map((l) => l.audio ?? 'N/A').toList(), isDark),
            _buildComparisonRow('RAM Options', Icons.memory, laptops.map((l) => l.ramOptions.map((r) => '${r}GB').join(', ')).toList(), isDark),
            _buildComparisonRow('Storage Options', Icons.storage, laptops.map((l) => l.storageOptions.map((s) => s >= 1024 ? '${s ~/ 1024}TB' : '${s}GB').join(', ')).toList(), isDark),
            _buildComparisonRow('Weight', Icons.scale, laptops.map((l) => l.weight != null ? '${l.weight!.toStringAsFixed(2)}kg' : 'N/A').toList(), isDark),
            _buildComparisonRow('Dimensions', Icons.straighten, laptops.map((l) => l.dimensions ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Price', Icons.attach_money, laptops.map((l) => AppSettings.formatPrice(l.price.toDouble())).toList(), isDark),
            _buildComparisonRow('Release Year', Icons.calendar_today, laptops.map((l) => l.releaseYear ?? 'N/A').toList(), isDark),
            _buildWinnerSummary(isDark),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    final title = 'Laptop Comparison: ${laptops.map((l) => l.name).join(' vs ')}';
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
    final names = laptops.map((l) => l.name).join(' vs ');
    final maxRam = laptops.reduce((a, b) => a.ramOptions.last > b.ramOptions.last ? a : b);
    final text = 'Laptop Comparison: $names\n'
        'Max RAM: ${maxRam.name}\n'
        '#TechCompare';
    return text;
  }

  String _buildMarkdownText() {
    final buffer = StringBuffer();
    buffer.writeln('# Laptop Comparison');
    buffer.writeln('');
    buffer.writeln('**Models:** ${laptops.map((l) => l.name).join(' vs ')}');
    buffer.writeln('');
    for (var l in laptops) {
      buffer.writeln('- ${l.name}:');
      buffer.writeln('  - CPU: ${l.processor}');
      buffer.writeln('  - Display: ${l.display}');
      buffer.writeln('  - RAM: ${l.ramOptions.map((r) => '${r}GB').join(', ')}');
      buffer.writeln('  - Storage: ${l.storageOptions.map((s) => s >= 1024 ? '${s ~/ 1024}TB' : '${s}GB').join(', ')}');
    }
    buffer.writeln('');
    buffer.writeln('Shared from Tech Compare');
    return buffer.toString();
  }

  String _buildQrPayload() {
    final names = laptops.map((l) => l.name).toList();
    final data = {
      'type': 'comparison',
      'category': 'Laptops',
      'names': names,
    };
    return jsonEncode(data);
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [Colors.blue.shade900, Colors.blue.shade700] : [Colors.blue.shade50, Colors.blue.shade100],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: laptops.map((l) {
          return Expanded(
            child: Column(
              children: [
                Text(l.image, style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 8),
                Text(
                  l.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  AppSettings.formatPrice(l.price.toDouble()),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
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
            'Comparison: ${laptops.length} Laptops',
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

  Widget _buildComparisonRow(String title, IconData icon, List<String> values, bool isDark) {
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
              color: isDark ? Colors.blue.shade800 : Colors.blue.shade100,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700),
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
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade300 : Colors.black),
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

  Widget _buildNumericRow(String title, IconData icon, List<int> values, String unit, bool isDark) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: isDark ? Colors.black38 : Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.blue.shade800 : Colors.blue.shade100,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700),
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
                          Icon(Icons.emoji_events, color: isDark ? Colors.green.shade300 : Colors.green.shade700, size: 18),
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

  Widget _buildWinnerSummary(bool isDark) {
    final maxStorage = laptops.reduce((a, b) => a.storageOptions.last > b.storageOptions.last ? a : b);
    final minPrice = laptops.reduce((a, b) => a.price < b.price ? a : b);
    final maxBattery = laptops.where((l) => l.batteryHours != null).isNotEmpty
        ? laptops.where((l) => l.batteryHours != null).reduce((a, b) => (a.batteryHours ?? 0) > (b.batteryHours ?? 0) ? a : b)
        : null;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: isDark ? [Colors.blue.shade900, Colors.blue.shade700] : [Colors.blue.shade50, Colors.blue.shade100]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: isDark ? Colors.black38 : Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 28),
              const SizedBox(width: 8),
              Text('Category Winners', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            ],
          ),
          const SizedBox(height: 12),
          _buildWinnerItem('💾 Most Storage', maxStorage.name, '${maxStorage.storageOptions.last >= 1024 ? maxStorage.storageOptions.last ~/ 1024 : maxStorage.storageOptions.last}${maxStorage.storageOptions.last >= 1024 ? 'TB' : 'GB'}', isDark),
          if (maxBattery != null)
            _buildWinnerItem('🔋 Best Battery', maxBattery.name, '${maxBattery.batteryHours} hours', isDark),
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
            child: Text(category, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800)),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                Text(value, style: TextStyle(fontSize: 11, color: isDark ? Colors.green.shade300 : Colors.green.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildComparisonText() {
    final buffer = StringBuffer();
    buffer.writeln('💻 Laptop Comparison\n');
    buffer.writeln('Comparing ${laptops.length} Laptops:\n');
    for (var l in laptops) {
      buffer.writeln('${l.name}:');
      buffer.writeln('  CPU: ${l.processor}');
      buffer.writeln('  Display: ${l.display}');
      buffer.writeln('  RAM: ${l.ramOptions.map((r) => '${r}GB').join(', ')}');
      buffer.writeln('  Storage: ${l.storageOptions.map((s) => s >= 1024 ? '${s ~/ 1024}TB' : '${s}GB').join(', ')}');
      buffer.writeln('');
    }
    final maxStorage = laptops.reduce((a, b) => a.storageOptions.last > b.storageOptions.last ? a : b);
    final minPrice = laptops.reduce((a, b) => a.price < b.price ? a : b);
    buffer.writeln('🏆 Winners:');
    buffer.writeln('  Most Storage: ${maxStorage.name}');
    buffer.writeln('  Best Price: ${minPrice.name} (${AppSettings.formatPrice(minPrice.price.toDouble())})');
    buffer.writeln('\nShared from Tech Compare App');
    return buffer.toString();
  }
}

