import 'package:flutter/material.dart';
import '../models/watch.dart';
import '../utils/settings.dart';

class WatchDetailScreen extends StatefulWidget {
  final Watch watch;

  const WatchDetailScreen({super.key, required this.watch});

  @override
  State<WatchDetailScreen> createState() => _WatchDetailScreenState();
}

class _WatchDetailScreenState extends State<WatchDetailScreen> {
  late bool isFavorite;
  String? selectedColor;

  @override
  void initState() {
    super.initState();
    isFavorite = AppSettings.isFavorite('watch_${widget.watch.name}');
    selectedColor = widget.watch.colors.first;
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      AppSettings.toggleFavorite('watch_${widget.watch.name}');
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
          widget.watch.name,
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
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                      : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                ),
              ),
              child: Center(
                child: Text(
                  widget.watch.image,
                  style: const TextStyle(fontSize: 100),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.watch.name,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      Text(
                        '\$${widget.watch.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSpecCard(isDark, 'Battery Life', '${widget.watch.batteryLife} hours', Icons.battery_charging_full),
                  const SizedBox(height: 12),
                  _buildSpecCard(isDark, 'Chip', widget.watch.chip, Icons.memory),
                  const SizedBox(height: 12),
                  _buildSpecCard(isDark, 'Display', widget.watch.display, Icons.display_settings),
                  if (widget.watch.caseSize != null) ...[
                    const SizedBox(height: 12),
                    _buildSpecCard(isDark, 'Case Size', widget.watch.caseSize!, Icons.watch),
                  ],
                  if (widget.watch.waterResistance != null) ...[
                    const SizedBox(height: 12),
                    _buildSpecCard(isDark, 'Water Resistance', widget.watch.waterResistance!, Icons.water_drop),
                  ],
                  if (widget.watch.hasGPS == true) ...[
                    const SizedBox(height: 12),
                    _buildSpecCard(isDark, 'GPS', 'Yes', Icons.location_on),
                  ],
                  if (widget.watch.hasCellular == true) ...[
                    const SizedBox(height: 12),
                    _buildSpecCard(isDark, 'Cellular', 'Yes', Icons.signal_cellular_alt),
                  ],
                  if (widget.watch.hasECG == true) ...[
                    const SizedBox(height: 12),
                    _buildSpecCard(isDark, 'ECG', 'Yes', Icons.favorite),
                  ],
                  if (widget.watch.colors.length > 1) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Colors',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: widget.watch.colors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selectedColor == color
                                  ? (isDark ? const Color(0xFF6366F1) : const Color(0xFF4A90E2))
                                  : (isDark ? const Color(0xFF2D3142) : Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selectedColor == color ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              color,
                              style: TextStyle(
                                color: selectedColor == color
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : Colors.black87),
                                fontWeight: selectedColor == color ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecCard(bool isDark, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3142) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6366F1)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

