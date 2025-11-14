import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/mac.dart';

class MacDetailScreen extends StatelessWidget {
  final Mac mac;

  const MacDetailScreen({super.key, required this.mac});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    void shareMac() {
      final specs = [
        'Display: ${mac.display}',
        'Chip: ${mac.chip}',
        'CPU: ${mac.cpuDetails}',
        'GPU: ${mac.gpuDetails}',
        if (mac.neuralEngine != null) 'Neural Engine: ${mac.neuralEngine}',
        'RAM: ${mac.ramOptions.map((r) => '${r}GB').join(', ')}',
        'Storage: ${mac.storageOptions.map((s) => s >= 1024 ? '${s~/1024}TB' : '${s}GB').join(', ')}',
      ].join('\n');
      Share.share('${mac.name}\n\n$specs', subject: mac.name);
    }

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
        title: Text(
          mac.name,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: isDark ? Colors.white70 : Colors.black54),
            onPressed: shareMac,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mac Image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Center(
                child: Hero(
                  tag: 'mac-${mac.name}',
                  child: Text(
                    mac.image,
                    style: const TextStyle(fontSize: 100),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          mac.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        '\$${mac.price}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Released: ${mac.releaseYear}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Specifications
                  _buildSection('Display', mac.display, isDark),
                  _buildSection('Chip', mac.chip, isDark),
                  _buildSection('CPU', mac.cpuDetails, isDark),
                  _buildSection('GPU', mac.gpuDetails, isDark),
                  _buildSection('Neural Engine', mac.neuralEngine, isDark),
                  _buildSection(
                    'RAM Options',
                    mac.ramOptions.map((ram) => '${ram}GB').join(', '),
                    isDark,
                  ),
                  _buildSection(
                    'Storage Options',
                    mac.storageOptions.map((s) => s >= 1024 ? '${s~/1024}TB' : '${s}GB').join(', '),
                    isDark,
                  ),
                  if (mac.refreshRate != null)
                    _buildSection('Refresh Rate', '${mac.refreshRate}Hz', isDark),
                  if (mac.peakBrightness != null)
                    _buildSection('Brightness', '${mac.peakBrightness} nits', isDark),
                  if (mac.batteryHours != null)
                    _buildSection('Battery Life', 'Up to ${mac.batteryHours} hours', isDark),
                  if (mac.ports != null)
                    _buildSection('Ports', mac.ports!, isDark),
                  if (mac.formFactor != null)
                    _buildSection('Form Factor', mac.formFactor!, isDark),
                  if (mac.colors != null)
                    _buildSection('Colors', mac.colors!, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Divider(
            color: isDark ? Colors.white24 : Colors.black12,
          ),
        ],
      ),
    );
  }
}
