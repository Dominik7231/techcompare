import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/settings.dart';
import '../services/auth_service.dart';
import '../data/phones_data.dart';
import '../data/macs_data.dart';
import '../data/ipads_data.dart';
import 'phone_detail_screen.dart';
import 'mac_detail_screen.dart';
import 'ipad_detail_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const ProfileScreen({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userName;
  String _userAvatar = '👤';
  String? _favoriteCategory;
  List<String> _searchHistory = [];
  List<Map<String, dynamic>> _viewedProducts = [];
  List<Map<String, dynamic>> _comparisonHistory = [];
  List<Map<String, dynamic>> _filterPresets = [];
  List<Map<String, String>> _newsItems = [
    {
      'title': 'Version 1.0.89 released',
      'date': '2025-11-13',
      'version': '1.0.89',
      'content': 'QR scanner fixed with permissions and auto-navigation; share outputs improved.'
    },
    {
      'title': 'Version 1.0.88 released',
      'date': '2025-11-13',
      'version': '1.0.88',
      'content': 'Added QR code sharing and scanner. Renamed Compare menu to Compare Devices and fixed icons.'
    },
    {
      'title': 'Version 1.0.87 released',
      'date': '2025-11-13',
      'version': '1.0.87',
      'content': 'Sharing now supports Tweet and Markdown formats. Added News Feed in Profile.'
    },
    {
      'title': 'Share buttons added',
      'date': '2025-11-12',
      'version': '1.0.86',
      'content': 'You can share specs from detail screens for phones, Macs and iPads.'
    },
  ];
  final TextEditingController _nameController = TextEditingController();
  String _appVersion = '1.0.106';
  final _authService = AuthService();
  bool _hasFirebaseUser = false;
  final TextEditingController _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadAppVersion();
    
    // Listen to auth state changes to update UI when user logs in/out
    _setupAuthListener();
  }
  
  void _setupAuthListener() {
    try {
      _authService.authStateChanges.listen((user) {
        if (mounted) {
          _loadProfileData();
        }
      }, onError: (error) {
        debugPrint('Auth state listener error: $error');
        // If listener fails, just reload profile data once
        if (mounted) {
          _loadProfileData();
        }
      });
    } catch (e) {
      debugPrint('Error setting up auth listener: $e');
      // Continue without listener if Firebase is not available
    }
  }

  Future<void> _loadAppVersion() async {
    // Try to get version from package_info_plus
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (e) {
      // If package_info fails, keep the default version (1.0.55)
      print('Could not load version: $e');
    }
  }

  Future<void> _loadProfileData() async {
    // Get Firebase user data if logged in
    String? name;
    bool hasFirebaseUser = false;
    
    try {
      final firebaseUser = _authService.currentUser;
      
      if (firebaseUser != null) {
        hasFirebaseUser = true;
        // Use Firebase display name if available
        name = firebaseUser.displayName;
        // If Firebase user has no display name, try local storage
        if (name == null || name.isEmpty) {
          name = await UserProfileManager.getUserName();
        }
      } else {
        hasFirebaseUser = false;
        // Fallback to local storage
        name = await UserProfileManager.getUserName();
      }
    } catch (e) {
      // If Firebase is not available, use local storage
      debugPrint('Error getting Firebase user: $e');
      hasFirebaseUser = false;
      name = await UserProfileManager.getUserName();
    }
    
    // Load other profile data
    try {
      final avatar = await UserProfileManager.getUserAvatar();
      final category = await UserProfileManager.getFavoriteCategory();
      final searches = await HistoryManager.getSearchHistory();
      final viewed = await HistoryManager.getViewedProducts();
      final comparisons = await HistoryManager.getComparisonHistory();
      final presets = await FilterPresetManager.getFilterPresets();

      if (mounted) {
        setState(() {
          _userName = name;
          _userAvatar = avatar;
          _favoriteCategory = category;
          _searchHistory = searches;
          _viewedProducts = viewed;
          _comparisonHistory = comparisons;
          _filterPresets = presets;
          _hasFirebaseUser = hasFirebaseUser;
          _nameController.text = name ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading profile data: $e');
      // Still update UI with what we have
      if (mounted) {
        setState(() {
          _userName = name;
          _hasFirebaseUser = hasFirebaseUser;
          _nameController.text = name ?? '';
        });
      }
    }
  }
  
  Future<void> _showLoginOptions() async {
    final isDark = widget.themeMode == ThemeMode.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF2D3142) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose an option to continue',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(themeMode: widget.themeMode),
                    ),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: isDark ? const Color(0xFF6366F1) : const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterScreen(themeMode: widget.themeMode),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Sign Up'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.themeMode == ThemeMode.dark 
            ? const Color(0xFF2D3142) 
            : Colors.white,
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      // Guard for platforms without Firebase (e.g., web preview)
      if (!_authService.isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication is not available on this platform.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      try {
        await _authService.signOut();
        // Reload profile data to update UI
        await _loadProfileData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _saveUserName() async {
    await UserProfileManager.setUserName(_nameController.text);
    await _loadProfileData();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name saved!')));
    }
  }

  Future<void> _selectAvatar() async {
    final avatars = [
      '👤',
      '👨',
      '👩',
      '🧑',
      '👨‍💻',
      '👩‍💻',
      '🎯',
      '🚀',
      '⭐',
      '🔥',
    ];
    final isDark = widget.themeMode == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D3142) : Colors.white,
        title: const Text('Select Avatar'),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: avatars.map((avatar) {
            return GestureDetector(
              onTap: () async {
                await UserProfileManager.setUserAvatar(avatar);
                Navigator.pop(context);
                await _loadProfileData();
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _userAvatar == avatar
                      ? (isDark ? Colors.blue.shade700 : Colors.blue.shade100)
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(avatar, style: const TextStyle(fontSize: 30)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _selectFavoriteCategory() async {
    final categories = ['Phones', 'Macs', 'iPads'];
    final isDark = widget.themeMode == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D3142) : Colors.white,
        title: const Text('Select Favorite Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((category) {
            return ListTile(
              title: Text(category),
              selected: _favoriteCategory == category,
              onTap: () async {
                await UserProfileManager.setFavoriteCategory(category);
                Navigator.pop(context);
                await _loadProfileData();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: isDark ? const Color(0xFF2D3142) : Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                        : [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _selectAvatar,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            _userAvatar,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Your Name',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _saveUserName(),
                          ),
                          const SizedBox(height: 8),
                          if (_favoriteCategory != null)
                            Text(
                              'Favorite: $_favoriteCategory',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settings Section
              _buildSectionTitle('Settings', isDark),
              const SizedBox(height: 12),
              _buildSettingTile(
                icon: Icons.category,
                title: 'Favorite Category',
                subtitle: _favoriteCategory ?? 'Not set',
                isDark: isDark,
                onTap: _selectFavoriteCategory,
              ),
              _buildSettingTile(
                icon: widget.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
                title: 'Theme',
                subtitle: widget.themeMode == ThemeMode.dark ? 'Dark' : 'Light',
                isDark: isDark,
                onTap: widget.onToggleTheme,
              ),
              _buildSettingTile(
                icon: Icons.card_giftcard,
                title: 'Enter promo code',
                subtitle: 'Unlock extra AI requests',
                isDark: isDark,
                onTap: () => _showPromoCodeDialog(isDark),
              ),
              if (_hasFirebaseUser)
                _buildSettingTile(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Sign out from your account',
                  isDark: isDark,
                  onTap: _signOut,
                )
              else
                _buildSettingTile(
                  icon: Icons.login,
                  title: 'Sign In / Sign Up',
                  subtitle: 'Create account or sign in',
                  isDark: isDark,
                  onTap: _showLoginOptions,
                ),

              const SizedBox(height: 16),

              // Version Info - Right after Settings for visibility
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF6366F1).withOpacity(0.3),
                            const Color(0xFF8B5CF6).withOpacity(0.3),
                          ]
                        : [
                            const Color(0xFF4A90E2).withOpacity(0.2),
                            const Color(0xFF357ABD).withOpacity(0.2),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isDark ? Colors.white70 : Colors.blue.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'App Version',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _appVersion,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Social Links
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D3142) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.public,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  title: Text(
                    'Follow on X (Twitter)',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    '@Dominik7231',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  trailing: Icon(
                    Icons.open_in_new,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  onTap: () async {
                    final url = Uri.parse('https://x.com/Dominik7231');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),

              const SizedBox(height: 32),

              // News Feed Section
              _buildSectionTitle('News Feed', isDark),
              const SizedBox(height: 12),
              Card(
                color: isDark ? const Color(0xFF2D3142) : Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(Icons.article, color: isDark ? Colors.white : const Color(0xFF2D3142)),
                  title: const Text('Latest updates'),
                  subtitle: Text('${_newsItems.length} items'),
                  onTap: () => _showNewsFeed(isDark),
                ),
              ),

              const SizedBox(height: 32),

              // History Section
              _buildSectionTitle('History', isDark),
              const SizedBox(height: 12),
              _buildHistoryTile(
                icon: Icons.search,
                title: 'Search History',
                count: _searchHistory.length,
                isDark: isDark,
                onTap: () => _showSearchHistory(isDark),
                onClear: () async {
                  await HistoryManager.clearSearchHistory();
                  await _loadProfileData();
                },
              ),
              _buildHistoryTile(
                icon: Icons.visibility,
                title: 'Viewed Products',
                count: _viewedProducts.length,
                isDark: isDark,
                onTap: () => _showViewedProducts(isDark),
                onClear: () async {
                  await HistoryManager.clearViewedProducts();
                  await _loadProfileData();
                },
              ),
              _buildHistoryTile(
                icon: Icons.compare_arrows,
                title: 'Comparisons',
                count: _comparisonHistory.length,
                isDark: isDark,
                onTap: () => _showComparisonHistory(isDark),
                onClear: () async {
                  await HistoryManager.clearComparisonHistory();
                  await _loadProfileData();
                },
              ),

              // Filter Presets Section
              _buildSectionTitle('Filter Presets', isDark),
              const SizedBox(height: 12),
              if (_filterPresets.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No saved filter presets',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                )
              else
                ..._filterPresets.map(
                  (preset) => _buildPresetTile(
                    name: preset['name'] as String,
                    isDark: isDark,
                    onDelete: () async {
                      await FilterPresetManager.deleteFilterPreset(
                        preset['name'] as String,
                      );
                      await _loadProfileData();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewsFeed(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D3142) : Colors.white,
        title: const Text('News Feed'),
        content: SizedBox(
          width: double.maxFinite,
          child: _newsItems.isEmpty
              ? const Text('No news yet')
              : ListView.builder(
                shrinkWrap: true,
                itemCount: _newsItems.length,
                itemBuilder: (context, index) {
                  final item = _newsItems[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item['title'] ?? ''),
                    subtitle: Text('${item['date']} • Version ${item['version']}\n${item['content'] ?? ''}'),
                  );
                },
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF2D3142),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3142) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
        title: Text(
          title,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildHistoryTile({
    required IconData icon,
    required String title,
    required int count,
    required bool isDark,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3142) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
        title: Text(
          title,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        subtitle: Text(
          '$count items',
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (count > 0)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
                tooltip: 'Clear',
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: count > 0 ? onTap : null,
      ),
    );
  }

  Widget _buildPresetTile({
    required String name,
    required bool isDark,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3142) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.filter_list),
        title: Text(
          name,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }

  void _showSearchHistory(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D3142) : Colors.white,
        title: const Text('Search History'),
        content: SizedBox(
          width: double.maxFinite,
          child: _searchHistory.isEmpty
              ? const Text('No search history')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchHistory.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_searchHistory[index]),
                      dense: true,
                    );
                  },
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

  void _showViewedProducts(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D3142) : Colors.white,
        title: const Text('Viewed Products'),
        content: SizedBox(
          width: double.maxFinite,
          child: _viewedProducts.isEmpty
              ? const Text('No viewed products')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _viewedProducts.length,
                  itemBuilder: (context, index) {
                    final item = _viewedProducts[index];
                    return ListTile(
                      title: Text(item['name'] as String),
                      subtitle: Text('${item['category']} - ${item['type']}'),
                      dense: true,
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToProduct(item);
                      },
                    );
                  },
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

  void _showComparisonHistory(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D3142) : Colors.white,
        title: const Text('Comparison History'),
        content: SizedBox(
          width: double.maxFinite,
          child: _comparisonHistory.isEmpty
              ? const Text('No comparison history')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _comparisonHistory.length,
                  itemBuilder: (context, index) {
                    final item = _comparisonHistory[index];
                    final products = (item['products'] as List).cast<String>();
                    return ListTile(
                      title: Text(products.join(' vs ')),
                      subtitle: Text(item['category'] as String),
                      dense: true,
                    );
                  },
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

  void _navigateToProduct(Map<String, dynamic> item) {
    final name = item['name'] as String;
    final category = item['category'] as String;
    final type = item['type'] as String;

    if (category == 'Phones' && type == 'phone') {
      final phone = allPhones.firstWhere((p) => p.name == name);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneDetailScreen(phone: phone),
        ),
      );
    } else if (category == 'Macs' && type == 'mac') {
      final mac = allMacs.firstWhere((m) => m.name == name);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MacDetailScreen(mac: mac)),
      );
    } else if (category == 'iPads' && type == 'ipad') {
      final ipad = alliPads.firstWhere((i) => i.name == name);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => iPadDetailScreen(ipad: ipad)),
      );
    }
  }

  Future<void> _showPromoCodeDialog(bool isDark) async {
    _promoController.clear();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D3142) : Colors.white,
        title: const Text('Enter promo code'),
        content: TextField(
          controller: _promoController,
          decoration: const InputDecoration(
            labelText: 'Promo code',
            hintText: 'Enter code here',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (result == true) {
      final code = _promoController.text.trim();
      if (code == '0505') {
        final success = await AIUsageManager.applyPromo0505();
        if (!mounted) return;
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Promo applied! You received +100 AI requests.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This promo code was already used.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid promo code.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
