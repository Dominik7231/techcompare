import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/headphones.dart';
import '../utils/settings.dart';

class HeadphonesCompareScreen extends StatelessWidget {
  final List<Headphones> headphones;

  const HeadphonesCompareScreen({super.key, required this.headphones});

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
        title: Text('Compare Headphones', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF2D3142), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () => _showShareOptions(context), tooltip: 'Share comparison'),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(isDark),
            _buildSummary(isDark),

            _buildComparisonRow('Type', Icons.headset, headphones.map((h) => h.type).toList(), isDark),
            _buildNumericRow('Battery Life', Icons.battery_charging_full, headphones.map((h) => h.batteryLife).toList(), 'hours', isDark),
            _buildComparisonRow('Noise Cancellation', Icons.noise_control_off, headphones.map((h) => h.noiseCancellation ?? 'None').toList(), isDark),
            _buildComparisonRow('Wireless', Icons.wifi, headphones.map((h) => h.hasWireless != null && h.hasWireless! ? 'Yes' : 'No').toList(), isDark),
            _buildComparisonRow('Connectivity', Icons.bluetooth, headphones.map((h) => h.connectivity ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Bluetooth', Icons.bluetooth, headphones.map((h) => h.bluetooth ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Driver Size', Icons.speaker, headphones.map((h) => h.driverSize != null ? '${h.driverSize}mm' : 'N/A').toList(), isDark),
            _buildComparisonRow('Frequency Response', Icons.graphic_eq, headphones.map((h) => h.frequencyResponse ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Impedance', Icons.electrical_services, headphones.map((h) => h.impedance != null ? '${h.impedance}Ω' : 'N/A').toList(), isDark),
            _buildComparisonRow('Microphone', Icons.mic, headphones.map((h) => h.hasMicrophone != null && h.hasMicrophone! ? (h.microphone ?? 'Yes') : 'No').toList(), isDark),
            _buildComparisonRow('Charging Time', Icons.timer, headphones.map((h) => h.chargingTime != null ? '${h.chargingTime}min' : 'N/A').toList(), isDark),
            _buildComparisonRow('Water Resistance', Icons.water_drop, headphones.map((h) => h.waterResistance ?? 'None').toList(), isDark),
            _buildComparisonRow('Audio Codec', Icons.music_note, headphones.map((h) => h.audioCodec ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Quick Charge', Icons.flash_on, headphones.map((h) => h.hasQuickCharge != null && h.hasQuickCharge! ? 'Yes' : 'No').toList(), isDark),
            _buildComparisonRow('Case Type', Icons.cases, headphones.map((h) => h.caseType ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Weight', Icons.scale, headphones.map((h) => h.weight != null ? '${h.weight}g' : 'N/A').toList(), isDark),
            _buildComparisonRow('Dimensions', Icons.straighten, headphones.map((h) => h.dimensions ?? 'N/A').toList(), isDark),
            _buildComparisonRow('Price', Icons.attach_money, headphones.map((h) => AppSettings.formatPrice(h.price.toDouble())).toList(), isDark),
            _buildComparisonRow('Release Year', Icons.calendar_today, headphones.map((h) => h.releaseYear ?? 'N/A').toList(), isDark),
            _buildColorsComparison(isDark),
            _buildWinnerSummary(isDark),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    final title = 'Headphones Comparison: ${headphones.map((h) => h.name).join(' vs ')}';
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
    final names = headphones.map((h) => h.name).join(' vs ');
    final maxBattery = headphones.reduce((a, b) => a.batteryLife > b.batteryLife ? a : b);
    final text = 'Headphones Comparison: $names\n'
      'Longest Battery: ${maxBattery.name}\n'
      '#TechCompare';
    return text;
  }

  String _buildMarkdownText() {
    final buffer = StringBuffer();
    buffer.writeln('# Headphones Comparison');
    buffer.writeln('');
    buffer.writeln('**Models:** ${headphones.map((h) => h.name).join(' vs ')}');
    buffer.writeln('');
    for (var h in headphones) {
      buffer.writeln('- ${h.name}:');
      buffer.writeln('  - Type: ${h.type}');
      buffer.writeln('  - Battery Life: ${h.batteryLife} hours');
      buffer.writeln('  - Connectivity: ${h.connectivity ?? 'N/A'}');
    }
    buffer.writeln('');
    buffer.writeln('Shared from Tech Compare');
    return buffer.toString();
  }

  String _buildQrPayload() {
    final names = headphones.map((h) => h.name).toList();
    final data = {'type': 'comparison', 'category': 'Headphones', 'names': names};
    return jsonEncode(data);
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: isDark ? [Colors.teal.shade900, Colors.teal.shade700] : [Colors.teal.shade50, Colors.teal.shade100])),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: headphones.map((h) {
          return Expanded(
            child: Column(children: [
              Text(h.image, style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 8),
              Text(h.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(AppSettings.formatPrice(h.price.toDouble()), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.teal.shade200 : Colors.teal.shade700)),
            ]),
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
      child: Row(children: [Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 28), const SizedBox(width: 8), Text('Comparison: ${headphones.length} Headphones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))]),
    );
  }

  Widget _buildComparisonRow(String title, IconData icon, List<String> values, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: isDark ? Colors.black38 : Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: isDark ? Colors.teal.shade800 : Colors.teal.shade100, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Row(children: [Icon(icon, color: isDark ? Colors.teal.shade200 : Colors.teal.shade700), const SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.teal.shade200 : Colors.teal.shade700))]),
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
          decoration: BoxDecoration(color: isDark ? Colors.teal.shade800 : Colors.teal.shade100, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Row(children: [Icon(icon, color: isDark ? Colors.teal.shade200 : Colors.teal.shade700), const SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.teal.shade200 : Colors.teal.shade700))]),
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
          decoration: BoxDecoration(color: isDark ? Colors.teal.shade800 : Colors.teal.shade100, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Row(children: [Icon(Icons.palette, color: isDark ? Colors.teal.shade200 : Colors.teal.shade700), const SizedBox(width: 8), Text('Available Colors', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.teal.shade200 : Colors.teal.shade700))]),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: List.generate(headphones.length, (index) { final h = headphones[index]; return Expanded(child: Column(children: h.colors.map((color) { return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text(color, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade300 : Colors.black87))); }).toList())); })),
        ),
      ]),
    );
  }

  Widget _buildWinnerSummary(bool isDark) {
    final maxBattery = headphones.reduce((a, b) => a.batteryLife > b.batteryLife ? a : b);
    final minPrice = headphones.reduce((a, b) => a.price < b.price ? a : b);
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: LinearGradient(colors: isDark ? [Colors.teal.shade900, Colors.teal.shade700] : [Colors.teal.shade50, Colors.teal.shade100]), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: isDark ? Colors.black38 : Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 28), const SizedBox(width: 8), Text('Category Winners', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))]),
        const SizedBox(height: 12),
        _buildWinnerItem('🔋 Best Battery Life', maxBattery.name, '${maxBattery.batteryLife} hours', isDark),
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
    buffer.writeln('🎧 Headphones Comparison\n');
    buffer.writeln('Comparing ${headphones.length} Headphones:\n');
    for (var h in headphones) {
      buffer.writeln('${h.name}:');
      buffer.writeln('  Type: ${h.type}');
      buffer.writeln('  Battery Life: ${h.batteryLife} hours');
      buffer.writeln('  Connectivity: ${h.connectivity ?? 'N/A'}');
      buffer.writeln('');
    }
    final maxBattery = headphones.reduce((a, b) => a.batteryLife > b.batteryLife ? a : b);
    final minPrice = headphones.reduce((a, b) => a.price < b.price ? a : b);
    buffer.writeln('🏆 Winners:');
    buffer.writeln('  Best Battery Life: ${maxBattery.name} (${maxBattery.batteryLife} hours)');
    buffer.writeln('  Best Price: ${minPrice.name} (${AppSettings.formatPrice(minPrice.price.toDouble())})');
    buffer.writeln('\nShared from Tech Compare App');
    return buffer.toString();
  }
}

