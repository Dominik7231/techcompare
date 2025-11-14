import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/tablet.dart';
import '../utils/settings.dart';

class TabletCompareScreen extends StatelessWidget {
  final List<Tablet> tablets;

  const TabletCompareScreen({super.key, required this.tablets});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF2D3142) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF2D3142)),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF2D3142)),
        title: Text(
          'Compare Tablets',
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF2D3142), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () => _showShareOptions(context), tooltip: 'Share comparison'),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(isDark),
            _buildSummary(isDark),

            _buildComparisonRow('Chip', Icons.memory, tablets.map((t) => t.chip).toList(), isDark),
            _buildComparisonRow('Display', Icons.tablet, tablets.map((t) => t.display).toList(), isDark),
            _buildComparisonRow('Display Tech', Icons.tv, tablets.map((t) => t.displayTech ?? 'N/A').toList(), isDark),
            _buildNumericRow('Refresh Rate', Icons.refresh, tablets.map((t) => t.refreshRate ?? 0).toList(), 'Hz', isDark),
            _buildNumericRow('Peak Brightness', Icons.brightness_high, tablets.map((t) => t.peakBrightness ?? 0).toList(), 'nits', isDark),
            _buildComparisonRow('RAM', Icons.memory, tablets.map((t) => t.ram != null ? '${t.ram}GB' : 'N/A').toList(), isDark),
            _buildComparisonRow('Storage Options', Icons.storage, tablets.map((t) => t.storageOptions.map((s) => s >= 1024 ? '${s ~/ 1024}TB' : '${s}GB').join(', ')).toList(), isDark),
            _buildNumericRow('Battery', Icons.battery_full, tablets.map((t) => t.battery).toList(), 'mAh', isDark),
            _buildComparisonRow('5G Support', Icons.signal_cellular_alt, tablets.map((t) => t.has5G != null && t.has5G! ? 'Yes' : 'No').toList(), isDark),
            _buildComparisonRow('Connectivity', Icons.bluetooth, tablets.map((t) => t.connectivity ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Ports', Icons.usb, tablets.map((t) => t.ports ?? 'N/A').toList(), isDark),
            _buildComparisonRow('OS', Icons.settings, tablets.map((t) => t.os ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Stylus', Icons.edit, tablets.map((t) => t.hasStylus != null && t.hasStylus! ? (t.stylus ?? 'Supported') : 'No').toList(), isDark),
            _buildComparisonRow('Charging', Icons.bolt, tablets.map((t) => t.chargingWattage != null ? '${t.chargingWattage}W' : 'N/A').toList(), isDark),
            _buildComparisonRow('Wireless Charging', Icons.battery_charging_full, tablets.map((t) => t.hasWirelessCharging != null && t.hasWirelessCharging! ? 'Yes' : 'No').toList(), isDark),
            _buildComparisonRow('Weight', Icons.scale, tablets.map((t) => t.weight != null ? '${t.weight}g' : 'N/A').toList(), isDark),
            _buildComparisonRow('Dimensions', Icons.straighten, tablets.map((t) => t.dimensions ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Price', Icons.attach_money, tablets.map((t) => AppSettings.formatPrice(t.price.toDouble())).toList(), isDark),
            _buildComparisonRow('Release Year', Icons.calendar_today, tablets.map((t) => t.releaseYear ?? 'N/A').toList(), isDark),
            _buildColorsComparison(isDark),
            _buildWinnerSummary(isDark),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    final title = 'Tablet Comparison: ${tablets.map((t) => t.name).join(' vs ')}';
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
              ListTile(leading: const Icon(Icons.text_snippet), title: const Text('Share as Plain Text'), onTap: () { Navigator.pop(context); Share.share(plain, subject: title); }),
              ListTile(leading: const Icon(Icons.open_in_new), title: const Text('Share as Tweet (X)'), subtitle: const Text('Optimized for 280 characters'), onTap: () { Navigator.pop(context); Share.share(tweet, subject: title); }),
              ListTile(leading: const Icon(Icons.code), title: const Text('Share as Markdown'), onTap: () { Navigator.pop(context); Share.share(markdown, subject: title); }),
              ListTile(leading: const Icon(Icons.qr_code), title: const Text('Share via QR Code'), onTap: () { Navigator.pop(context); final payload = _buildQrPayload(); showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Scan to Import'), content: SizedBox(width: double.maxFinite, child: Center(child: QrImageView(data: payload, version: QrVersions.auto, size: 220))), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))])); }),
              ListTile(leading: const Icon(Icons.copy), title: const Text('Copy to Clipboard (Tweet)'), onTap: () async { await Clipboard.setData(ClipboardData(text: tweet)); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied tweet text to clipboard'))); }),
            ],
          ),
        );
      },
    );
  }

  String _buildTweetText() {
    final names = tablets.map((t) => t.name).join(' vs ');
    final maxStorage = tablets.reduce((a, b) => a.storageOptions.last > b.storageOptions.last ? a : b);
    var text = 'Tablet Comparison: $names\n'
        'Max Storage: ${maxStorage.name}\n'
        '#TechCompare';
    if (text.length > 280) { text = text.substring(0, 277) + '...'; }
    return text;
  }

  String _buildMarkdownText() {
    final buffer = StringBuffer();
    buffer.writeln('# Tablet Comparison');
    buffer.writeln('');
    buffer.writeln('**Models:** ${tablets.map((t) => t.name).join(' vs ')}');
    buffer.writeln('');
    for (var t in tablets) {
      buffer.writeln('- ${t.name}:');
      buffer.writeln('  - Chip: ${t.chip}');
      buffer.writeln('  - Display: ${t.display}');
      buffer.writeln('  - RAM: ${t.ram ?? 'N/A'}');
      buffer.writeln('  - Storage: ${t.storageOptions.map((s) => s >= 1024 ? '${s~/1024}TB' : '${s}GB').join(', ')}');
    }
    buffer.writeln('');
    buffer.writeln('Shared from Tech Compare');
    return buffer.toString();
  }

  String _buildQrPayload() {
    final names = tablets.map((t) => t.name).toList();
    final data = {'type': 'comparison', 'category': 'Tablets', 'names': names};
    return jsonEncode(data);
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: isDark ? [Colors.purple.shade900, Colors.purple.shade700] : [Colors.purple.shade50, Colors.purple.shade100])),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tablets.map((t) {
          return Expanded(
            child: Column(
              children: [
                Text(t.image, style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 8),
                Text(t.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(AppSettings.formatPrice(t.price.toDouble()), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.purple.shade200 : Colors.purple.shade700)),
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
      decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: isDark ? Colors.black38 : Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2))]),
      child: Row(children: [Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 28), const SizedBox(width: 8), Text('Comparison: ${tablets.length} Tablets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))]),
    );
  }

  Widget _buildComparisonRow(String title, IconData icon, List<String> values, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: isDark ? Colors.black38 : Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: isDark ? Colors.purple.shade800 : Colors.purple.shade100, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Row(children: [Icon(icon, color: isDark ? Colors.purple.shade200 : Colors.purple.shade700), const SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.purple.shade200 : Colors.purple.shade700))]),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: List.generate(values.length, (index) { return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(values[index], textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade300 : Colors.black)))); })),
        ),
      ]),
    );
  }

  Widget _buildNumericRow(String title, IconData icon, List<int> values, String unit, bool isDark) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: isDark ? Colors.black38 : Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: isDark ? Colors.purple.shade800 : Colors.purple.shade100, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Row(children: [Icon(icon, color: isDark ? Colors.purple.shade200 : Colors.purple.shade700), const SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.purple.shade200 : Colors.purple.shade700))]),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: List.generate(values.length, (index) { final value = values[index]; final isBest = value == maxValue && maxValue != minValue && value > 0; final isWorst = value == minValue && maxValue != minValue && value > 0; return Expanded(child: Container(padding: const EdgeInsets.all(8), margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: isBest ? (isDark ? Colors.green.shade900 : Colors.green.shade100) : isWorst ? (isDark ? Colors.red.shade900 : Colors.red.shade100) : null, borderRadius: BorderRadius.circular(8)), child: Column(children: [Text(value > 0 ? '$value $unit' : 'N/A', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isBest ? (isDark ? Colors.green.shade300 : Colors.green.shade700) : isWorst ? (isDark ? Colors.red.shade300 : Colors.red.shade700) : (isDark ? Colors.white : Colors.black))), if (isBest) Icon(Icons.emoji_events, color: isDark ? Colors.green.shade300 : Colors.green.shade700, size: 18)]))); })),
        ),
      ]),
    );
  }

  Widget _buildColorsComparison(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: isDark ? Colors.black38 : Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: isDark ? Colors.purple.shade800 : Colors.purple.shade100, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Row(children: [Icon(Icons.palette, color: isDark ? Colors.purple.shade200 : Colors.purple.shade700), const SizedBox(width: 8), Text('Available Colors', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.purple.shade200 : Colors.purple.shade700))]),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: List.generate(tablets.length, (index) { final tablet = tablets[index]; return Expanded(child: Column(children: tablet.colors.map((color) { return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text(color, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade300 : Colors.black87))); }).toList())); })),
        ),
      ]),
    );
  }

  Widget _buildWinnerSummary(bool isDark) {
    final maxStorage = tablets.reduce((a, b) => a.storageOptions.last > b.storageOptions.last ? a : b);
    final minPrice = tablets.reduce((a, b) => a.price < b.price ? a : b);
    final maxBrightness = tablets.where((t) => t.peakBrightness != null && t.peakBrightness! > 0).isNotEmpty ? tablets.where((t) => t.peakBrightness != null && t.peakBrightness! > 0).reduce((a, b) => (a.peakBrightness ?? 0) > (b.peakBrightness ?? 0) ? a : b) : null;
    final lightest = tablets.where((t) => t.weight != null && t.weight! > 0).isNotEmpty ? tablets.where((t) => t.weight != null && t.weight! > 0).reduce((a, b) => (a.weight ?? 9999) < (b.weight ?? 9999) ? a : b) : null;
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: LinearGradient(colors: isDark ? [Colors.purple.shade900, Colors.purple.shade700] : [Colors.purple.shade50, Colors.purple.shade100]), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: isDark ? Colors.black38 : Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 28), const SizedBox(width: 8), Text('Category Winners', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))]),
        const SizedBox(height: 12),
        _buildWinnerItem('💾 Most Storage', maxStorage.name, '${maxStorage.storageOptions.last >= 1024 ? maxStorage.storageOptions.last ~/ 1024 : maxStorage.storageOptions.last}${maxStorage.storageOptions.last >= 1024 ? 'TB' : 'GB'}', isDark),
        if (maxBrightness != null) _buildWinnerItem('☀️ Brightest Display', maxBrightness.name, '${maxBrightness.peakBrightness} nits', isDark),
        if (lightest != null) _buildWinnerItem('⚖️ Lightest', lightest.name, '${lightest.weight}g', isDark),
        _buildWinnerItem('💰 Best Price', minPrice.name, AppSettings.formatPrice(minPrice.price.toDouble()), isDark),
      ]),
    );
  }

  Widget _buildWinnerItem(String category, String name, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(flex: 2, child: Text(category, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800))),
        Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)), Text(value, style: TextStyle(fontSize: 11, color: isDark ? Colors.green.shade300 : Colors.green.shade700))])),
      ]),
    );
  }

  String _buildComparisonText() {
    final buffer = StringBuffer();
    buffer.writeln('📱 Tablet Comparison\n');
    buffer.writeln('Comparing ${tablets.length} Tablets:\n');
    for (var t in tablets) {
      buffer.writeln('${t.name}:');
      buffer.writeln('  Chip: ${t.chip}');
      buffer.writeln('  Display: ${t.display}');
      buffer.writeln('  RAM: ${t.ram ?? 'N/A'}');
      buffer.writeln('  Storage: ${t.storageOptions.map((s) => s >= 1024 ? '${s ~/ 1024}TB' : '${s}GB').join(', ')}');
      buffer.writeln('');
    }
    final maxStorage = tablets.reduce((a, b) => a.storageOptions.last > b.storageOptions.last ? a : b);
    final minPrice = tablets.reduce((a, b) => a.price < b.price ? a : b);
    buffer.writeln('🏆 Winners:');
    buffer.writeln('  Most Storage: ${maxStorage.name}');
    buffer.writeln('  Best Price: ${minPrice.name} (${AppSettings.formatPrice(minPrice.price.toDouble())})');
    buffer.writeln('\nShared from Tech Compare App');
    return buffer.toString();
  }
}

