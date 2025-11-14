import 'package:flutter/material.dart';
import '../models/phone.dart';
import '../models/mac.dart';
import '../models/ipad.dart';
import '../data/phones_data.dart';
import '../data/macs_data.dart';
import '../data/ipads_data.dart';
import '../utils/settings.dart';
import 'phone_detail_screen.dart';
import 'mac_detail_screen.dart';
import 'ipad_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final ThemeMode themeMode;

  const FavoritesScreen({
    super.key,
    required this.themeMode,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String selectedCategory = 'Phones'; // 'Phones', 'Macs', or 'iPads'

  List<Phone> get favoritePhones {
    return allPhones.where((phone) => AppSettings.isFavorite(phone.name)).toList();
  }

  List<Mac> get favoriteMacs {
    // For Macs, we'll use name-based favorites (same system)
    return allMacs.where((mac) => AppSettings.isFavorite(mac.name)).toList();
  }

  List<iPad> get favoriteiPads {
    // For iPads, we use 'ipad_' prefix
    return alliPads.where((ipad) => AppSettings.isFavorite('ipad_${ipad.name}')).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: isDark ? const Color(0xFF2D3142) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF2D3142),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF2D3142),
        ),
      ),
      body: Column(
        children: [
          // Category Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D3142) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildCategoryChip('Phones', '📱', isDark)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildCategoryChip('Macs', '💻', isDark)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildCategoryChip('iPads', '📱', isDark)),
                ],
              ),
            ),
          ),

          // Favorites List
          Expanded(
            child: selectedCategory == 'Phones'
                ? favoritePhones.isEmpty
                    ? _buildEmptyState('No favorite phones yet', isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: favoritePhones.length,
                        itemBuilder: (context, index) {
                          final phone = favoritePhones[index];
                          return _buildFavoritePhoneCard(phone, isDark);
                        },
                      )
                : selectedCategory == 'Macs'
                ? favoriteMacs.isEmpty
                    ? _buildEmptyState('No favorite Macs yet', isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: favoriteMacs.length,
                        itemBuilder: (context, index) {
                          final mac = favoriteMacs[index];
                          return _buildFavoriteMacCard(mac, isDark);
                        },
                      )
                : favoriteiPads.isEmpty
                    ? _buildEmptyState('No favorite iPads yet', isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: favoriteiPads.length,
                        itemBuilder: (context, index) {
                          final ipad = favoriteiPads[index];
                          return _buildFavoriteiPadCard(ipad, isDark);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, String emoji, bool isDark) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              category,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritePhoneCard(Phone phone, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF2D3142) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF4A90E2), const Color(0xFF357ABD)]
                  : [const Color(0xFF4A90E2), const Color(0xFF5BA3F5)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              phone.image,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
        title: Text(
          phone.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              phone.chip,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${phone.price}',
              style: const TextStyle(
                color: Color(0xFF4A90E2),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () {
            setState(() {
              AppSettings.toggleFavorite(phone.name);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Removed from favorites')),
            );
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneDetailScreen(phone: phone),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteMacCard(Mac mac, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF2D3142) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF4A90E2), const Color(0xFF357ABD)]
                  : [const Color(0xFF4A90E2), const Color(0xFF5BA3F5)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              mac.image,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
        title: Text(
          mac.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              mac.chip,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${mac.price}',
              style: const TextStyle(
                color: Color(0xFF4A90E2),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () {
            setState(() {
              AppSettings.toggleFavorite(mac.name);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Removed from favorites')),
            );
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MacDetailScreen(mac: mac),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteiPadCard(iPad ipad, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF2D3142) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF9B59B6), const Color(0xFF8E44AD)]
                  : [const Color(0xFF9B59B6), const Color(0xFFAB6BCF)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              ipad.image,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
        title: Text(
          ipad.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              ipad.chip,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${ipad.price}',
              style: const TextStyle(
                color: Color(0xFF9B59B6),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () {
            setState(() {
              AppSettings.toggleFavorite('ipad_${ipad.name}');
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Removed from favorites')),
            );
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => iPadDetailScreen(ipad: ipad),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: isDark ? Colors.white30 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

