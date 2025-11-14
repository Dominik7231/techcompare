import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/phone.dart';
import '../utils/settings.dart';

class PhoneDetailScreen extends StatefulWidget {
  final Phone phone;

  const PhoneDetailScreen({super.key, required this.phone});

  @override
  State<PhoneDetailScreen> createState() => _PhoneDetailScreenState();
}

class _PhoneDetailScreenState extends State<PhoneDetailScreen> {
  String? selectedColor;
  bool isFavorite = false;
  void _sharePhone() {
    final specs = [
      'Chip: ${widget.phone.chip}',
      if (widget.phone.ram != null) 'RAM: ${widget.phone.ram}GB',
      'Display: ${widget.phone.display}',
      'Camera: ${widget.phone.camera}',
      if (widget.phone.frontCamera != null) 'Front Camera: ${widget.phone.frontCamera}',
      'Storage: ${widget.phone.storageOptions.map((s) => '${s}GB').join(', ')}',
      'Battery: ${widget.phone.battery} mAh',
    ].join('\n');
    final text = '${widget.phone.name}\n\n$specs';
    Share.share(text, subject: widget.phone.name);
  }

  @override
  void initState() {
    super.initState();
    selectedColor = widget.phone.colors.first;
    isFavorite = AppSettings.isFavorite(widget.phone.name);
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
          widget.phone.name,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? Colors.red
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
            onPressed: () {
              setState(() {
                AppSettings.toggleFavorite(widget.phone.name);
                isFavorite = AppSettings.isFavorite(widget.phone.name);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? 'Added to favorites'
                        : 'Removed from favorites',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
          IconButton(
            icon: Icon(Icons.share, color: isDark ? Colors.white70 : Colors.black54),
            onPressed: _sharePhone,
            tooltip: 'Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Center(
                child: Hero(
                  tag: widget.phone.name,
                  child: Text(
                    widget.phone.image,
                    style: const TextStyle(fontSize: 150),
                  ),
                ),
              ),
            ),

            // Phone Name and Price
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.phone.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppSettings.formatPrice(widget.phone.price),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.green.shade300
                          : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              thickness: 1,
              color: isDark ? Colors.white24 : Colors.black12,
            ),

            // Specifications Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Specifications',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSpecRow(
                    Icons.memory,
                    'Chip',
                    widget.phone.chip,
                    isDark,
                  ),
                  if (widget.phone.ram != null)
                    _buildSpecRow(
                      Icons.memory_outlined,
                      'RAM',
                      '${widget.phone.ram} GB',
                      isDark,
                    ),
                  _buildSpecRow(
                    Icons.phone_android,
                    'Display',
                    widget.phone.display,
                    isDark,
                  ),
                  _buildSpecRow(
                    Icons.camera_alt,
                    'Rear Camera',
                    widget.phone.camera,
                    isDark,
                  ),
                  if (widget.phone.frontCamera != null)
                    _buildSpecRow(
                      Icons.camera_front,
                      'Front Camera',
                      widget.phone.frontCamera!,
                      isDark,
                    ),
                  _buildSpecRow(
                    Icons.storage,
                    'Storage',
                    widget.phone.storageOptions.map((s) => '${s}GB').join(', '),
                    isDark,
                  ),
                  _buildSpecRow(
                    Icons.battery_charging_full,
                    'Battery',
                    '${widget.phone.battery} mAh',
                    isDark,
                  ),
                  if (widget.phone.weight != null)
                    _buildSpecRow(
                      Icons.fitness_center,
                      'Weight',
                      '${widget.phone.weight} g',
                      isDark,
                    ),
                  if (widget.phone.dimensions != null)
                    _buildSpecRow(
                      Icons.straighten,
                      'Dimensions',
                      '${widget.phone.dimensions} mm',
                      isDark,
                    ),
                  _buildSpecRow(
                    Icons.signal_cellular_alt,
                    '5G',
                    widget.phone.has5G ? 'Yes' : 'No',
                    isDark,
                  ),
                  if (widget.phone.releaseYear != null)
                    _buildSpecRow(
                      Icons.calendar_today,
                      'Release',
                      widget.phone.releaseYear!,
                      isDark,
                    ),
                  if (widget.phone.ipProtection != null)
                    _buildSpecRow(
                      Icons.water_drop,
                      'Protection',
                      widget.phone.ipProtection!,
                      isDark,
                    ),
                  if (widget.phone.refreshRate != null)
                    _buildSpecRow(
                      Icons.speed,
                      'Refresh Rate',
                      '${widget.phone.refreshRate} Hz',
                      isDark,
                    ),
                  if (widget.phone.peakBrightness != null)
                    _buildSpecRow(
                      Icons.brightness_6,
                      'Peak Brightness',
                      '${widget.phone.peakBrightness} nits',
                      isDark,
                    ),
                  if (widget.phone.hasProMotion == true)
                    _buildSpecRow(
                      Icons.motion_photos_on,
                      'ProMotion',
                      'Yes',
                      isDark,
                    ),
                  if (widget.phone.hasDynamicIsland == true)
                    _buildSpecRow(
                      Icons.circle,
                      'Dynamic Island',
                      'Yes',
                      isDark,
                    ),
                  if (widget.phone.port != null)
                    _buildSpecRow(
                      Icons.cable,
                      'Port',
                      widget.phone.port!,
                      isDark,
                    ),
                  if (widget.phone.chargingWattage != null)
                    _buildSpecRow(
                      Icons.bolt,
                      'Charging',
                      '${widget.phone.chargingWattage}W',
                      isDark,
                    ),
                  if (widget.phone.hasWirelessCharging == true)
                    _buildSpecRow(
                      Icons.battery_charging_full,
                      'Wireless Charging',
                      'Yes',
                      isDark,
                    ),
                  if (widget.phone.wifi != null)
                    _buildSpecRow(
                      Icons.wifi,
                      'Wi-Fi',
                      widget.phone.wifi!,
                      isDark,
                    ),
                  if (widget.phone.bluetooth != null)
                    _buildSpecRow(
                      Icons.bluetooth,
                      'Bluetooth',
                      widget.phone.bluetooth!,
                      isDark,
                    ),
                ],
              ),
            ),

            Divider(
              thickness: 1,
              color: isDark ? Colors.white24 : Colors.black12,
            ),

            // Available Colors (chips only, no title)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.phone.colors.map((color) {
                  final isSelected = selectedColor == color;
                  return ChoiceChip(
                    label: Text(
                      color,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: _getColorFromName(color),
                    avatar: !isSelected
                        ? CircleAvatar(
                            backgroundColor: _getColorFromName(color),
                            radius: 12,
                          )
                        : null,
                    onSelected: (selected) {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: isDark ? const Color(0xFF4A90E2) : Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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

  Color _getColorFromName(String colorName) {
    final colorMap = {
      'Titanium Natural': Colors.grey.shade300,
      'Titanium Blue': Colors.blue.shade300,
      'Titanium White': Colors.white,
      'Titanium Black': Colors.black,
      'Pink': Colors.pink.shade300,
      'Yellow': Colors.yellow.shade300,
      'Green': Colors.green.shade300,
      'Blue': Colors.blue.shade400,
      'Black': Colors.black,
      'Deep Purple': Colors.deepPurple.shade400,
      'Gold': Colors.amber.shade400,
      'Silver': Colors.grey.shade300,
      'Space Black': Colors.black87,
    };
    return colorMap[colorName] ?? Colors.grey;
  }
}
