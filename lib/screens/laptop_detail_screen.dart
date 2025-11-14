import 'package:flutter/material.dart';
import '../models/laptop.dart';
import '../utils/settings.dart';

class LaptopDetailScreen extends StatefulWidget {
  final Laptop laptop;

  const LaptopDetailScreen({super.key, required this.laptop});

  @override
  State<LaptopDetailScreen> createState() => _LaptopDetailScreenState();
}

class _LaptopDetailScreenState extends State<LaptopDetailScreen> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = AppSettings.isFavorite('laptop_${widget.laptop.name}');
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      AppSettings.toggleFavorite('laptop_${widget.laptop.name}');
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
          widget.laptop.name,
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
                      ? [const Color(0xFF4A90E2), const Color(0xFF357ABD)]
                      : [const Color(0xFF4A90E2), const Color(0xFF5BA3F5)],
                ),
              ),
              child: Center(
                child: Text(
                  widget.laptop.image,
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
                          widget.laptop.name,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      Text(
                        '\$${widget.laptop.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSpecCard(isDark, 'Processor', widget.laptop.processor, Icons.memory),
                  const SizedBox(height: 12),
                  _buildSpecCard(isDark, 'Display', widget.laptop.display, Icons.display_settings),
                  if (widget.laptop.gpu != null) ...[
                    const SizedBox(height: 12),
                    _buildSpecCard(isDark, 'GPU', widget.laptop.gpu!, Icons.videogame_asset),
                  ],
                  const SizedBox(height: 12),
                  _buildSpecCard(isDark, 'RAM', '${widget.laptop.ramOptions.join(", ")} GB', Icons.storage),
                  const SizedBox(height: 12),
                  _buildSpecCard(isDark, 'Storage', '${widget.laptop.storageOptions.join(", ")} GB', Icons.save),
                  if (widget.laptop.batteryHours != null) ...[
                    const SizedBox(height: 12),
                    _buildSpecCard(isDark, 'Battery', '${widget.laptop.batteryHours} hours', Icons.battery_charging_full),
                  ],
                  if (widget.laptop.ports != null) ...[
                    const SizedBox(height: 12),
                    _buildSpecCard(isDark, 'Ports', widget.laptop.ports!, Icons.usb),
                  ],
                  if (widget.laptop.os != null) ...[
                    const SizedBox(height: 12),
                    _buildSpecCard(isDark, 'OS', widget.laptop.os!, Icons.computer),
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

