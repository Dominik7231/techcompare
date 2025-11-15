import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
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
import '../utils/responsive_helper.dart';
import 'compare_screen.dart';
import 'mac_compare_screen.dart';
import 'ipad_compare_screen.dart';
import 'airpods_compare_screen.dart';
import 'watch_compare_screen.dart';
import 'laptop_compare_screen.dart';
import 'tablet_compare_screen.dart';
import 'headphones_compare_screen.dart';

class CompareSelectScreen extends StatefulWidget {
  const CompareSelectScreen({super.key});

  @override
  State<CompareSelectScreen> createState() => _CompareSelectScreenState();
}

class _CompareSelectScreenState extends State<CompareSelectScreen> {
  final List<Phone> selectedPhones = [];
  final List<Mac> selectedMacs = [];
  final List<iPad> selectediPads = [];
  final List<AirPods> selectedAirPods = [];
  final List<Watch> selectedWatches = [];
  final List<Laptop> selectedLaptops = [];
  final List<Tablet> selectedTablets = [];
  final List<Headphones> selectedHeadphones = [];
  String searchQuery = '';
  String selectedBrand = 'All'; // Brand filter for phones
  String selectedCategory = 'Phones'; // Category: Phones, Macs, iPads, AirPods, Watches, Laptops, Tablets, Headphones
  String sortOption = 'name_asc';

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
    
