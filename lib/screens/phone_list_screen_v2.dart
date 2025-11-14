import 'package:flutter/material.dart';
import 'package:techcomparev1/utils/version_text.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/phone.dart';
import '../data/phones_data.dart';
import '../data/macs_data.dart';
import '../data/ipads_data.dart';
import '../utils/settings.dart';
import '../services/ad_service.dart';
import 'compare_select_screen.dart';
import 'phone_detail_screen.dart';
import 'ai_assistant_screen.dart';

class PhoneListScreenV2 extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const PhoneListScreenV2({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<PhoneListScreenV2> createState() => _PhoneListScreenV2State();
}

class _PhoneListScreenV2State extends State<PhoneListScreenV2> {
  String searchQuery = '';
  int _selectedIndex = 0;
  String selectedBrand = 'All'; // Brand filter: 'All', 'iPhone', 'Samsung'
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  List<Phone> get filteredPhones {
    List<Phone> phones = List<Phone>.from(allPhones);
    
    // Apply brand filter
    if (selectedBrand != 'All') {
      phones = phones.where((phone) => phone.brand == selectedBrand).toList();
    }
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      phones = phones.where((phone) {
        return phone.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               phone.chip.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    return phones;
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // AI Chat
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AIAssistantScreen(
        phones: allPhones,
        macs: allMacs,
        ipads: alliPads,
      ),
    ),
  ).then((_) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else if (index == 2) {
      // Compare - Navigate to Compare Select Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CompareSelectScreen(),
        ),
      ).then((_) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else if (index == 3) {
      // Profile/Settings
      _showAboutDialog();
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _selectedIndex = 0;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd({int retryCount = 0}) {
    if (!AdService.isInitialized) {
      // Wait for AdMob to initialize
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _loadBannerAd(retryCount: retryCount);
      });
      return;
    }
    
    _bannerAd?.dispose();
    _bannerAd = AdService().createBannerAd(
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (ad, error) {
        print('Banner ad failed to load (attempt ${retryCount + 1}): ${error.code} - ${error.message}');
        ad.dispose();
        if (mounted && retryCount < 2) {
          // Retry after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) _loadBannerAd(retryCount: retryCount + 1);
          });
        }
      },
    );
    _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'iPhone Compare',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          widget.themeMode == ThemeMode.light
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                        ),
                        onPressed: widget.onToggleTheme,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D2D44) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search your phone...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Brand Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildBrandChip('All'),
                  const SizedBox(width: 10),
                  _buildBrandChip('iPhone'),
                  const SizedBox(width: 10),
                  _buildBrandChip('Samsung'),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Phone Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: filteredPhones.length,
                  itemBuilder: (context, index) {
                    final phone = filteredPhones[index];

                    return GestureDetector(
                      onTap: () {
                        // Home mode: always show details
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhoneDetailScreen(phone: phone),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D2D44) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image and favorite
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue.withOpacity(0.1),
                                    Colors.purple.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      phone.image,
                                      style: const TextStyle(fontSize: 60),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          AppSettings.toggleFavorite(phone.name);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          AppSettings.isFavorite(phone.name)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Phone info
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          phone.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${phone.storageOptions.first}GB',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            AppSettings.formatPrice(phone.price),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 12,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D44) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Banner Ad
              if (_isBannerAdLoaded && _bannerAd != null)
                Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: AdWidget(ad: _bannerAd!),
                ),
              // Bottom Navigation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_rounded, 'Home', 0),
                    _buildNavItem(Icons.psychology_rounded, 'AI', 1),
                    _buildNavItem(Icons.compare_arrows_rounded, 'Compare', 2),
                    _buildNavItem(Icons.person_rounded, 'Profile', 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandChip(String brand) {
    final bool isSelected = selectedBrand == brand;
    final bool isDark = widget.themeMode == ThemeMode.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedBrand = brand;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
              ? Colors.blue 
              : (isDark ? const Color(0xFF2D2D44) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            brand,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('About'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Phone Compare App'),
            const SizedBox(height: 8),
            const VersionText(),
            const SizedBox(height: 8),
            const Text('Compare iPhone and Samsung phones with AI assistance'),
          ],
        ),
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
