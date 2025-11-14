import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Your AdMob Ad Unit IDs
  static const String _bannerAdUnitId = 'ca-app-pub-6484170221531266/3671532174';
  static const String _rewardedAdUnitId = 'ca-app-pub-6484170221531266/1506056349';

  // Test IDs for development
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedInterstitialId =
      'ca-app-pub-3940256099942544/5354046379';

  // Use test ads during development, real ads in production
  static bool get _isTestMode => false; // Set to false for production!

  static String get bannerAdUnitId => _isTestMode ? _testBannerId : _bannerAdUnitId;
  static String get rewardedAdUnitId => _isTestMode ? _testRewardedInterstitialId : _rewardedAdUnitId;

  static bool _isInitialized = false;
  static String? _lastError;

  // Initialize AdMob
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final initStatus = await MobileAds.instance.initialize();
      _isInitialized = true;
      print('AdMob initialized successfully');
      print('Adapter statuses: ${initStatus.adapterStatuses}');
    } catch (e) {
      _lastError = e.toString();
      print('AdMob initialization error: $e');
      _isInitialized = false;
    }
  }

  static bool get isInitialized => _isInitialized;
  static String? get lastError => _lastError;

  // Create Banner Ad
  BannerAd createBannerAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    if (!_isInitialized) {
      print('Warning: AdMob not initialized before creating banner ad');
    }

    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded successfully');
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load:');
          print('  Error code: ${error.code}');
          print('  Error message: ${error.message}');
          print('  Error domain: ${error.domain}');
          print('  Response info: ${error.responseInfo}');
          _lastError = 'Banner: ${error.code} - ${error.message}';
          onAdFailedToLoad(ad, error);
        },
      ),
    );
  }



  // Create Rewarded Interstitial Ad
  static Future<RewardedInterstitialAd?> createRewardedInterstitialAd() async {
    if (!_isInitialized) {
      print('Warning: AdMob not initialized, attempting to initialize...');
      await initialize();
      if (!_isInitialized) {
        _lastError = 'AdMob initialization failed';
        return null;
      }
    }

    RewardedInterstitialAd? rewardedInterstitialAd;
    bool adLoaded = false;
    LoadAdError? loadError;

    print(
      'Loading rewarded ad with ID: $rewardedAdUnitId',
    );

    await RewardedInterstitialAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedInterstitialAd = ad;
          adLoaded = true;
          print('RewardedInterstitialAd loaded successfully');
        },
        onAdFailedToLoad: (error) {
          loadError = error;
          print('RewardedInterstitialAd failed to load:');
          print('  Error code: ${error.code}');
          print('  Error message: ${error.message}');
          print('  Error domain: ${error.domain}');
          print('  Response info: ${error.responseInfo}');
          _lastError = 'Rewarded: ${error.code} - ${error.message}';
        },
      ),
    );

    // Wait a bit to ensure callback is processed
    await Future.delayed(const Duration(milliseconds: 500));

    if (!adLoaded && loadError != null) {
      print('Ad load failed: ${loadError!.code} - ${loadError!.message}');
    }

    return rewardedInterstitialAd;
  }

  // Show Rewarded Interstitial Ad
  static void showRewardedInterstitialAd(
    RewardedInterstitialAd? ad, {
    required Function(RewardItem reward) onRewarded,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailed,
  }) {
    if (ad == null) {
      onAdFailed?.call();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Failed to show rewarded interstitial ad: $error');
        ad.dispose();
        onAdFailed?.call();
      },
    );

    ad.setImmersiveMode(true);

    ad.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded(reward);
      },
    );
  }
}
