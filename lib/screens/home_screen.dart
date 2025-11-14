import 'package:flutter/material.dart';
import 'package:techcomparev1/utils/version_text.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
import '../services/ad_service.dart';
import '../utils/settings.dart';
import '../utils/responsive_helper.dart';
import 'dart:async';
import 'compare_select_screen.dart';
import 'phone_detail_screen.dart';
import 'mac_detail_screen.dart';
import 'ipad_detail_screen.dart';
import 'airpods_detail_screen.dart';
import 'watch_detail_screen.dart';
import 'laptop_detail_screen.dart';
import 'tablet_detail_screen.dart';
import 'headphones_detail_screen.dart';
import 'ai_assistant_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  final bool enableAds;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
    this.enableAds = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String searchQuery = '';
  int _selectedIndex = 0;
  String selectedCategory = 'Phones'; // 'Phones', 'Macs', 'iPads', 'AirPods', 'Watches', 'Laptops', 'Tablets', 'Headphones'
  String selectedBrand = 'All'; // For phones: 'All', 'iPhone', 'Samsung', 'Xiaomi', 'Google', 'OnePlus'
  String sortBy = 'Name'; // 'Name', 'Price', 'Battery', 'Storage'
  double minPrice = 0;
  double maxPrice = 2000;
  RangeValues priceRange = const RangeValues(0, 2000);
  bool _filtersExpanded = false; // For collapsible filters
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  late AnimationController _categoryAnimationController;
  late AnimationController _gridAnimationController;
  late Animation<double> _categoryFadeAnimation;
  late Animation<Offset> _categorySlideAnimation;
  
  // Cached filtered lists for performance
  List<Phone>? _cachedFilteredPhones;
  List<Mac>? _cachedFilteredMacs;
  List<iPad>? _cachedFilterediPads;
  List<AirPods>? _cachedFilteredAirPods;
  List<Watch>? _cachedFilteredWatches;
  List<Laptop>? _cachedFilteredLaptops;
  List<Tablet>? _cachedFilteredTablets;
  List<Headphones>? _cachedFilteredHeadphones;
  String? _lastSearchQuery;
  String? _lastSelectedBrand;
  String? _lastSortBy;
  RangeValues? _lastPriceRange;

  List<Phone> get filteredPhones {
    // Use cache if filters haven't changed
    if (_cachedFilteredPhones != null &&
        _lastSearchQuery == searchQuery &&
        _lastSelectedBrand == selectedBrand &&
        _lastSortBy == sortBy &&
        _lastPriceRange == priceRange) {
      return _cachedFilteredPhones!;
    }
    
    List<Phone> phones = List<Phone>.from(allPhones);
    
    if (selectedBrand != 'All') {
      phones = phones.where((phone) => phone.brand == selectedBrand).toList();
    }
    
    // Price filter
    phones = phones.where((phone) => phone.price >= priceRange.start && phone.price <= priceRange.end).toList();
    
    if (searchQuery.isNotEmpty) {
      phones = phones.where((phone) {
        return phone.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               phone.chip.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    // Sort
    switch (sortBy) {
      case 'Price':
        phones.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Battery':
        phones.sort((a, b) => b.battery.compareTo(a.battery));
        break;
      case 'Storage':
        phones.sort((a, b) => b.storageOptions.first.compareTo(a.storageOptions.first));
        break;
      case 'Name':
      default:
        phones.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    // Cache the result
    _cachedFilteredPhones = phones;
    _lastSearchQuery = searchQuery;
    _lastSelectedBrand = selectedBrand;
    _lastSortBy = sortBy;
    _lastPriceRange = priceRange;
    
    return phones;
  }

  List<Mac> get filteredMacs {
    // Use cache if filters haven't changed
    if (_cachedFilteredMacs != null &&
        _lastSearchQuery == searchQuery &&
        _lastSortBy == sortBy &&
        _lastPriceRange == priceRange) {
      return _cachedFilteredMacs!;
    }
    
    List<Mac> macs = List<Mac>.from(allMacs);
    
    // Price filter
    macs = macs.where((mac) => mac.price >= priceRange.start && mac.price <= priceRange.end).toList();
    
    if (searchQuery.isNotEmpty) {
      macs = macs.where((mac) {
        return mac.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               mac.chip.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    // Sort
    switch (sortBy) {
      case 'Price':
        macs.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Storage':
        macs.sort((a, b) => b.storageOptions.first.compareTo(a.storageOptions.first));
        break;
      case 'Name':
      default:
        macs.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    // Cache the result
    _cachedFilteredMacs = macs;
    
    return macs;
  }

  List<iPad> get filterediPads {
    // Use cache if filters haven't changed
    if (_cachedFilterediPads != null &&
        _lastSearchQuery == searchQuery &&
        _lastSortBy == sortBy &&
        _lastPriceRange == priceRange) {
      return _cachedFilterediPads!;
    }
    
    List<iPad> ipads = List<iPad>.from(alliPads);
    
    // Price filter
    ipads = ipads.where((ipad) => ipad.price >= priceRange.start && ipad.price <= priceRange.end).toList();
    
    if (searchQuery.isNotEmpty) {
      ipads = ipads.where((ipad) {
        return ipad.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               ipad.chip.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    // Sort
    switch (sortBy) {
      case 'Price':
        ipads.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Storage':
        ipads.sort((a, b) => b.storageOptions.first.compareTo(a.storageOptions.first));
        break;
      case 'Name':
      default:
        ipads.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    // Cache the result
    _cachedFilterediPads = ipads;
    
    return ipads;
  }

  List<AirPods> get filteredAirPods {
    // Use cache if filters haven't changed
    if (_cachedFilteredAirPods != null &&
        _lastSearchQuery == searchQuery &&
        _lastSortBy == sortBy &&
        _lastPriceRange == priceRange) {
      return _cachedFilteredAirPods!;
    }
    
    List<AirPods> airpods = List<AirPods>.from(allAirPods);
    
    // Price filter
    airpods = airpods.where((airpod) => airpod.price >= priceRange.start && airpod.price <= priceRange.end).toList();
    
    if (searchQuery.isNotEmpty) {
      airpods = airpods.where((airpod) {
        return airpod.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               airpod.chip.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    // Sort
    switch (sortBy) {
      case 'Price':
        airpods.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Battery':
        airpods.sort((a, b) => b.batteryLife.compareTo(a.batteryLife));
        break;
      case 'Name':
      default:
        airpods.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    // Cache the result
    _cachedFilteredAirPods = airpods;
    
    return airpods;
  }

  List<Watch> get filteredWatches {
    if (_cachedFilteredWatches != null &&
        _lastSearchQuery == searchQuery &&
        _lastSortBy == sortBy &&
        _lastPriceRange == priceRange) {
      return _cachedFilteredWatches!;
    }
    
    List<Watch> watches = List<Watch>.from(allWatches);
    
    watches = watches.where((watch) => watch.price >= priceRange.start && watch.price <= priceRange.end).toList();
    
    if (searchQuery.isNotEmpty) {
      watches = watches.where((watch) {
        return watch.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               watch.chip.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    switch (sortBy) {
      case 'Price':
        watches.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Battery':
        watches.sort((a, b) => b.batteryLife.compareTo(a.batteryLife));
        break;
      case 'Name':
      default:
        watches.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    _cachedFilteredWatches = watches;
    return watches;
  }

  List<Laptop> get filteredLaptops {
    if (_cachedFilteredLaptops != null &&
        _lastSearchQuery == searchQuery &&
        _lastSortBy == sortBy &&
        _lastPriceRange == priceRange) {
      return _cachedFilteredLaptops!;
    }
    
    List<Laptop> laptops = List<Laptop>.from(allLaptops);
    
    laptops = laptops.where((laptop) => laptop.price >= priceRange.start && laptop.price <= priceRange.end).toList();
    
    if (searchQuery.isNotEmpty) {
      laptops = laptops.where((laptop) {
        return laptop.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               laptop.processor.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    switch (sortBy) {
      case 'Price':
        laptops.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Storage':
        laptops.sort((a, b) => b.storageOptions.first.compareTo(a.storageOptions.first));
        break;
      case 'Name':
      default:
        laptops.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    _cachedFilteredLaptops = laptops;
    return laptops;
  }

  List<Tablet> get filteredTablets {
    if (_cachedFilteredTablets != null &&
        _lastSearchQuery == searchQuery &&
        _lastSortBy == sortBy &&
        _lastPriceRange == priceRange) {
      return _cachedFilteredTablets!;
    }
    
    List<Tablet> tablets = List<Tablet>.from(allTablets);
    
    tablets = tablets.where((tablet) => tablet.price >= priceRange.start && tablet.price <= priceRange.end).toList();
    
    if (searchQuery.isNotEmpty) {
      tablets = tablets.where((tablet) {
        return tablet.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               tablet.chip.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    switch (sortBy) {
      case 'Price':
        tablets.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Storage':
        tablets.sort((a, b) => b.storageOptions.first.compareTo(a.storageOptions.first));
        break;
      case 'Name':
      default:
        tablets.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    _cachedFilteredTablets = tablets;
    return tablets;
  }

  List<Headphones> get filteredHeadphones {
    if (_cachedFilteredHeadphones != null &&
        _lastSearchQuery == searchQuery &&
        _lastSortBy == sortBy &&
        _lastPriceRange == priceRange) {
      return _cachedFilteredHeadphones!;
    }
    
    List<Headphones> headphones = List<Headphones>.from(allHeadphones);
    
    headphones = headphones.where((headphone) => headphone.price >= priceRange.start && headphone.price <= priceRange.end).toList();
    
    if (searchQuery.isNotEmpty) {
      headphones = headphones.where((headphone) {
        return headphone.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               headphone.brand.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    switch (sortBy) {
      case 'Price':
        headphones.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Battery':
        headphones.sort((a, b) => b.batteryLife.compareTo(a.batteryLife));
        break;
      case 'Name':
      default:
        headphones.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    _cachedFilteredHeadphones = headphones;
    return headphones;
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _categoryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _gridAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _categoryFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _categoryAnimationController,
        curve: Curves.easeOut,
      ),
    );
    
    _categorySlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _categoryAnimationController,
        curve: Curves.easeOut,
      ),
    );
    
    _categoryAnimationController.forward();
    _gridAnimationController.forward();
    
    // Load banner ad in background to speed up startup
    if (widget.enableAds) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadBannerAd();
      });
    }
    // Calculate max price dynamically
    final allPrices = [
      ...allPhones.map((p) => p.price),
      ...allMacs.map((m) => m.price),
      ...alliPads.map((i) => i.price),
      ...allAirPods.map((a) => a.price),
      ...allWatches.map((w) => w.price),
      ...allLaptops.map((l) => l.price),
      ...allTablets.map((t) => t.price),
      ...allHeadphones.map((h) => h.price),
    ];
    if (allPrices.isNotEmpty) {
      final maxPriceValue = allPrices.reduce((a, b) => a > b ? a : b);
      maxPrice = (maxPriceValue / 100).ceil() * 100; // Round up to nearest 100
      priceRange = RangeValues(0, maxPrice);
    }
  }
  
  // Clear cache when filters change for better performance
  void _clearCache() {
    _cachedFilteredPhones = null;
    _cachedFilteredMacs = null;
    _cachedFilterediPads = null;
    _cachedFilteredAirPods = null;
    _cachedFilteredWatches = null;
    _cachedFilteredLaptops = null;
    _cachedFilteredTablets = null;
    _cachedFilteredHeadphones = null;
  }

  @override
  void dispose() {
    _categoryAnimationController.dispose();
    _gridAnimationController.dispose();
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
        // Silently handle banner ad failures - don't show error to user
        print('Banner ad failed to load (attempt ${retryCount + 1}): ${error.code} - ${error.message}');
        ad.dispose();
        if (mounted) {
          setState(() {
            _isBannerAdLoaded = false;
          });
        }
        if (mounted && retryCount < 2) {
          // Retry after 5 seconds (longer delay for "No fill" errors)
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) _loadBannerAd(retryCount: retryCount + 1);
          });
        }
      },
    );
    _bannerAd?.load();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // Favorites
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FavoritesScreen(
            themeMode: widget.themeMode,
          ),
        ),
      ).then((_) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else if (index == 2) {
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
    } else if (index == 3) {
      // Compare
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
    } else if (index == 4) {
      // Profile
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            themeMode: widget.themeMode,
            onToggleTheme: widget.onToggleTheme,
          ),
        ),
      ).then((_) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Tech Compare App'),
            SizedBox(height: 8),
            VersionText(),
            SizedBox(height: 8),
        Text('Compare Devices with AI assistance'),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = ResponsiveHelper.isWeb;
    final isDesktop = ResponsiveHelper.isDesktop(context);
    
    // Web desktop layout
    if (isWeb && isDesktop) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5),
        body: Row(
          children: [
            // Sidebar Navigation
            _buildWebSidebar(context, isDark),
            // Main Content
            Expanded(
              child: _buildWebMainContent(context, isDark),
            ),
          ],
        ),
      );
    }
    
    // Mobile/Tablet layout (original app design)
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header - Redesigned
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                                      : [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF4A90E2)).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.phone_android,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tech Compare',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${selectedCategory == 'Phones' ? filteredPhones.length : selectedCategory == 'Macs' ? filteredMacs.length : selectedCategory == 'iPads' ? filterediPads.length : selectedCategory == 'AirPods' ? filteredAirPods.length : selectedCategory == 'Watches' ? filteredWatches.length : selectedCategory == 'Laptops' ? filteredLaptops.length : selectedCategory == 'Tablets' ? filteredTablets.length : filteredHeadphones.length} ${selectedCategory.toLowerCase()} available',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        widget.themeMode == ThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color: isDark ? Colors.white : const Color(0xFF2D3142),
                        size: 24,
                      ),
                      onPressed: widget.onToggleTheme,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar - Redesigned
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF252538) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                      _clearCache(); // Clear cache when search changes
                    });
                    // Record search history when user stops typing
                    if (value.isNotEmpty) {
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        if (searchQuery == value && value.isNotEmpty) {
                          HistoryManager.addSearchHistory(value);
                        }
                      });
                    }
                  },
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: selectedCategory == 'Phones' 
                        ? 'Search phones...' 
                        : selectedCategory == 'Macs'
                        ? 'Search Macs...'
                        : selectedCategory == 'iPads'
                        ? 'Search iPads...'
                        : 'Search AirPods...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark ? Colors.white60 : Colors.black54,
                      size: 22,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: isDark ? Colors.white60 : Colors.black54,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  ),
                ),
              ),
            ),

            // Category Selector - Redesigned
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF252538) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildCategoryChip('Phones', '📱', isDark)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildCategoryChip('Macs', '💻', isDark)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildCategoryChip('iPads', '📱', isDark)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildCategoryChip('AirPods', '🎧', isDark)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildCategoryChip('Watches', '⌚', isDark)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildCategoryChip('Laptops', '💻', isDark)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildCategoryChip('Tablets', '📱', isDark)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildCategoryChip('Headphones', '🎧', isDark)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Filters Section - Collapsible & Redesigned
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF252538) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Filter Header (Always Visible)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _filtersExpanded = !_filtersExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              color: isDark ? Colors.white70 : Colors.black87,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Filters & Sort',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            Icon(
                              _filtersExpanded ? Icons.expand_less : Icons.expand_more,
                              color: isDark ? Colors.white60 : Colors.black54,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Filter Content (Collapsible)
                    if (_filtersExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (selectedCategory == 'Phones') ...[
                              const SizedBox(height: 8),
                              Text(
                                'Brand',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildBrandChip('All', isDark),
                                    const SizedBox(width: 8),
                                    _buildBrandChip('iPhone', isDark),
                                    const SizedBox(width: 8),
                                    _buildBrandChip('Samsung', isDark),
                                    const SizedBox(width: 8),
                                    _buildBrandChip('Xiaomi', isDark),
                                    const SizedBox(width: 8),
                                    _buildBrandChip('Google', isDark),
                                    const SizedBox(width: 8),
                                    _buildBrandChip('OnePlus', isDark),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            Text(
                              'Price Range',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RangeSlider(
                              values: priceRange,
                              min: 0,
                              max: maxPrice,
                              divisions: (maxPrice / 50).round(),
                              labels: RangeLabels(
                                '\$${priceRange.start.round()}',
                                '\$${priceRange.end.round()}',
                              ),
                              onChanged: (RangeValues values) {
                                setState(() {
                                  priceRange = values;
                                  _clearCache(); // Clear cache when price range changes
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Sort by',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildSortChip('Name', isDark),
                                  const SizedBox(width: 8),
                                  _buildSortChip('Price', isDark),
                                  if (selectedCategory == 'Phones' || selectedCategory == 'AirPods' || selectedCategory == 'Watches' || selectedCategory == 'Headphones') ...[
                                    const SizedBox(width: 8),
                                    _buildSortChip('Battery', isDark),
                                  ],
                                  const SizedBox(width: 8),
                                  _buildSortChip('Storage', isDark),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Grid with Pull-to-Refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Refresh data
                  await Future.delayed(const Duration(milliseconds: 500));
                  setState(() {});
                },
                child: selectedCategory == 'Phones'
                    ? _buildPhoneGrid(isDark)
                    : selectedCategory == 'Macs'
                    ? _buildMacGrid(isDark)
                    : selectedCategory == 'iPads'
                    ? _buildiPadGrid(isDark)
                    : selectedCategory == 'AirPods'
                    ? _buildAirPodsGrid(isDark)
                    : selectedCategory == 'Watches'
                    ? _buildWatchesGrid(isDark)
                    : selectedCategory == 'Laptops'
                    ? _buildLaptopsGrid(isDark)
                    : selectedCategory == 'Tablets'
                    ? _buildTabletsGrid(isDark)
                    : _buildHeadphonesGrid(isDark),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isBannerAdLoaded && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D3142) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onBottomNavTap,
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: 'Favorites',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.smart_toy),
                    label: 'AI',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.compare_arrows),
                    label: 'Compare',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, String emoji, bool isDark) {
    final isSelected = selectedCategory == category;
    return FadeTransition(
      opacity: _categoryFadeAnimation,
      child: SlideTransition(
        position: _categorySlideAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
          onTap: () {
            // Reset grid animation when category changes
            _gridAnimationController.reset();
            setState(() {
              selectedCategory = category;
              if (category == 'Macs') {
                selectedBrand = 'All'; // Reset brand filter when switching to Macs
              }
              _clearCache(); // Clear cache when category changes
            });
            _gridAnimationController.forward();
          },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                      : [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF4A90E2)).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: 18,
                shadows: isSelected
                    ? [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              category,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandChip(String brand, bool isDark) {
    final isSelected = selectedBrand == brand;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBrand = brand;
          _clearCache(); // Clear cache when brand changes
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                      : [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
                )
              : null,
          color: isSelected ? null : (isDark ? const Color(0xFF2D3142) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF4A90E2)).withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          brand,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String sortOption, bool isDark) {
    final isSelected = sortBy == sortOption;
    return GestureDetector(
      onTap: () {
        setState(() {
          sortBy = sortOption;
          _clearCache(); // Clear cache when sort changes
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                      : [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
                )
              : null,
          color: isSelected ? null : (isDark ? const Color(0xFF2D3142) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF4A90E2)).withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: Colors.white,
              )
            else
              Icon(
                Icons.radio_button_unchecked_rounded,
                size: 16,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            const SizedBox(width: 6),
            Text(
              sortOption,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridColumns(context),
        childAspectRatio: 0.76,
        crossAxisSpacing: 16,
        mainAxisSpacing: 18,
      ),
      itemCount: filteredPhones.length,
      itemBuilder: (context, index) {
        final phone = filteredPhones[index];
        return _buildAnimatedCard(
          child: _buildPhoneCard(phone, isDark),
          index: index,
        );
      },
    );
  }

  Widget _buildMacGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridColumns(context),
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredMacs.length,
      itemBuilder: (context, index) {
        final mac = filteredMacs[index];
        return _buildAnimatedCard(
          child: _buildMacCard(mac, isDark),
          index: index,
        );
      },
    );
  }

  Widget _buildAnimatedCard({required Widget child, required int index}) {
    // Staggered animation: delay based on index
    final delay = (index * 50).clamp(0, 300);
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _gridAnimationController,
        curve: Interval(
          delay / _gridAnimationController.duration!.inMilliseconds,
          (delay + 300) / _gridAnimationController.duration!.inMilliseconds,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final opacity = animation.value;
        final slideOffset = Offset(0, 24 * (1 - animation.value));
        final scale = 0.94 + (0.06 * animation.value);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: slideOffset,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildPhoneCard(Phone phone, bool isDark) {
    final isFavorite = AppSettings.isFavorite(phone.name);
    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: () {
        // Record viewed product
        HistoryManager.addViewedProduct(phone.name, 'Phones', 'phone');
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => PhoneDetailScreen(phone: phone),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF151528) : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.grey.shade100,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.40 : 0.10),
                blurRadius: 30,
                offset: const Offset(0, 18),
                spreadRadius: -10,
              ),
              BoxShadow(
                color: (isDark
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF4A90E2))
                    .withOpacity(0.12),
                blurRadius: 26,
                offset: const Offset(0, 6),
                spreadRadius: -4,
              ),
            ],
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.95),
                        Theme.of(context).colorScheme.secondary.withOpacity(0.85),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(26),
                      topRight: Radius.circular(26),
                    ),
                  ),
                  child: Center(
                    child: Hero(
                      tag: phone.name,
                      child: Text(
                        phone.image,
                        style: const TextStyle(fontSize: 62),
                      ),
                    ),
                  ),
                ),
                if (isFavorite)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phone.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.storage_rounded,
                            size: 14,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${phone.storageOptions.first}GB',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.memory_rounded,
                          size: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            phone.chip,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white60
                                  : Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.black45,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${phone.price}',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.primary,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.06)
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.blue.shade100,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.smartphone,
                                size: 11,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                phone.brand,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                  color: isDark
                                      ? Colors.blue.shade100
                                      : Colors.blue.shade800,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildMacCard(Mac mac, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: () {
        // Record viewed product
        HistoryManager.addViewedProduct(mac.name, 'Macs', 'mac');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MacDetailScreen(mac: mac),
          ),
        );
      },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.30 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: -4,
              ),
            ],
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Hero(
                  tag: 'mac-${mac.name}',
                  child: Text(
                    mac.image,
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mac.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.storage,
                            size: 13,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${mac.storageOptions.first >= 1024 ? mac.storageOptions.first ~/ 1024 : mac.storageOptions.first}${mac.storageOptions.first >= 1024 ? 'TB' : 'GB'}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.memory,
                          size: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            mac.chip,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 9,
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${mac.price}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A90E2),
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.shade300,
                                Colors.purple.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Mac',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
      ),
    );
  }

  Widget _buildiPadGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filterediPads.length,
      itemBuilder: (context, index) {
        final ipad = filterediPads[index];
        return _buildAnimatedCard(
          child: _buildiPadCard(ipad, isDark),
          index: index,
        );
      },
    );
  }

  Widget _buildiPadCard(iPad ipad, bool isDark) {
    final isFavorite = AppSettings.isFavorite('ipad_${ipad.name}');
    return GestureDetector(
      onTap: () {
        // Record viewed product
        HistoryManager.addViewedProduct(ipad.name, 'iPads', 'ipad');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => iPadDetailScreen(ipad: ipad),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D3142) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF9B59B6), const Color(0xFF8E44AD)]
                          : [const Color(0xFF9B59B6), const Color(0xFFAB6BCF)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      ipad.image,
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),
                if (isFavorite)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ipad.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.storage,
                            size: 13,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${ipad.storageOptions.first >= 1024 ? ipad.storageOptions.first ~/ 1024 : ipad.storageOptions.first}${ipad.storageOptions.first >= 1024 ? 'TB' : 'GB'}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.memory,
                          size: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ipad.chip,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 9,
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${ipad.price}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9B59B6),
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.shade300,
                                Colors.purple.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'iPad',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
  }

  // Web Sidebar Navigation
  Widget _buildWebSidebar(BuildContext context, bool isDark) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3142) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                    : [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.phone_android, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tech Compare',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildWebNavItem(context, isDark, Icons.home, 'Home', 0),
                _buildWebNavItem(context, isDark, Icons.favorite, 'Favorites', 1),
                _buildWebNavItem(context, isDark, Icons.smart_toy, 'AI Assistant', 2),
                _buildWebNavItem(context, isDark, Icons.compare_arrows, 'Compare', 3),
                _buildWebNavItem(context, isDark, Icons.person, 'Profile', 4),
              ],
            ),
          ),
          // Theme Toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  widget.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                title: Text(
                  widget.themeMode == ThemeMode.dark ? 'Light Mode' : 'Dark Mode',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                onTap: widget.onToggleTheme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebNavItem(BuildContext context, bool isDark, IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? const Color(0xFF6366F1).withOpacity(0.2) : const Color(0xFF4A90E2).withOpacity(0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? (isDark ? const Color(0xFF8B5CF6) : const Color(0xFF4A90E2))
              : (isDark ? Colors.white60 : Colors.black54),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.white60 : Colors.black54),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () => _onBottomNavTap(index),
      ),
    );
  }

  // Web Main Content
  Widget _buildWebMainContent(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Top Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D3142) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tech Compare',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${selectedCategory == 'Phones' ? filteredPhones.length : selectedCategory == 'Macs' ? filteredMacs.length : filterediPads.length} ${selectedCategory.toLowerCase()} available',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Content Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.getMaxContentWidth(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF252538) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: selectedCategory == 'Phones' 
                            ? 'Search phones...' 
                            : selectedCategory == 'Macs'
                            ? 'Search Macs...'
                            : selectedCategory == 'iPads'
                            ? 'Search iPads...'
                            : 'Search AirPods...',
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                        prefixIcon: Icon(Icons.search, color: isDark ? Colors.white60 : Colors.black54),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: isDark ? Colors.white60 : Colors.black54),
                                onPressed: () => setState(() => searchQuery = ''),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                  // Category Selector
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF252538) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildWebCategoryChip('Phones', '📱', isDark),
                        const SizedBox(width: 8),
                        _buildWebCategoryChip('Macs', '💻', isDark),
                        const SizedBox(width: 8),
                        _buildWebCategoryChip('iPads', '📱', isDark),
                        const SizedBox(width: 8),
                        _buildWebCategoryChip('AirPods', '🎧', isDark),
                        const SizedBox(width: 8),
                        _buildWebCategoryChip('Watches', '⌚', isDark),
                        const SizedBox(width: 8),
                        _buildWebCategoryChip('Laptops', '💻', isDark),
                        const SizedBox(width: 8),
                        _buildWebCategoryChip('Tablets', '📱', isDark),
                        const SizedBox(width: 8),
                        _buildWebCategoryChip('Headphones', '🎧', isDark),
                      ],
                    ),
                  ),
                  // Products Grid
                  _buildWebProductsGrid(context, isDark),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebCategoryChip(String category, String emoji, bool isDark) {
    final isSelected = selectedCategory == category;
    return InkWell(
      onTap: () => setState(() => selectedCategory = category),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF6366F1) : const Color(0xFF4A90E2))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebProductsGrid(BuildContext context, bool isDark) {
    final columns = ResponsiveHelper.getGridColumns(context);
    final items = selectedCategory == 'Phones'
        ? filteredPhones.map((p) => _buildWebProductCard(context, isDark, p.name, p.price.toDouble(), p.image, 'phone', p)).toList()
        : selectedCategory == 'Macs'
            ? filteredMacs.map((m) => _buildWebProductCard(context, isDark, m.name, m.price.toDouble(), m.image, 'mac', m)).toList()
            : selectedCategory == 'iPads'
            ? filterediPads.map((i) => _buildWebProductCard(context, isDark, i.name, i.price.toDouble(), i.image, 'ipad', i)).toList()
            : selectedCategory == 'AirPods'
            ? filteredAirPods.map((a) => _buildWebProductCard(context, isDark, a.name, a.price.toDouble(), a.image, 'airpods', a)).toList()
            : selectedCategory == 'Watches'
            ? filteredWatches.map((w) => _buildWebProductCard(context, isDark, w.name, w.price.toDouble(), w.image, 'watch', w)).toList()
            : selectedCategory == 'Laptops'
            ? filteredLaptops.map((l) => _buildWebProductCard(context, isDark, l.name, l.price.toDouble(), l.image, 'laptop', l)).toList()
            : selectedCategory == 'Tablets'
            ? filteredTablets.map((t) => _buildWebProductCard(context, isDark, t.name, t.price.toDouble(), t.image, 'tablet', t)).toList()
            : filteredHeadphones.map((h) => _buildWebProductCard(context, isDark, h.name, h.price.toDouble(), h.image, 'headphones', h)).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  Widget _buildWebProductCard(BuildContext context, bool isDark, String name, double price, String image, String type, dynamic product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF2D3142) : Colors.white,
      child: InkWell(
        onTap: () {
          if (type == 'phone') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => PhoneDetailScreen(phone: product)));
          } else if (type == 'mac') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => MacDetailScreen(mac: product)));
          } else if (type == 'ipad') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => iPadDetailScreen(ipad: product)));
          } else if (type == 'airpods') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => AirPodsDetailScreen(airpods: product)));
          } else if (type == 'watch') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => WatchDetailScreen(watch: product)));
          } else if (type == 'laptop') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => LaptopDetailScreen(laptop: product)));
          } else if (type == 'tablet') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => TabletDetailScreen(tablet: product)));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => HeadphonesDetailScreen(headphones: product)));
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(image, style: const TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                '\$${price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFF4A90E2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAirPodsGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredAirPods.length,
      itemBuilder: (context, index) {
        final airpods = filteredAirPods[index];
        return _buildAnimatedCard(
          child: _buildAirPodsCard(airpods, isDark),
          index: index,
        );
      },
    );
  }

  Widget _buildAirPodsCard(AirPods airpods, bool isDark) {
    final isFavorite = AppSettings.isFavorite('airpods_${airpods.name}');
    return GestureDetector(
      onTap: () {
        // Record viewed product
        HistoryManager.addViewedProduct(airpods.name, 'AirPods', 'airpods');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AirPodsDetailScreen(airpods: airpods),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D3142) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                          : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      airpods.image,
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),
                if (isFavorite)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      airpods.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.battery_charging_full,
                            size: 13,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${airpods.batteryLife}h',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.memory,
                          size: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            airpods.chip,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 9,
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${airpods.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6366F1),
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.shade300,
                                Colors.purple.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '🎧',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
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
  }

  Widget _buildWatchesGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredWatches.length,
      itemBuilder: (context, index) {
        final watch = filteredWatches[index];
        return _buildAnimatedCard(
          child: _buildWatchCard(watch, isDark),
          index: index,
        );
      },
    );
  }

  Widget _buildWatchCard(Watch watch, bool isDark) {
    final isFavorite = AppSettings.isFavorite('watch_${watch.name}');
    return GestureDetector(
      onTap: () {
        HistoryManager.addViewedProduct(watch.name, 'Watch', 'watch');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WatchDetailScreen(watch: watch),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D3142) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                          : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      watch.image,
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),
                if (isFavorite)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    watch.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${watch.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.battery_charging_full,
                          size: 13,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${watch.batteryLife}h',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaptopsGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredLaptops.length,
      itemBuilder: (context, index) {
        final laptop = filteredLaptops[index];
        return _buildAnimatedCard(
          child: _buildLaptopCard(laptop, isDark),
          index: index,
        );
      },
    );
  }

  Widget _buildLaptopCard(Laptop laptop, bool isDark) {
    final isFavorite = AppSettings.isFavorite('laptop_${laptop.name}');
    return GestureDetector(
      onTap: () {
        HistoryManager.addViewedProduct(laptop.name, 'Laptop', 'laptop');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LaptopDetailScreen(laptop: laptop),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D3142) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF4A90E2), const Color(0xFF357ABD)]
                          : [const Color(0xFF4A90E2), const Color(0xFF5BA3F5)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      laptop.image,
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),
                if (isFavorite)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    laptop.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${laptop.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.memory,
                        size: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          laptop.processor,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletsGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredTablets.length,
      itemBuilder: (context, index) {
        final tablet = filteredTablets[index];
        return _buildAnimatedCard(
          child: _buildTabletCard(tablet, isDark),
          index: index,
        );
      },
    );
  }

  Widget _buildTabletCard(Tablet tablet, bool isDark) {
    final isFavorite = AppSettings.isFavorite('tablet_${tablet.name}');
    return GestureDetector(
      onTap: () {
        HistoryManager.addViewedProduct(tablet.name, 'Tablet', 'tablet');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TabletDetailScreen(tablet: tablet),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D3142) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                          : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      tablet.image,
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),
                if (isFavorite)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tablet.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${tablet.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.memory,
                        size: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tablet.chip,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadphonesGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredHeadphones.length,
      itemBuilder: (context, index) {
        final headphones = filteredHeadphones[index];
        return _buildAnimatedCard(
          child: _buildHeadphonesCard(headphones, isDark),
          index: index,
        );
      },
    );
  }

  Widget _buildHeadphonesCard(Headphones headphones, bool isDark) {
    final isFavorite = AppSettings.isFavorite('headphones_${headphones.name}');
    return GestureDetector(
      onTap: () {
        HistoryManager.addViewedProduct(headphones.name, 'Headphones', 'headphones');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HeadphonesDetailScreen(headphones: headphones),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D3142) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                          : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      headphones.image,
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),
                if (isFavorite)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headphones.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${headphones.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.battery_charging_full,
                          size: 13,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${headphones.batteryLife}h',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
