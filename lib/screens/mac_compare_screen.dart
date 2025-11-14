import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/mac.dart';
import '../utils/settings.dart';
import '../utils/ai_usage_helper.dart';
import '../services/ai_assistant.dart';

class MacCompareScreen extends StatefulWidget {
  final List<Mac> macs;

  const MacCompareScreen({super.key, required this.macs});

  @override
  State<MacCompareScreen> createState() => _MacCompareScreenState();
}

class _MacCompareScreenState extends State<MacCompareScreen> {
  String? _aiComparison;
  bool _isLoadingAI = false;

  Future<void> _getAIComparison() async {
    if (widget.macs.length != 2) return;

    // Check AI usage and show ad if needed
    final canProceed = await AIUsageHelper.checkAndHandleAIUsage(context);
    if (!canProceed) {
      return;
    }

    setState(() {
      _isLoadingAI = true;
    });

    final comparison = await AIAssistant.compareMacs(
      widget.macs[0],
      widget.macs[1],
    );

    // Record AI usage after successful call
    await AIUsageHelper.recordAIUsage();

    setState(() {
      _aiComparison = comparison;
      _isLoadingAI = false;
    });

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.psychology, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text('AI Comparison'),
            ],
          ),
          content: SingleChildScrollView(child: Text(_aiComparison ?? '')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

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
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF2D3142),
        ),
        title: Text(
          'Compare Macs',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.macs.length == 2)
            IconButton(
              icon: _isLoadingAI
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.psychology),
              onPressed: _isLoadingAI ? null : _getAIComparison,
              tooltip: 'AI Comparison',
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareOptions,
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
              widget.macs.map((m) => m.chip).toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Display',
              Icons.desktop_mac,
              widget.macs.map((m) => m.display).toList(),
              isDark,
            ),
            _buildComparisonRow(
              'CPU',
              Icons.speed,
              widget.macs.map((m) => m.cpuDetails).toList(),
              isDark,
            ),
            _buildComparisonRow(
              'GPU',
              Icons.videogame_asset,
              widget.macs.map((m) => m.gpuDetails).toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Neural Engine',
              Icons.psychology,
              widget.macs.map((m) => m.neuralEngine).toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Display Tech',
              Icons.tv,
              widget.macs.map((m) => m.displayTech).toList(),
              isDark,
            ),
            _buildNumericRow(
              'Refresh Rate',
              Icons.refresh,
              widget.macs.map((m) => m.refreshRate ?? 0).toList(),
              'Hz',
              isDark,
            ),
            _buildNumericRow(
              'Peak Brightness',
              Icons.brightness_high,
              widget.macs.map((m) => m.peakBrightness ?? 0).toList(),
              'nits',
              isDark,
            ),
            _buildComparisonRow(
              'RAM Options',
              Icons.memory,
              widget.macs
                  .map((m) => m.ramOptions.map((r) => '${r}GB').join(', '))
                  .toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Storage',
              Icons.storage,
              widget.macs
                  .map(
                    (m) => m.storageOptions
                        .map((s) => s >= 1024 ? '${s ~/ 1024}TB' : '${s}GB')
                        .join(', '),
                  )
                  .toList(),
              isDark,
            ),
            _buildNumericRow(
              'Battery Life',
              Icons.battery_charging_full,
              widget.macs.map((m) => m.batteryHours ?? 0).toList(),
              'hours',
              isDark,
            ),
            _buildComparisonRow(
              'Ports',
              Icons.usb,
              widget.macs.map((m) => m.ports ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Form Factor',
              Icons.computer,
              widget.macs.map((m) => m.formFactor ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Price',
              Icons.attach_money,
              widget.macs
                  .map((m) => AppSettings.formatPrice(m.price.toDouble()))
                  .toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Release Year',
              Icons.calendar_today,
              widget.macs.map((m) => m.releaseYear).toList(),
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

  void _showShareOptions() {
    final title = 'Mac Comparison: ${widget.macs.map((m) => m.name).join(' vs ')}';
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
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied tweet text to clipboard')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildTweetText() {
    final names = widget.macs.map((m) => m.name).join(' vs ');
    final maxRam = widget.macs.reduce((a, b) => a.ramOptions.last > b.ramOptions.last ? a : b);
    final maxStorage = widget.macs.reduce((a, b) => a.storageOptions.last > b.storageOptions.last ? a : b);
    final text = 'Mac Comparison: $names\n'
        'Max RAM: ${maxRam.name}\n'
        'Max Storage: ${maxStorage.name}\n'
        '#TechCompare';
    return text;
  }

  String _buildMarkdownText() {
    final buffer = StringBuffer();
    buffer.writeln('# Mac Comparison');
    buffer.writeln('');
    buffer.writeln('**Models:** ${widget.macs.map((m) => m.name).join(' vs ')}');
    buffer.writeln('');
    for (var mac in widget.macs) {
      buffer.writeln('- ${mac.name}:');
      buffer.writeln('  - Chip: ${mac.chip}');
      buffer.writeln('  - Display: ${mac.display}');
      buffer.writeln('  - CPU: ${mac.cpuDetails}');
      buffer.writeln('  - GPU: ${mac.gpuDetails}');
      buffer.writeln('  - Neural Engine: ${mac.neuralEngine}');
      buffer.writeln('  - RAM Options: ${mac.ramOptions.map((r) => '${r}GB').join(', ')}');
      buffer.writeln('  - Storage Options: ${mac.storageOptions.map((s) => s >= 1024 ? '${s~/1024}TB' : '${s}GB').join(', ')}');
    }
    buffer.writeln('');
    buffer.writeln('Shared from Tech Compare');
    return buffer.toString();
  }

  String _buildQrPayload() {
    final names = widget.macs.map((m) => m.name).toList();
    final data = {
      'type': 'comparison',
      'category': 'Macs',
      'names': names,
    };
    return jsonEncode(data);
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.macs.map((mac) {
          return Expanded(
            child: Column(
              children: [
                Text(mac.image, style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 8),
                Text(
                  mac.name,
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
                  AppSettings.formatPrice(mac.price.toDouble()),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
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
                'Comparison: ${widget.macs.length} Macs',
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
              color: isDark ? Colors.blue.shade800 : Colors.blue.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
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
              color: isDark ? Colors.blue.shade800 : Colors.blue.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
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
              color: isDark ? Colors.blue.shade800 : Colors.blue.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.palette,
                  color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Available Colors',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.macs.length, (index) {
                final mac = widget.macs[index];
                final colors =
                    mac.colors?.split(',').map((c) => c.trim()).toList() ??
                    ['N/A'];
                return Expanded(
                  child: Column(
                    children: colors.map((color) {
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
    final maxStorage = widget.macs.reduce(
      (a, b) =>
          (a.storageOptions.isNotEmpty &&
              b.storageOptions.isNotEmpty &&
              a.storageOptions.last > b.storageOptions.last)
          ? a
          : b,
    );
    final minPrice = widget.macs.reduce((a, b) => a.price < b.price ? a : b);
    final maxBattery =
        widget.macs.where((m) => m.batteryHours != null).isNotEmpty
        ? widget.macs
              .where((m) => m.batteryHours != null)
              .reduce(
                (a, b) => (a.batteryHours ?? 0) > (b.batteryHours ?? 0) ? a : b,
              )
        : null;
    final maxBrightness =
        widget.macs
            .where((m) => m.peakBrightness != null && m.peakBrightness! > 0)
            .isNotEmpty
        ? widget.macs
              .where((m) => m.peakBrightness != null && m.peakBrightness! > 0)
              .reduce(
                (a, b) =>
                    (a.peakBrightness ?? 0) > (b.peakBrightness ?? 0) ? a : b,
              )
        : null;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.purple.shade900, Colors.purple.shade700]
              : [Colors.purple.shade50, Colors.purple.shade100],
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
          if (maxStorage.storageOptions.isNotEmpty)
            _buildWinnerItem(
              '💾 Most Storage',
              maxStorage.name,
              '${maxStorage.storageOptions.last >= 1024 ? maxStorage.storageOptions.last ~/ 1024 : maxStorage.storageOptions.last}${maxStorage.storageOptions.last >= 1024 ? 'TB' : 'GB'}',
              isDark,
            ),
          if (maxBattery != null)
            _buildWinnerItem(
              '🔋 Best Battery',
              maxBattery.name,
              '${maxBattery.batteryHours} hours',
              isDark,
            ),
          if (maxBrightness != null)
            _buildWinnerItem(
              '☀️ Brightest Display',
              maxBrightness.name,
              '${maxBrightness.peakBrightness} nits',
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
    String macName,
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
                  macName,
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
    buffer.writeln('💻 Mac Comparison\n');
    buffer.writeln('Comparing ${widget.macs.length} Macs:\n');

    for (var mac in widget.macs) {
      buffer.writeln('${mac.name}:');
      buffer.writeln('  Chip: ${mac.chip}');
      buffer.writeln('  Display: ${mac.display}');
      buffer.writeln('  CPU: ${mac.cpuDetails}');
      buffer.writeln('  GPU: ${mac.gpuDetails}');
      buffer.writeln(
        '  RAM Options: ${mac.ramOptions.map((r) => '${r}GB').join(', ')}',
      );
      buffer.writeln(
        '  Storage Options: ${mac.storageOptions.map((s) => s >= 1024 ? '${s ~/ 1024}TB' : '${s}GB').join(', ')}',
      );
      buffer.writeln(
        '  Price: ${AppSettings.formatPrice(mac.price.toDouble())}',
      );
      buffer.writeln('  Release Year: ${mac.releaseYear}');
      if (mac.batteryHours != null)
        buffer.writeln('  Battery: ${mac.batteryHours} hours');
      buffer.writeln('');
    }

    final maxStorage = widget.macs.reduce(
      (a, b) =>
          (a.storageOptions.isNotEmpty &&
              b.storageOptions.isNotEmpty &&
              a.storageOptions.last > b.storageOptions.last)
          ? a
          : b,
    );
    final minPrice = widget.macs.reduce((a, b) => a.price < b.price ? a : b);
    final maxBattery =
        widget.macs.where((m) => m.batteryHours != null).isNotEmpty
        ? widget.macs
              .where((m) => m.batteryHours != null)
              .reduce(
                (a, b) => (a.batteryHours ?? 0) > (b.batteryHours ?? 0) ? a : b,
              )
        : null;
    final maxBrightness =
        widget.macs
            .where((m) => m.peakBrightness != null && m.peakBrightness! > 0)
            .isNotEmpty
        ? widget.macs
              .where((m) => m.peakBrightness != null && m.peakBrightness! > 0)
              .reduce(
                (a, b) =>
                    (a.peakBrightness ?? 0) > (b.peakBrightness ?? 0) ? a : b,
              )
        : null;

    buffer.writeln('🏆 Winners:');
    if (maxStorage.storageOptions.isNotEmpty) {
      buffer.writeln(
        '  Most Storage: ${maxStorage.name} (${maxStorage.storageOptions.last >= 1024 ? maxStorage.storageOptions.last ~/ 1024 : maxStorage.storageOptions.last}${maxStorage.storageOptions.last >= 1024 ? 'TB' : 'GB'})',
      );
    }
    if (maxBattery != null) {
      buffer.writeln(
        '  Best Battery: ${maxBattery.name} (${maxBattery.batteryHours} hours)',
      );
    }
    if (maxBrightness != null) {
      buffer.writeln(
        '  Brightest Display: ${maxBrightness.name} (${maxBrightness.peakBrightness} nits)',
      );
    }
    buffer.writeln(
      '  Best Price: ${minPrice.name} (${AppSettings.formatPrice(minPrice.price.toDouble())})',
    );
    buffer.writeln('\nShared from Tech Compare App');

    return buffer.toString();
  }
}
