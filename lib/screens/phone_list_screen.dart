import 'package:flutter/material.dart';
import 'package:techcomparev1/utils/version_text.dart';
import '../models/phone.dart';
import '../data/phones_data.dart';
import '../data/macs_data.dart';
import '../data/ipads_data.dart';
import '../utils/settings.dart';
import 'compare_screen.dart';
import 'phone_detail_screen.dart';
import 'ai_assistant_screen.dart';

class PhoneListScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const PhoneListScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<PhoneListScreen> createState() => _PhoneListScreenState();
}

class _PhoneListScreenState extends State<PhoneListScreen> {
  final List<Phone> selectedPhones = [];
  String sortBy = 'name'; // name, price, storage, battery
  bool ascending = true;

  // Search and filtering
  String searchQuery = '';
  RangeValues priceRange = const RangeValues(0, 1500);
  List<String> selectedStorages = [];

  List<Phone> get sortedPhones {
    // First filter the phones
    List<Phone> phones = List<Phone>.from(iphones);

    // Search filter
    if (searchQuery.isNotEmpty) {
      phones = phones.where((phone) {
        return phone.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            phone.chip.toLowerCase().contains(searchQuery.toLowerCase()) ||
            phone.display.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Price filter
    phones = phones.where((phone) {
      return phone.price >= priceRange.start && phone.price <= priceRange.end;
    }).toList();

    // Storage filter
    if (selectedStorages.isNotEmpty) {
      phones = phones.where((phone) {
        return selectedStorages.any(
          (storage) => phone.storageOptions.any(
            (option) => option.toString() == storage,
          ),
        );
      }).toList();
    }

    // Sort
    phones.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'storage':
          comparison = a.storage.compareTo(b.storage);
          break;
        case 'battery':
          comparison = a.battery.compareTo(b.battery);
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }
      return ascending ? comparison : -comparison;
    });
    return phones;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iPhone Compare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AIAssistantScreen(phones: allPhones, macs: allMacs, ipads: alliPads),
                ),
              );
            },
            tooltip: 'AI Assistant',
          ),
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle theme',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'sort') {
                _showSortDialog();
              } else if (value == 'about') {
                _showAboutDialog(context);
              } else if (value == 'currency') {
                _showCurrencyDialog();
              } else if (value == 'favorites') {
                _showFavoritesDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'currency',
                child: Row(
                  children: [
                    Icon(Icons.attach_money),
                    SizedBox(width: 8),
                    Text('Currency'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'favorites',
                child: Row(
                  children: [
                    Icon(Icons.favorite),
                    SizedBox(width: 8),
                    Text('Favorites'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sort',
                child: Row(
                  children: [
                    Icon(Icons.sort),
                    SizedBox(width: 8),
                    Text('Sort'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('About'),
                  ],
                ),
              ),
            ],
          ),
          if (selectedPhones.length >= 2)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CompareScreen(phones: selectedPhones),
                    ),
                  );
                },
                icon: const Icon(Icons.compare_arrows),
                label: Text('(${selectedPhones.length})'),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '🔍 Search by name, chip or display...',
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price filter
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Price: \$${priceRange.start.round()}-\$${priceRange.end.round()}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                RangeSlider(
                  values: priceRange,
                  min: 0,
                  max: 1500,
                  divisions: 30,
                  labels: RangeLabels(
                    '\$${priceRange.start.round()}',
                    '\$${priceRange.end.round()}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      priceRange = values;
                    });
                  },
                ),
                const SizedBox(height: 8),

                // Storage filter
                Row(
                  children: [
                    const Icon(Icons.storage, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Storage:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['64', '128', '256', '512', '1024'].map((storage) {
                    final isSelected = selectedStorages.contains(storage);
                    return FilterChip(
                      label: Text('${storage}GB'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedStorages.add(storage);
                          } else {
                            selectedStorages.remove(storage);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          if (selectedPhones.isNotEmpty)
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${selectedPhones.length} phones selected. ${selectedPhones.length >= 2 ? 'Click the Compare button!' : 'Select at least one more!'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (selectedPhones.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedPhones.clear();
                        });
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 8,
                bottom: 80,
              ),
              itemCount: sortedPhones.length + 1,
              itemBuilder: (context, index) {
                // Footer with version
                if (index == sortedPhones.length) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.phone_iphone,
                          size: 40,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'iPhone Compare',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'v1.0.10',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '© 2025 Tech Compare',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final phone = sortedPhones[index];
                final isSelected = selectedPhones.contains(phone);

                return Card(
                  elevation: isSelected ? 8 : 2,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  color: isSelected ? Colors.blue.shade50 : null,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhoneDetailScreen(phone: phone),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                phone.image,
                                style: const TextStyle(fontSize: 48),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  phone.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  phone.chip,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.storage,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        phone.storageOptions
                                            .map((s) => '${s}GB')
                                            .join('/'),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.battery_full,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${phone.battery} mAh',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppSettings.formatPrice(phone.price),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(
                                  AppSettings.isFavorite(phone.name)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: AppSettings.isFavorite(phone.name)
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    AppSettings.toggleFavorite(phone.name);
                                  });
                                },
                              ),
                              Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      if (selectedPhones.length < 4) {
                                        selectedPhones.add(phone);
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'You can compare up to 4 phones at a time!',
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } else {
                                      selectedPhones.remove(phone);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('By Name'),
              value: 'name',
              groupValue: sortBy,
              onChanged: (value) {
                setState(() {
                  if (sortBy == value) {
                    ascending = !ascending;
                  } else {
                    sortBy = value!;
                    ascending = true;
                  }
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('By Price'),
              value: 'price',
              groupValue: sortBy,
              onChanged: (value) {
                setState(() {
                  if (sortBy == value) {
                    ascending = !ascending;
                  } else {
                    sortBy = value!;
                    ascending = true;
                  }
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('By Storage'),
              value: 'storage',
              groupValue: sortBy,
              onChanged: (value) {
                setState(() {
                  if (sortBy == value) {
                    ascending = !ascending;
                  } else {
                    sortBy = value!;
                    ascending = true;
                  }
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('By Battery'),
              value: 'battery',
              groupValue: sortBy,
              onChanged: (value) {
                setState(() {
                  if (sortBy == value) {
                    ascending = !ascending;
                  } else {
                    sortBy = value!;
                    ascending = true;
                  }
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Ascending order'),
              value: ascending,
              onChanged: (value) {
                setState(() {
                  ascending = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.phone_iphone, size: 30, color: Colors.blue),
            SizedBox(width: 12),
            Text('iPhone Compare'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VersionText(
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'A modern iPhone comparison app with AI chat assistant that helps you find the perfect iPhone for your needs.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.check_circle, 'Detailed Specifications'),
            _buildInfoRow(Icons.compare_arrows, 'Advanced Compare'),
            _buildInfoRow(Icons.palette, 'Dark Mode Support'),
            _buildInfoRow(Icons.sort, 'Multiple Sort Options'),
            const SizedBox(height: 16),
            const Text(
              '© 2025 Tech Compare',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
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

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.attach_money, color: Colors.green),
              SizedBox(width: 8),
              Text('💱 Currency Selection'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['USD', 'EUR', 'HUF'].map((curr) {
              return RadioListTile<String>(
                title: Text(_getCurrencyName(curr)),
                subtitle: Text(AppSettings.currencySymbols[curr] ?? ''),
                value: curr,
                groupValue: AppSettings.currency,
                onChanged: (value) {
                  setDialogState(() {
                    setState(() {
                      AppSettings.currency = value!;
                    });
                  });
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'USD':
        return 'US Dollar (USD)';
      case 'EUR':
        return 'Euro (EUR)';
      case 'HUF':
        return 'Hungarian Forint (HUF)';
      default:
        return code;
    }
  }

  void _showFavoritesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.favorite, color: Colors.red),
            SizedBox(width: 8),
            Text('⭐ Favorites'),
          ],
        ),
        content: AppSettings.favorites.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'You don\'t have any favorite phones yet.\n\nTap the heart icon on any phone card to add it to your favorites!',
                  textAlign: TextAlign.center,
                ),
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: AppSettings.favorites.map((phoneName) {
                    final phone = iphones.firstWhere(
                      (p) => p.name == phoneName,
                    );
                    return ListTile(
                      leading: Text(
                        phone.image,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(phone.name),
                      subtitle: Text(AppSettings.formatPrice(phone.price)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            AppSettings.toggleFavorite(phoneName);
                          });
                          Navigator.pop(context);
                          _showFavoritesDialog();
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PhoneDetailScreen(phone: phone),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
