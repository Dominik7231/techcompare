import 'package:flutter/material.dart';
import '../models/headphones.dart';
import '../utils/settings.dart';

class HeadphonesDetailScreen extends StatefulWidget {
  final Headphones headphones;

  const HeadphonesDetailScreen({super.key, required this.headphones});

  @override
  State<HeadphonesDetailScreen> createState() => _HeadphonesDetailScreenState();
}

class _HeadphonesDetailScreenState extends State<HeadphonesDetailScreen> {
  late bool isFavorite;
  String? selectedColor;

  @override
  void initState() {
    super.initState();
    isFavorite = AppSettings.isFavorite('headphones_${widget.headphones.name}');
    selectedColor = widget.headphones.colors.first;
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      AppSettings.toggleFavorite('headphones_${widget.headphones.name}');
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
          widget.headphones.name,
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
                  widget.headphones.image,
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
                          widget.headphones.name,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      Text(
                        '\$${widget.headphones.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSpecCard(isDark, 'Type', widget.headphones.type, Icons.headphones),
                  const SizedBox(height: 12),
                  _buildSpecCard(isDark, 'Battery Life', '${widget.headphones.batteryLife} hours', Icons.battery_charging_full),
                  if (widget.headphones.noiseCancellation != null) ...[
                    const SizedBox(height: 12),
                    _buildSpecCard(isDark, 'Noise Cancellation', widget.headphones.noiseCancellation!, Icons.noise_control_off),
                  ],
                  if (widget.headphones.bluetooth != null) ...[
                    const SizedBox(height: 12),
                    _buildSpecCard(isDark, 'Bluetooth', widget.headphones.bluetooth!, Icons.bluetooth),
                  ],
                  if (widget.headphones.driverSize != null) ...[
                    const SizedBox(height: 12),
                    _buildSpecCard(isDark, 'Driver Size', '${widget.headphones.driverSize}mm', Icons.speaker),
                  ],
                  if (widget.headphones.frequencyResponse != null) ...[
                    const SizedBox(height: 12),
                    _buildSpecCard(isDark, 'Frequency Response', widget.headphones.frequencyResponse!, Icons.graphic_eq),
                  ],
                  if (widget.headphones.colors.length > 1) ...[
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
                      children: widget.headphones.colors.map((color) {
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

