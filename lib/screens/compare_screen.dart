import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/phone.dart';
import '../utils/settings.dart';
import '../utils/ai_usage_helper.dart';
import '../services/ai_assistant.dart';
import '../secrets.dart' if (dart.library.html) '../secrets_stub.dart';

class CompareScreen extends StatefulWidget {
  final List<Phone> phones;

  const CompareScreen({super.key, required this.phones});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  String? _aiComparison;
  bool _isLoadingAI = false;

  Future<void> _getAIComparison() async {
    if (widget.phones.length != 2) return;

    final key = openRouterApiKey.trim();
    if (key.isEmpty || key == 'YOUR_OPENROUTER_API_KEY_HERE') {
      setState(() {
        _aiComparison = 'AI is not configured. Please add your OpenRouter API key in secrets.dart to enable AI features.';
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
      return;
    }

    // Check AI usage and show ad if needed
    final canProceed = await AIUsageHelper.checkAndHandleAIUsage(context);
    if (!canProceed) {
      return;
    }

    setState(() {
      _isLoadingAI = true;
    });

    final comparison = await AIAssistant.comparePhones(
      widget.phones[0],
      widget.phones[1],
    );

    if (!(comparison.startsWith('AI is not configured') || comparison.startsWith('AI error:') || comparison.startsWith('Error occurred:') || comparison.contains('took too long'))) {
      await AIUsageHelper.recordAIUsage();
    }

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
    final hasAI = openRouterApiKey.trim().isNotEmpty && openRouterApiKey.trim() != 'YOUR_OPENROUTER_API_KEY_HERE';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparison'),
        actions: [
          if (widget.phones.length == 2 && hasAI)
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
              'Brand',
              Icons.business,
              widget.phones.map((p) => p.brand).toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Chip',
              Icons.memory,
              widget.phones.map((p) => p.chip).toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Display',
              Icons.phone_android,
              widget.phones.map((p) => p.display).toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Display Tech',
              Icons.tv,
              widget.phones.map((p) => p.displayTech ?? 'N/A').toList(),
              isDark,
            ),
            _buildNumericRow(
              'Refresh Rate',
              Icons.refresh,
              widget.phones.map((p) => p.refreshRate ?? 0).toList(),
              'Hz',
              isDark,
            ),
            _buildNumericRow(
              'Peak Brightness',
              Icons.brightness_high,
              widget.phones.map((p) => p.peakBrightness ?? 0).toList(),
              'nits',
              isDark,
            ),
            _buildComparisonRow(
              'ProMotion',
              Icons.speed,
              widget.phones
                  .map(
                    (p) => p.hasProMotion != null && p.hasProMotion!
                        ? 'Yes'
                        : 'No',
                  )
                  .toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Always-On Display',
              Icons.watch_later,
              widget.phones
                  .map(
                    (p) =>
                        p.hasAlwaysOn != null && p.hasAlwaysOn! ? 'Yes' : 'No',
                  )
                  .toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Dynamic Island',
              Icons.circle,
              widget.phones
                  .map(
                    (p) => p.hasDynamicIsland != null && p.hasDynamicIsland!
                        ? 'Yes'
                        : 'No',
                  )
                  .toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Camera',
              Icons.camera_alt,
              widget.phones.map((p) => p.camera).toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Main Camera',
              Icons.camera,
              widget.phones.map((p) => p.mainCameraDetails ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Ultra Wide',
              Icons.camera_alt,
              widget.phones
                  .map((p) => p.ultraWideCameraDetails ?? 'N/A')
                  .toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Telephoto',
              Icons.zoom_in,
              widget.phones.map((p) => p.telephotoDetails ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Front Camera',
              Icons.camera_front,
              widget.phones.map((p) => p.frontCamera ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Video Capabilities',
              Icons.videocam,
              widget.phones.map((p) => p.videoCapabilities ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'CPU Details',
              Icons.speed,
              widget.phones.map((p) => p.cpuDetails ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'GPU Details',
              Icons.videogame_asset,
              widget.phones.map((p) => p.gpuDetails ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Neural Engine',
              Icons.psychology,
              widget.phones.map((p) => p.neuralEngine ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Process Tech',
              Icons.precision_manufacturing,
              widget.phones.map((p) => p.processTech ?? 'N/A').toList(),
              isDark,
            ),
            _buildNumericRow(
              'RAM',
              Icons.memory,
              widget.phones.map((p) => p.ram ?? 0).toList(),
              'GB',
              isDark,
            ),
            _buildComparisonRow(
              'Storage',
              Icons.storage,
              widget.phones
                  .map((p) => p.storageOptions.map((s) => '${s}GB').join(', '))
                  .toList(),
              isDark,
            ),
            _buildNumericRow(
              'Battery',
              Icons.battery_charging_full,
              widget.phones.map((p) => p.battery).toList(),
              'mAh',
              isDark,
            ),
            _buildNumericRow(
              'Video Playback',
              Icons.play_circle,
              widget.phones.map((p) => p.videoPlaybackHours ?? 0).toList(),
              'hours',
              isDark,
            ),
            _buildNumericRow(
              'Charging Power',
              Icons.bolt,
              widget.phones.map((p) => p.chargingWattage ?? 0).toList(),
              'W',
              isDark,
            ),
            _buildComparisonRow(
              'Wireless Charging',
              Icons.battery_charging_full,
              widget.phones
                  .map(
                    (p) =>
                        p.hasWirelessCharging != null && p.hasWirelessCharging!
                        ? 'Yes'
                        : 'No',
                  )
                  .toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Port',
              Icons.usb,
              widget.phones.map((p) => p.port ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'USB Version',
              Icons.usb,
              widget.phones.map((p) => p.usbVersion ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              '5G Support',
              Icons.signal_cellular_alt,
              widget.phones.map((p) => p.has5G ? 'Yes' : 'No').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Wi-Fi',
              Icons.wifi,
              widget.phones.map((p) => p.wifi ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Bluetooth',
              Icons.bluetooth,
              widget.phones.map((p) => p.bluetooth ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'IP Protection',
              Icons.water_drop,
              widget.phones.map((p) => p.ipProtection ?? 'N/A').toList(),
              isDark,
            ),
            _buildNumericRow(
              'Weight',
              Icons.scale,
              widget.phones.map((p) => p.weight ?? 0).toList(),
              'g',
              isDark,
            ),
            _buildComparisonRow(
              'Dimensions',
              Icons.straighten,
              widget.phones.map((p) => p.dimensions ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Material',
              Icons.layers,
              widget.phones.map((p) => p.material ?? 'N/A').toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Action Button',
              Icons.radio_button_checked,
              widget.phones
                  .map(
                    (p) => p.hasActionButton != null && p.hasActionButton!
                        ? 'Yes'
                        : 'No',
                  )
                  .toList(),
              isDark,
            ),
            _buildComparisonRow(
              'Release Year',
              Icons.calendar_today,
              widget.phones.map((p) => p.releaseYear ?? 'N/A').toList(),
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
        children: widget.phones.map((phone) {
          return Expanded(
            child: Column(
              children: [
                Text(phone.image, style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 8),
                Text(
                  phone.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppSettings.formatPrice(phone.price),
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

  Future<void> _postOnX(String tweetText) async {
    final encodedText = Uri.encodeComponent(tweetText);
    final xUrl = Uri.parse('https://x.com/intent/tweet?text=$encodedText');
    
    try {
      if (await canLaunchUrl(xUrl)) {
        await launchUrl(xUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open X. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening X: $e')),
        );
      }
    }
  }

  void _showShareOptions() {
    final title = 'Phone Comparison: ${widget.phones.map((p) => p.name).join(' vs ')}';
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
                  _postOnX(plain);
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
                        width: 260,
                        height: 260,
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
    final names = widget.phones.map((p) => p.name).join(' vs ');
    final maxStorage = widget.phones.reduce((a, b) =>
        (a.storageOptions.isNotEmpty ? a.storageOptions.last : 0) >
        (b.storageOptions.isNotEmpty ? b.storageOptions.last : 0) ? a : b);
    final maxBattery = widget.phones.reduce((a, b) => a.battery > b.battery ? a : b);
    final minPrice = widget.phones.reduce((a, b) => a.price < b.price ? a : b);
    final text = 'Phone Comparison: $names\n'
        'Storage: ${maxStorage.name} wins\n'
        'Battery: ${maxBattery.name} wins\n'
        'Best Price: ${minPrice.name}\n'
        '#TechCompare';
    return text;
  }

  String _buildMarkdownText() {
    final buffer = StringBuffer();
    buffer.writeln('# Phone Comparison');
    buffer.writeln('');
    buffer.writeln('**Models:** ${widget.phones.map((p) => p.name).join(' vs ')}');
    buffer.writeln('');
    for (var phone in widget.phones) {
      buffer.writeln('- ${phone.name}:');
      buffer.writeln('  - Chip: ${phone.chip}');
      buffer.writeln('  - Display: ${phone.display}');
      buffer.writeln('  - Camera: ${phone.camera}');
      buffer.writeln('  - Storage: ${phone.storageOptions.map((s) => '${s}GB').join(', ')}');
      buffer.writeln('  - Battery: ${phone.battery} mAh');
      if (phone.ram != null) buffer.writeln('  - RAM: ${phone.ram} GB');
      if (phone.releaseYear != null) buffer.writeln('  - Release Year: ${phone.releaseYear}');
      if (phone.colors.isNotEmpty) buffer.writeln('  - Colors: ${phone.colors.join(', ')}');
      if (phone.port != null) buffer.writeln('  - Port: ${phone.port}');
      if (phone.usbVersion != null) buffer.writeln('  - USB: ${phone.usbVersion}');
      if (phone.wifi != null) buffer.writeln('  - Wi-Fi: ${phone.wifi}');
      if (phone.bluetooth != null) buffer.writeln('  - Bluetooth: ${phone.bluetooth}');
    }
    buffer.writeln('');
    buffer.writeln('Shared from Tech Compare');
    return buffer.toString();
  }

  String _buildQrPayload() {
    final names = widget.phones.map((p) => p.name).toList();
    final data = {
      'type': 'comparison',
      'category': 'Phones',
      'names': names,
    };
    return jsonEncode(data);
  }

  Widget _buildSummary(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.shade300,
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
                'Comparison: ${widget.phones.length} phones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
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
        color: Theme.of(context).colorScheme.surface,
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
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
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
                        color: Theme.of(context).colorScheme.onSurface,
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
    final allEqual = values.every((v) => v == maxValue);

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
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
                final isBest = value == maxValue;
                final isWorst = !allEqual && value == minValue && value != maxValue;

                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isBest
                          ? Theme.of(context).colorScheme.tertiary.withOpacity(0.18)
                          : isWorst
                              ? Theme.of(context).colorScheme.error.withOpacity(0.18)
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$value $unit',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isBest
                                ? Theme.of(context).colorScheme.tertiary
                                : isWorst
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (isBest && !allEqual)
                          Icon(
                            Icons.emoji_events,
                            color: Theme.of(context).colorScheme.tertiary,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.shade300,
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
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Available Colors',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.phones.length, (index) {
                final phone = widget.phones[index];
                return Expanded(
                  child: Column(
                    children: phone.colors.map((color) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          color,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurface,
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
    final storageValues = widget.phones
        .map((p) => p.storageOptions.isNotEmpty ? p.storageOptions.last : 0)
        .toList();
    final maxStorageVal = storageValues.reduce((a, b) => a > b ? a : b);
    final storageWinners = widget.phones
        .where((p) => (p.storageOptions.isNotEmpty ? p.storageOptions.last : 0) == maxStorageVal)
        .toList();
    final maxBatteryVal = widget.phones.map((p) => p.battery).reduce((a, b) => a > b ? a : b);
    final batteryWinners = widget.phones.where((p) => p.battery == maxBatteryVal).toList();
    final minPriceVal = widget.phones.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    final priceWinners = widget.phones.where((p) => p.price == minPriceVal).toList();
    final maxBrightness =
        widget.phones
            .where((p) => p.peakBrightness != null && p.peakBrightness! > 0)
            .isNotEmpty
        ? widget.phones
              .where((p) => p.peakBrightness != null && p.peakBrightness! > 0)
              .reduce(
                (a, b) =>
                    (a.peakBrightness ?? 0) > (b.peakBrightness ?? 0) ? a : b,
              )
        : null;
    final lightest =
        widget.phones.where((p) => p.weight != null && p.weight! > 0).isNotEmpty
        ? widget.phones
              .where((p) => p.weight != null && p.weight! > 0)
              .reduce((a, b) => (a.weight ?? 9999) < (b.weight ?? 9999) ? a : b)
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildWinnerItem(
            '💾 Most Storage',
            storageWinners.map((p) => p.name).join(' • '),
            '$maxStorageVal GB',
            isDark,
          ),
          _buildWinnerItem(
            '🔋 Biggest Battery',
            batteryWinners.map((p) => p.name).join(' • '),
            '$maxBatteryVal mAh',
            isDark,
          ),
          if (maxBrightness != null)
            _buildWinnerItem(
              '☀️ Brightest Display',
              maxBrightness.name,
              '${maxBrightness.peakBrightness} nits',
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
            priceWinners.map((p) => p.name).join(' • '),
            AppSettings.formatPrice(minPriceVal),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerItem(
    String category,
    String phoneName,
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
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phoneName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.tertiary,
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
    buffer.writeln('📱 Phone Comparison\n');
    buffer.writeln('Comparing ${widget.phones.length} phones:\n');

    for (var phone in widget.phones) {
      buffer.writeln('${phone.name}:');
      buffer.writeln('  Chip: ${phone.chip}');
      buffer.writeln('  Display: ${phone.display}');
      buffer.writeln('  Camera: ${phone.camera}');
      buffer.writeln(
        '  Storage: ${phone.storageOptions.map((s) => '${s}GB').join(', ')}',
      );
      buffer.writeln('  Battery: ${phone.battery} mAh');
      buffer.writeln('  Price: ${AppSettings.formatPrice(phone.price)}');
      if (phone.ram != null) buffer.writeln('  RAM: ${phone.ram} GB');
      if (phone.releaseYear != null) buffer.writeln('  Release Year: ${phone.releaseYear}');
      if (phone.colors.isNotEmpty) buffer.writeln('  Colors: ${phone.colors.join(', ')}');
      if (phone.port != null) buffer.writeln('  Port: ${phone.port}');
      if (phone.usbVersion != null) buffer.writeln('  USB: ${phone.usbVersion}');
      if (phone.wifi != null) buffer.writeln('  Wi-Fi: ${phone.wifi}');
      if (phone.bluetooth != null) buffer.writeln('  Bluetooth: ${phone.bluetooth}');
      buffer.writeln('');
    }

    final maxStorage = widget.phones.reduce((a, b) =>
        (a.storageOptions.isNotEmpty ? a.storageOptions.last : 0) >
        (b.storageOptions.isNotEmpty ? b.storageOptions.last : 0) ? a : b);
    final maxBattery = widget.phones.reduce(
      (a, b) => a.battery > b.battery ? a : b,
    );
    final minPrice = widget.phones.reduce((a, b) => a.price < b.price ? a : b);

    buffer.writeln('🏆 Winners:');
    buffer.writeln(
      '  Most Storage: ${maxStorage.name} (${maxStorage.storageOptions.last} GB)',
    );
    buffer.writeln(
      '  Biggest Battery: ${maxBattery.name} (${maxBattery.battery} mAh)',
    );
    buffer.writeln(
      '  Best Price: ${minPrice.name} (${AppSettings.formatPrice(minPrice.price)})',
    );
    buffer.writeln('\nShared from Tech Compare App');

    return buffer.toString();
  }
}
