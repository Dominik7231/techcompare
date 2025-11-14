import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionText extends StatelessWidget {
  final TextStyle? style;
  final String label;

  const VersionText({super.key, this.style, this.label = 'Version:'});

  Future<String> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadVersion(),
      builder: (context, snapshot) {
        final version = snapshot.data;
        final text = version == null ? '$label …' : '$label $version';
        return Text(text, style: style);
      },
    );
  }
}

