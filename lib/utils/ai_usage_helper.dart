import 'dart:async';
import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import 'settings.dart';

class AIUsageHelper {
  // Check and handle AI usage, show ad if needed
  static Future<bool> checkAndHandleAIUsage(BuildContext context) async {
    // Check if user needs to watch ad (reached 5, 10, 15, etc.)
    final shouldShowAd = await AIUsageManager.needsToWatchAd();
    
    if (shouldShowAd) {
      // User must watch ad to continue
      return await _showRewardedAd(context);
    }
    
    return true;
  }

  // Show rewarded interstitial ad - MUST watch ad to continue
  static Future<bool> _showRewardedAd(BuildContext context) async {
    bool adWatched = false;
    const int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries && !adWatched) {
      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  retryCount > 0 
                    ? 'Loading ad... (Attempt ${retryCount + 1}/$maxRetries)'
                    : 'Loading ad...',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }

      try {
        // Load rewarded interstitial ad
        final ad = await AdService.createRewardedInterstitialAd();
        
        // Close loading dialog
        if (context.mounted) {
          Navigator.pop(context);
        }

        if (ad == null) {
          retryCount++;
          if (retryCount < maxRetries) {
            // Wait before retry
            await Future.delayed(const Duration(seconds: 2));
            continue;
          } else {
            // All retries failed - show user-friendly error message
            final errorMsg = AdService.lastError ?? 'Unknown error';
            final isNoFill = errorMsg.contains('No fill') || errorMsg.contains('3');
            
            if (context.mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text('Reklám jelenleg nem érhető el'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jelenleg nem sikerült reklámot betölteni. Próbáld újra később.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      if (isNoFill) ...[
                        const Text(
                          'Lehetséges okok:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        const Text('• Nincs elérhető reklám jelenleg'),
                        const Text('• Az alkalmazás még nincs teljesen jóváhagyva'),
                        const Text('• Próbáld újra később'),
                        const SizedBox(height: 16),
                      ],
                      const Text(
                        'Fontos: Az 5. használat után kötelező reklámot nézni az AI funkciók használatához.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Rendben'),
                    ),
                  ],
                ),
              );
            }
            return false;
          }
        }

        // Show ad with reward callback
        final completer = Completer<bool>();
        
        AdService.showRewardedInterstitialAd(
          ad,
          onRewarded: (reward) async {
            adWatched = true;
            // Add reward usage
            final rewardUsage = await AIUsageManager.getRewardUsage();
            await AIUsageManager.addRewardUsage();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 You earned +$rewardUsage AI uses!'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          },
          onAdDismissed: () {
            if (!adWatched) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please watch the ad completely to continue using AI features.'),
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            } else {
              if (!completer.isCompleted) {
                completer.complete(true);
              }
            }
          },
          onAdFailed: () {
            retryCount++;
            if (retryCount < maxRetries) {
              // Wait before retry
              Future.delayed(const Duration(seconds: 2), () {
                if (!completer.isCompleted) {
                  completer.complete(false);
                }
              });
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ad failed to show. Please try again later.'),
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            }
          },
        );

        // Wait for ad to be watched or dismissed
        adWatched = await completer.future;
        
        if (adWatched) {
          break; // Success, exit retry loop
        } else if (retryCount < maxRetries) {
          // Wait before retry
          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
        }
        retryCount++;
        if (retryCount >= maxRetries) {
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: Text(
                  'Error loading ad: ${e.toString()}\n\nPlease try again later. You must watch an ad to continue using AI features.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          return false;
        }
        // Wait before retry
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    
    return adWatched;
  }

  // Increment AI usage after successful use
  static Future<void> recordAIUsage() async {
    await AIUsageManager.incrementUsage();
  }

  // Get remaining uses for display
  static Future<int> getRemainingUses() async {
    return await AIUsageManager.getRemainingUses();
  }
}