    phones.sort((a, b) => _compareByOption(a.name, b.name, a.price, b.price));
    return phones;
  }

  List<Mac> get filteredMacs {
    List<Mac> macs = List<Mac>.from(allMacs);
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      macs = macs.where((mac) {
        return mac.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               mac.chip.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    macs.sort((a, b) => _compareByOption(a.name, b.name, a.price, b.price));
    return macs;
  }

  List<iPad> get filterediPads {
    List<iPad> ipads = List<iPad>.from(alliPads);
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      ipads = ipads.where((ipad) {
        return ipad.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               ipad.chip.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    ipads.sort((a, b) => _compareByOption(a.name, b.name, a.price, b.price));
    return ipads;
  }

  List<AirPods> get filteredAirPods {
    List<AirPods> airpods = List<AirPods>.from(allAirPods);
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      airpods = airpods.where((airpod) {
        return airpod.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               airpod.chip.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    airpods.sort((a, b) => _compareByOption(a.name, b.name, a.price, b.price));
    return airpods;
  }

  List<Watch> get filteredWatches {
    List<Watch> watches = List<Watch>.from(allWatches);
    if (searchQuery.isNotEmpty) {
      watches = watches.where((w) {
        return w.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    watches.sort((a, b) => _compareByOption(a.name, b.name, a.price, b.price));
    return watches;
  }

  List<Laptop> get filteredLaptops {
    List<Laptop> laptops = List<Laptop>.from(allLaptops);
    if (searchQuery.isNotEmpty) {
      laptops = laptops.where((l) {
        return l.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               l.processor.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    laptops.sort((a, b) => _compareByOption(a.name, b.name, a.price, b.price));
    return laptops;
  }

  List<Tablet> get filteredTablets {
    List<Tablet> tablets = List<Tablet>.from(allTablets);
    if (searchQuery.isNotEmpty) {
      tablets = tablets.where((t) {
        return t.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               t.chip.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    tablets.sort((a, b) => _compareByOption(a.name, b.name, a.price, b.price));
    return tablets;
  }

  List<Headphones> get filteredHeadphones {
    List<Headphones> heads = List<Headphones>.from(allHeadphones);
    if (searchQuery.isNotEmpty) {
      heads = heads.where((h) {
        return h.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    heads.sort((a, b) => _compareByOption(a.name, b.name, a.price, b.price));
    return heads;
  }

  int _compareByOption(String aName, String bName, num aPrice, num bPrice) {
    switch (sortOption) {
      case 'name_desc':
        return bName.compareTo(aName);
      case 'price_asc':
        return aPrice.compareTo(bPrice);
      case 'price_desc':
        return bPrice.compareTo(aPrice);
      case 'name_asc':
      default:
        return aName.compareTo(bName);
    }
  }

  List<String> get phoneBrands {
    final brands = allPhones.map((phone) => phone.brand).toSet().toList()
      ..sort();
    return ['All', ...brands];
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
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF2D3142),
        ),
        actions: [
          IconButton(
            onPressed: _scanQr,
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Compare button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Compare $selectedCategory',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Select 2-4 devices',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white60 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if ((selectedCategory == 'Phones' && selectedPhones.isNotEmpty) ||
                          (selectedCategory == 'Macs' && selectedMacs.isNotEmpty) ||
                          (selectedCategory == 'iPads' && selectediPads.isNotEmpty) ||
                          (selectedCategory == 'AirPods' && selectedAirPods.isNotEmpty))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${selectedCategory == 'Phones' ? selectedPhones.length : selectedCategory == 'Macs' ? selectedMacs.length : selectedCategory == 'iPads' ? selectediPads.length : selectedCategory == 'AirPods' ? selectedAirPods.length : selectedCategory == 'Watches' ? selectedWatches.length : selectedCategory == 'Laptops' ? selectedLaptops.length : selectedCategory == 'Tablets' ? selectedTablets.length : selectedHeadphones.length} selected',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Category Chips
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip('Phones', '📱', isDark),
                          const SizedBox(width: 12),
                          _buildCategoryChip('Macs', '💻', isDark),
                          const SizedBox(width: 12),
                          _buildCategoryChip('iPads', '📱', isDark),
                          const SizedBox(width: 12),
                          _buildCategoryChip('AirPods', '🎧', isDark),
                          const SizedBox(width: 12),
                          _buildCategoryChip('Watches', '⌚', isDark),
                          const SizedBox(width: 12),
                          _buildCategoryChip('Laptops', '💻', isDark),
                          const SizedBox(width: 12),
                          _buildCategoryChip('Tablets', '📱', isDark),
                          const SizedBox(width: 12),
                          _buildCategoryChip('Headphones', '🎧', isDark),
                        ],
                      ),
                    ),
                  ),
                  
                  // Compare button at top
                  if ((selectedCategory == 'Phones' && selectedPhones.length >= 2) ||
                      (selectedCategory == 'Macs' && selectedMacs.length >= 2) ||
                      (selectedCategory == 'iPads' && selectediPads.length >= 2) ||
                      (selectedCategory == 'AirPods' && selectedAirPods.length >= 2) ||
                      (selectedCategory == 'Watches' && selectedWatches.length >= 2) ||
                      (selectedCategory == 'Laptops' && selectedLaptops.length >= 2) ||
                      (selectedCategory == 'Tablets' && selectedTablets.length >= 2) ||
                      (selectedCategory == 'Headphones' && selectedHeadphones.length >= 2))
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedCategory == 'Phones') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CompareScreen(phones: selectedPhones),
                                ),
                              );
                            } else if (selectedCategory == 'Macs') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MacCompareScreen(macs: selectedMacs),
                                ),
                              );
                            } else if (selectedCategory == 'iPads') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => iPadCompareScreen(ipads: selectediPads),
                                ),
                              );
                            } else if (selectedCategory == 'AirPods') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AirPodsCompareScreen(airpods: selectedAirPods),
                                ),
                              );
                            } else if (selectedCategory == 'Watches') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WatchCompareScreen(watches: selectedWatches),
                                ),
                              );
                            } else if (selectedCategory == 'Laptops') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LaptopCompareScreen(laptops: selectedLaptops),
                                ),
                              );
                            } else if (selectedCategory == 'Tablets') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TabletCompareScreen(tablets: selectedTablets),
                                ),
                              );
                            } else if (selectedCategory == 'Headphones') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HeadphonesCompareScreen(headphones: selectedHeadphones),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blue,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.compare_arrows, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Compare ${selectedCategory == 'Phones' ? selectedPhones.length : selectedCategory == 'Macs' ? selectedMacs.length : selectedCategory == 'iPads' ? selectediPads.length : selectedCategory == 'AirPods' ? selectedAirPods.length : selectedCategory == 'Watches' ? selectedWatches.length : selectedCategory == 'Laptops' ? selectedLaptops.length : selectedCategory == 'Tablets' ? selectedTablets.length : selectedHeadphones.length} $selectedCategory',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                    hintText: selectedCategory == 'Phones' 
                        ? 'Search phones...' 
                        : selectedCategory == 'Macs'
                        ? 'Search Macs...'
                        : selectedCategory == 'iPads'
                        ? 'Search iPads...'
                        : selectedCategory == 'AirPods'
                        ? 'Search AirPods...'
                        : selectedCategory == 'Watches'
                        ? 'Search watches...'
                        : selectedCategory == 'Laptops'
                        ? 'Search laptops...'
                        : selectedCategory == 'Tablets'
                        ? 'Search tablets...'
                        : 'Search headphones...',
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: sortOption,
                    items: const [
                      DropdownMenuItem(value: 'name_asc', child: Text('Név (A→Z)')),
                      DropdownMenuItem(value: 'name_desc', child: Text('Név (Z→A)')),
                      DropdownMenuItem(value: 'price_asc', child: Text('Ár (növekvő)')),
                      DropdownMenuItem(value: 'price_desc', child: Text('Ár (csökkenő)')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() { sortOption = v; });
                    },
                  ),
                ],
              ),
            ),

            // Brand Filter Chips (only for Phones)
            if (selectedCategory == 'Phones') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: phoneBrands
                      .map((brand) => _buildBrandChip(brand))
                      .toList(),
                ),
              ),
              const SizedBox(height: 15),
            ],

            // Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
    );
  }

  Widget _buildCategoryChip(String category, String emoji, bool isDark) {
    final isSelected = selectedCategory == category;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
          searchQuery = ''; // Clear search when switching
          selectedBrand = 'All';
          selectedPhones.clear();
          selectedMacs.clear();
          selectediPads.clear();
          selectedAirPods.clear();
          selectedWatches.clear();
          selectedLaptops.clear();
          selectedTablets.clear();
          selectedHeadphones.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                )
              : null,
          color: isSelected 
              ? null 
              : (isDark ? const Color(0xFF2D2D44) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : [],
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
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : (isDark ? Colors.white : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scanQr() {
    if (kIsWeb) {
      final controller = ms.MobileScannerController(
        facing: ms.CameraFacing.back,
        detectionSpeed: ms.DetectionSpeed.normal,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Scan QR')),
            body: ms.MobileScanner(
              controller: controller,
              fit: BoxFit.cover,
              errorBuilder: (ctx, error, child) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Camera error: MobileScannerErrorCode.genericError'),
                      SizedBox(height: 12),
                      Text('Enable camera permissions in browser settings, run under HTTPS, and avoid iframes.'),
                    ],
                  ),
                );
              },
              onDetect: (capture) async {
                final barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final raw = barcode.rawValue;
                  if (raw != null && raw.isNotEmpty) {
                    try {
                      final data = jsonDecode(raw);
                      if (data is Map && data['type'] == 'comparison') {
                        final category = data['category'] as String;
                        final names = List<String>.from(data['names'] as List);
                        await controller.stop();
                        Navigator.pop(context);
                        _applyQrComparison(category, names);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(content: Text('Comparison imported from QR')),
                        );
                        break;
                      }
                    } catch (_) {}
                  }
                }
              },
            ),
          ),
        ),
      );
      return;
    }
    _ensureCameraPermission().then((granted) {
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required to scan QR')),
        );
        return;
      }
      final controller = ms.MobileScannerController(
        facing: ms.CameraFacing.back,
        detectionSpeed: ms.DetectionSpeed.normal,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Scan QR')),
            body: ms.MobileScanner(
              controller: controller,
              fit: BoxFit.cover,
              errorBuilder: (ctx, error, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Camera error: ${error.errorCode}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final ok = await _ensureCameraPermission();
                        if (ok) {
                          await controller.start();
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                );
              },
              onDetect: (capture) async {
                final barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final raw = barcode.rawValue;
                  if (raw != null && raw.isNotEmpty) {
                    try {
                      final data = jsonDecode(raw);
                      if (data is Map && data['type'] == 'comparison') {
                        final category = data['category'] as String;
                        final names = List<String>.from(data['names'] as List);
                        await controller.stop();
                        Navigator.pop(context);
                        _applyQrComparison(category, names);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(content: Text('Comparison imported from QR')),
                        );
                        break;
                      }
                    } catch (_) {}
                  }
                }
              },
            ),
          ),
        ),
      );
    });
  }

  Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    final req = await Permission.camera.request();
    return req.isGranted;
  }

  

  void _applyQrComparison(String category, List<String> names) {
    setState(() {
      selectedCategory = category;
      selectedPhones.clear();
      selectedMacs.clear();
      selectediPads.clear();
      selectedAirPods.clear();
      selectedWatches.clear();
      selectedLaptops.clear();
      selectedTablets.clear();
      selectedHeadphones.clear();
      if (category == 'Phones') {
        for (final n in names) {
          final match = allPhones.where((p) => p.name == n).toList();
          if (match.isNotEmpty && selectedPhones.length < 4) selectedPhones.add(match.first);
        }
      } else if (category == 'Macs') {
        for (final n in names) {
          final match = allMacs.where((m) => m.name == n).toList();
          if (match.isNotEmpty && selectedMacs.length < 4) selectedMacs.add(match.first);
        }
      } else if (category == 'iPads') {
        for (final n in names) {
          final match = alliPads.where((i) => i.name == n).toList();
          if (match.isNotEmpty && selectediPads.length < 4) selectediPads.add(match.first);
        }
      } else if (category == 'AirPods') {
        for (final n in names) {
          final match = allAirPods.where((a) => a.name == n).toList();
          if (match.isNotEmpty && selectedAirPods.length < 4) selectedAirPods.add(match.first);
        }
      } else if (category == 'Watches') {
        for (final n in names) {
          final match = allWatches.where((w) => w.name == n).toList();
          if (match.isNotEmpty && selectedWatches.length < 4) selectedWatches.add(match.first);
        }
      } else if (category == 'Laptops') {
        for (final n in names) {
          final match = allLaptops.where((l) => l.name == n).toList();
          if (match.isNotEmpty && selectedLaptops.length < 4) selectedLaptops.add(match.first);
        }
      } else if (category == 'Tablets') {
        for (final n in names) {
          final match = allTablets.where((t) => t.name == n).toList();
          if (match.isNotEmpty && selectedTablets.length < 4) selectedTablets.add(match.first);
        }
      } else if (category == 'Headphones') {
        for (final n in names) {
          final match = allHeadphones.where((h) => h.name == n).toList();
          if (match.isNotEmpty && selectedHeadphones.length < 4) selectedHeadphones.add(match.first);
        }
      }
    });
    if (selectedCategory == 'Phones' && selectedPhones.length >= 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => CompareScreen(phones: selectedPhones)));
    } else if (selectedCategory == 'Macs' && selectedMacs.length >= 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MacCompareScreen(macs: selectedMacs)));
    } else if (selectedCategory == 'iPads' && selectediPads.length >= 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => iPadCompareScreen(ipads: selectediPads)));
    } else if (selectedCategory == 'AirPods' && selectedAirPods.length >= 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AirPodsCompareScreen(airpods: selectedAirPods)));
    } else if (selectedCategory == 'Watches' && selectedWatches.length >= 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => WatchCompareScreen(watches: selectedWatches)));
    } else if (selectedCategory == 'Laptops' && selectedLaptops.length >= 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LaptopCompareScreen(laptops: selectedLaptops)));
    } else if (selectedCategory == 'Tablets' && selectedTablets.length >= 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => TabletCompareScreen(tablets: selectedTablets)));
    } else if (selectedCategory == 'Headphones' && selectedHeadphones.length >= 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HeadphonesCompareScreen(headphones: selectedHeadphones)));
    }
  }

  Widget _buildPhoneGrid(bool isDark) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridColumns(context),
        childAspectRatio: 0.75,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: filteredPhones.length,
      itemBuilder: (context, index) {
        final phone = filteredPhones[index];
        final isSelected = selectedPhones.contains(phone);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedPhones.remove(phone);
              } else {
                if (selectedPhones.length < 4) {
                  selectedPhones.add(phone);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Maximum 4 phones can be selected!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D44) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: Colors.blue, width: 3)
                  : null,
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
                // Image
                Container(
                  height: 120,
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
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Phone info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${phone.storageOptions.first}GB • ${phone.chip}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Text(
                          '\$${phone.price}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
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
    );
  }

  Widget _buildMacGrid(bool isDark) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridColumns(context),
        childAspectRatio: 0.75,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: filteredMacs.length,
      itemBuilder: (context, index) {
        final mac = filteredMacs[index];
        final isSelected = selectedMacs.contains(mac);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedMacs.remove(mac);
              } else {
                if (selectedMacs.length < 4) {
                  selectedMacs.add(mac);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Maximum 4 Macs can be selected!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D44) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: Colors.blue, width: 3)
                  : null,
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
                // Image
                Container(
                  height: 120,
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
                          mac.image,
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Mac info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mac.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${mac.storageOptions.first}GB • ${mac.chip}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Text(
                          '\$${mac.price}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
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
    );
  }

  Widget _buildBrandChip(String brand) {
    final isSelected = selectedBrand == brand;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(
        brand,
        style: TextStyle(
          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          selectedBrand = brand;
        });
      },
      selectedColor: Colors.blue,
      backgroundColor: isDark ? const Color(0xFF2D2D44) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3)),
    );
  }

  Widget _buildiPadGrid(bool isDark) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridColumns(context),
        childAspectRatio: 0.75,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: filterediPads.length,
      itemBuilder: (context, index) {
        final ipad = filterediPads[index];
        final isSelected = selectediPads.contains(ipad);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectediPads.remove(ipad);
              } else {
                if (selectediPads.length < 4) {
                  selectediPads.add(ipad);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Maximum 4 iPads can be selected!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D44) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: Colors.purple, width: 3)
                  : null,
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
                // Image
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purple.withOpacity(0.1),
                        Colors.purple.withOpacity(0.2),
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
                          ipad.image,
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // iPad info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ipad.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${ipad.storageOptions.first}GB • ${ipad.chip}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Text(
                          '\$${ipad.price}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
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
    );
  }

  Widget _buildAirPodsGrid(bool isDark) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridColumns(context),
        childAspectRatio: 0.75,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: filteredAirPods.length,
      itemBuilder: (context, index) {
        final airpod = filteredAirPods[index];
        final isSelected = selectedAirPods.contains(airpod);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedAirPods.remove(airpod);
              } else {
                if (selectedAirPods.length < 4) {
                  selectedAirPods.add(airpod);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Maximum 4 AirPods can be selected!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D44) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: Colors.purple, width: 3)
                  : null,
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
                // Image
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purple.withOpacity(0.1),
                        Colors.purple.withOpacity(0.2),
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
                          airpod.image,
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // AirPods info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              airpod.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${airpod.batteryLife}h • ${airpod.chip}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Text(
                          '\$${airpod.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
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
    );
  }
  Widget _buildWatchesGrid(bool isDark) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridColumns(context),
        childAspectRatio: 0.75,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: filteredWatches.length,
      itemBuilder: (context, index) {
        final watch = filteredWatches[index];
        final isSelected = selectedWatches.contains(watch);
        return _buildSelectableCard(
          isDark: isDark,
          isSelected: isSelected,
          gradientColors: [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
          imageText: watch.image,
          title: watch.name,
          subtitle: watch.chip ?? '',
          priceText: '\$${watch.price.toStringAsFixed(0)}',
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedWatches.remove(watch);
              } else {
                if (selectedWatches.length < 4) selectedWatches.add(watch);
              }
            });
          },
          checkColor: const Color(0xFF4A90E2),
        );
      },
    );
  }

  Widget _buildLaptopsGrid(bool isDark) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridColumns(context),
        childAspectRatio: 0.75,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: filteredLaptops.length,
      itemBuilder: (context, index) {
        final laptop = filteredLaptops[index];
        final isSelected = selectedLaptops.contains(laptop);
        return _buildSelectableCard(
          isDark: isDark,
          isSelected: isSelected,
          gradientColors: [Colors.blue.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
          imageText: laptop.image,
          title: laptop.name,
          subtitle: '${laptop.storageOptions.first}GB • ${laptop.processor}',
          priceText: '\$${laptop.price.toStringAsFixed(0)}',
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedLaptops.remove(laptop);
              } else {
                if (selectedLaptops.length < 4) selectedLaptops.add(laptop);
              }
            });
          },
          checkColor: Colors.blue,
        );
      },
    );
  }

  Widget _buildTabletsGrid(bool isDark) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridColumns(context),
        childAspectRatio: 0.75,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: filteredTablets.length,
      itemBuilder: (context, index) {
        final tablet = filteredTablets[index];
        final isSelected = selectedTablets.contains(tablet);
        return _buildSelectableCard(
          isDark: isDark,
          isSelected: isSelected,
          gradientColors: [Colors.purple.withOpacity(0.1), Colors.purple.withOpacity(0.2)],
          imageText: tablet.image,
          title: tablet.name,
          subtitle: '${tablet.storageOptions.first}GB • ${tablet.chip}',
          priceText: '\$${tablet.price.toStringAsFixed(0)}',
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedTablets.remove(tablet);
              } else {
                if (selectedTablets.length < 4) selectedTablets.add(tablet);
              }
            });
          },
          checkColor: Colors.purple,
        );
      },
    );
  }

  Widget _buildHeadphonesGrid(bool isDark) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridColumns(context),
        childAspectRatio: 0.75,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: filteredHeadphones.length,
      itemBuilder: (context, index) {
        final h = filteredHeadphones[index];
        final isSelected = selectedHeadphones.contains(h);
        return _buildSelectableCard(
          isDark: isDark,
          isSelected: isSelected,
          gradientColors: [Colors.blueGrey.withOpacity(0.1), Colors.blueGrey.withOpacity(0.2)],
          imageText: h.image,
          title: h.name,
          subtitle: '${h.batteryLife ?? 0}h',
          priceText: '\$${h.price.toStringAsFixed(0)}',
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedHeadphones.remove(h);
              } else {
                if (selectedHeadphones.length < 4) selectedHeadphones.add(h);
              }
            });
          },
          checkColor: Colors.blueGrey,
        );
      },
    );
  }

  Widget _buildSelectableCard({
    required bool isDark,
    required bool isSelected,
    required List<Color> gradientColors,
    required String imageText,
    required String title,
    required String subtitle,
    required String priceText,
    required VoidCallback onTap,
    required Color checkColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D44) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: checkColor, width: 3) : null,
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
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
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
                      imageText,
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: checkColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Text(
                      priceText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
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
}
