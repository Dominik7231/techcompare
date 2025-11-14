import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/ipad.dart';
import '../utils/settings.dart';

class iPadDetailScreen extends StatefulWidget {
  final iPad ipad;

  const iPadDetailScreen({super.key, required this.ipad});

  @override
  State<iPadDetailScreen> createState() => _iPadDetailScreenState();
}

class _iPadDetailScreenState extends State<iPadDetailScreen> {
  late bool isFavorite;
  void _shareIpad() {
    final specs = [
      'Display: ${widget.ipad.display}',
      'Chip: ${widget.ipad.chip}',
      'CPU: ${widget.ipad.cpuDetails}',
      'GPU: ${widget.ipad.gpuDetails}',
      'RAM: ${widget.ipad.ramOptions.map((r) => '${r}GB').join(', ')}',
      'Storage: ${widget.ipad.storageOptions.map((s) => s >= 1024 ? '${s~/1024}TB' : '${s}GB').join(', ')}',
    ].join('\n');
    Share.share('${widget.ipad.name}\n\n$specs', subject: widget.ipad.name);
  }

  @override
  void initState() {
    super.initState();
    isFavorite = AppSettings.isFavorite('ipad_${widget.ipad.name}');
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      AppSettings.toggleFavorite('ipad_${widget.ipad.name}');
    });
  }

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
        title: Text(
          widget.ipad.name,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : (isDark ? Colors.white70 : Colors.black54),
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: Icon(Icons.share, color: isDark ? Colors.white70 : Colors.black54),
            onPressed: _shareIpad,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // iPad Image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF9B59B6), const Color(0xFF8E44AD)]
                      : [const Color(0xFF9B59B6), const Color(0xFFAB6BCF)],
                ),
              ),
              child: Center(
                child: Text(
                  widget.ipad.image,
                  style: const TextStyle(fontSize: 100),
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
                          widget.ipad.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        '\$${widget.ipad.price}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9B59B6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Released: ${widget.ipad.releaseYear}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Specifications
                  _buildSection('Display', widget.ipad.display, isDark),
                  _buildSection('Chip', widget.ipad.chip, isDark),
                  _buildSection('CPU', widget.ipad.cpuDetails, isDark),
                  _buildSection('GPU', widget.ipad.gpuDetails, isDark),
                  _buildSection('Neural Engine', widget.ipad.neuralEngine, isDark),
                  _buildSection(
                    'RAM Options',
                    widget.ipad.ramOptions.map((ram) => '${ram}GB').join(', '),
                    isDark,
                  ),
                  _buildSection(
                    'Storage Options',
                    widget.ipad.storageOptions.map((s) => s >= 1024 ? '${s~/1024}TB' : '${s}GB').join(', '),
                    isDark,
                  ),
                  if (widget.ipad.refreshRate != null)
                    _buildSection('Refresh Rate', '${widget.ipad.refreshRate}Hz', isDark),
                  if (widget.ipad.peakBrightness != null)
                    _buildSection('Brightness', '${widget.ipad.peakBrightness} nits', isDark),
                  if (widget.ipad.batteryHours != null)
                    _buildSection('Battery Life', 'Up to ${widget.ipad.batteryHours} hours', isDark),
                  if (widget.ipad.ports != null)
                    _buildSection('Ports', widget.ipad.ports!, isDark),
                  if (widget.ipad.formFactor != null)
                    _buildSection('Form Factor', widget.ipad.formFactor!, isDark),
                  if (widget.ipad.colors != null)
                    _buildSection('Colors', widget.ipad.colors!, isDark),
                  if (widget.ipad.has5G != null)
                    _buildSection('5G Support', widget.ipad.has5G! ? 'Yes' : 'No', isDark),
                  if (widget.ipad.camera != null)
                    _buildSection('Camera', widget.ipad.camera!, isDark),
                  if (widget.ipad.weight != null)
                    _buildSection('Weight', '${widget.ipad.weight}g', isDark),
                  if (widget.ipad.dimensions != null)
                    _buildSection('Dimensions', widget.ipad.dimensions!, isDark),
                  if (widget.ipad.hasApplePencil != null && widget.ipad.hasApplePencil!)
                    _buildSection(
                      'Apple Pencil',
                      widget.ipad.applePencilVersion ?? 'Supported',
                      isDark,
                    ),
                  if (widget.ipad.hasMagicKeyboard != null && widget.ipad.hasMagicKeyboard!)
                    _buildSection('Magic Keyboard', 'Supported', isDark),
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

