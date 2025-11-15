import 'package:flutter/material.dart';
import '../models/phone.dart';
import '../models/mac.dart';
import '../models/ipad.dart';
import '../models/airpods.dart';
import '../models/watch.dart';
import '../models/laptop.dart';
import '../models/tablet.dart';
import '../models/headphones.dart';
import '../data/phones_data.dart';
import '../data/macs_data.dart';
import '../data/ipads_data.dart';
import '../data/airpods_data.dart';
import '../data/watches_data.dart';
import '../data/laptops_data.dart';
import '../data/tablets_data.dart';
import '../data/headphones_data.dart';
import '../utils/settings.dart';
import 'phone_detail_screen.dart';
import 'mac_detail_screen.dart';
import 'ipad_detail_screen.dart';
import 'airpods_detail_screen.dart';
import 'watch_detail_screen.dart';
import 'laptop_detail_screen.dart';
import 'tablet_detail_screen.dart';
import 'headphones_detail_screen.dart';

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
  String selectedCategory = 'Phones';

  List<Phone> get favoritePhones {
    return allPhones.where((phone) => AppSettings.isFavorite(phone.name)).toList();
  }

  List<Mac> get favoriteMacs {
    return allMacs.where((mac) => AppSettings.isFavorite(mac.name)).toList();
  }

  List<iPad> get favoriteiPads {
    return alliPads.where((ipad) => AppSettings.isFavorite('ipad_${ipad.name}')).toList();
  }

  List<AirPods> get favoriteAirPods {
    return allAirPods.where((airpods) => AppSettings.isFavorite('airpods_${airpods.name}')).toList();
  }

  List<Watch> get favoriteWatches {
    return allWatches.where((watch) => AppSettings.isFavorite('watch_${watch.name}')).toList();
  }

  List<Laptop> get favoriteLaptops {
    return allLaptops.where((laptop) => AppSettings.isFavorite('laptop_${laptop.name}')).toList();
  }

  List<Tablet> get favoriteTablets {
    return allTablets.where((tablet) => AppSettings.isFavorite('tablet_${tablet.name}')).toList();
  }

  List<Headphones> get favoriteHeadphones {
    return allHeadphones.where((headphones) => AppSettings.isFavorite('headphones_${headphones.name}')).toList();
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('Phones', '📱', isDark),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Macs', '💻', isDark),
                    const SizedBox(width: 8),
                    _buildCategoryChip('iPads', '📱', isDark),
                    const SizedBox(width: 8),
                    _buildCategoryChip('AirPods', '🎧', isDark),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Watches', '⌚', isDark),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Laptops', '💻', isDark),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Tablets', '📱', isDark),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Headphones', '🎧', isDark),
                  ],
                ),
              ),
            ),
          ),

          // Favorites List
          Expanded(
            child: _buildFavoritesList(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(bool isDark) {
    switch (selectedCategory) {
      case 'Phones':
        return favoritePhones.isEmpty
            ? _buildEmptyState('No favorite phones yet', isDark)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoritePhones.length,
                itemBuilder: (context, index) => _buildFavoritePhoneCard(favoritePhones[index], isDark),
              );
      case 'Macs':
        return favoriteMacs.isEmpty
            ? _buildEmptyState('No favorite Macs yet', isDark)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteMacs.length,
                itemBuilder: (context, index) => _buildFavoriteMacCard(favoriteMacs[index], isDark),
              );
      case 'iPads':
        return favoriteiPads.isEmpty
            ? _buildEmptyState('No favorite iPads yet', isDark)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteiPads.length,
                itemBuilder: (context, index) => _buildFavoriteiPadCard(favoriteiPads[index], isDark),
              );
      case 'AirPods':
        return favoriteAirPods.isEmpty
            ? _buildEmptyState('No favorite AirPods yet', isDark)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteAirPods.length,
                itemBuilder: (context, index) => _buildFavoriteAirPodsCard(favoriteAirPods[index], isDark),
              );
      case 'Watches':
        return favoriteWatches.isEmpty
            ? _buildEmptyState('No favorite Watches yet', isDark)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteWatches.length,
                itemBuilder: (context, index) => _buildFavoriteWatchCard(favoriteWatches[index], isDark),
              );
      case 'Laptops':
        return favoriteLaptops.isEmpty
            ? _buildEmptyState('No favorite Laptops yet', isDark)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteLaptops.length,
                itemBuilder: (context, index) => _buildFavoriteLaptopCard(favoriteLaptops[index], isDark),
              );
      case 'Tablets':
        return favoriteTablets.isEmpty
            ? _buildEmptyState('No favorite Tablets yet', isDark)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteTablets.length,
                itemBuilder: (context, index) => _buildFavoriteTabletCard(favoriteTablets[index], isDark),
              );
      case 'Headphones':
        return favoriteHeadphones.isEmpty
            ? _buildEmptyState('No favorite Headphones yet', isDark)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteHeadphones.length,
                itemBuilder: (context, index) => _buildFavoriteHeadphonesCard(favoriteHeadphones[index], isDark),
              );
      default:
        return _buildEmptyState('Select a category', isDark);
    }
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

  Widget _buildFavoriteAirPodsCard(AirPods airpods, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF2D3142) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(airpods.image, style: const TextStyle(fontSize: 32))),
        ),
        title: Text(airpods.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        subtitle: Text('\$${airpods.price}', style: const TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () {
            setState(() => AppSettings.toggleFavorite('airpods_${airpods.name}'));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
          },
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AirPodsDetailScreen(airpods: airpods))),
      ),
    );
  }

  Widget _buildFavoriteWatchCard(Watch watch, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF2D3142) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF48C6EF), Color(0xFF6F86D6)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(watch.image, style: const TextStyle(fontSize: 32))),
        ),
        title: Text(watch.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        subtitle: Text('\$${watch.price}', style: const TextStyle(color: Color(0xFF48C6EF), fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () {
            setState(() => AppSettings.toggleFavorite('watch_${watch.name}'));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
          },
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WatchDetailScreen(watch: watch))),
      ),
    );
  }

  Widget _buildFavoriteLaptopCard(Laptop laptop, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF2D3142) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFF093FB), Color(0xFFF5576C)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(laptop.image, style: const TextStyle(fontSize: 32))),
        ),
        title: Text(laptop.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        subtitle: Text('\$${laptop.price}', style: const TextStyle(color: Color(0xFFF093FB), fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () {
            setState(() => AppSettings.toggleFavorite('laptop_${laptop.name}'));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
          },
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LaptopDetailScreen(laptop: laptop))),
      ),
    );
  }

  Widget _buildFavoriteTabletCard(Tablet tablet, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF2D3142) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(tablet.image, style: const TextStyle(fontSize: 32))),
        ),
        title: Text(tablet.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        subtitle: Text('\$${tablet.price}', style: const TextStyle(color: Color(0xFF4FACFE), fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () {
            setState(() => AppSettings.toggleFavorite('tablet_${tablet.name}'));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
          },
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TabletDetailScreen(tablet: tablet))),
      ),
    );
  }

  Widget _buildFavoriteHeadphonesCard(Headphones headphones, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF2D3142) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFA709A), Color(0xFFFEE140)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(headphones.image, style: const TextStyle(fontSize: 32))),
        ),
        title: Text(headphones.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        subtitle: Text('\$${headphones.price}', style: const TextStyle(color: Color(0xFFFA709A), fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () {
            setState(() => AppSettings.toggleFavorite('headphones_${headphones.name}'));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
          },
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HeadphonesDetailScreen(headphones: headphones))),
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

