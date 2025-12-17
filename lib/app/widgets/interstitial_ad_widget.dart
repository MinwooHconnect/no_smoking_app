import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdWidget {
  static InterstitialAd? _interstitialAd;
  static bool _isAdLoaded = false;

  // 테스트용 전면 광고 단위 ID (실제 배포 시에는 실제 광고 단위 ID로 변경)
  // Android 테스트 ID: ca-app-pub-3940256099942544/1033173712
  // iOS 테스트 ID: ca-app-pub-3940256099942544/4411468910
  static const String _adUnitId = 'ca-app-pub-3653426435604549~2970213963';

  // 전면 광고 로드
  static Future<void> loadInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isAdLoaded = true;
            debugPrint('전면 광고 로드 성공');
          },
          onAdFailedToLoad: (error) {
            _interstitialAd = null;
            _isAdLoaded = false;
            debugPrint('전면 광고 로드 실패: $error');
          },
        ),
      );
    } catch (e) {
      debugPrint('전면 광고 생성 실패: $e');
      _interstitialAd = null;
      _isAdLoaded = false;
    }
  }

  // 전면 광고 표시
  static Future<bool> showInterstitialAd() async {
    // 광고가 로드되지 않았으면 먼저 로드 시도
    if (!_isAdLoaded || _interstitialAd == null) {
      await loadInterstitialAd();
      // 로드 후에도 광고가 없으면 false 반환
      if (!_isAdLoaded || _interstitialAd == null) {
        return false;
      }
    }

    try {
      // 광고 표시 전에 콜백 설정
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _isAdLoaded = false;
          // 다음 광고 미리 로드
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          _isAdLoaded = false;
          debugPrint('전면 광고 표시 실패: $error');
        },
      );

      // 광고 표시 (show()는 Future를 반환하지 않음)
      _interstitialAd!.show();
      return true;
    } catch (e) {
      debugPrint('전면 광고 표시 중 오류: $e');
      return false;
    }
  }

  // 광고 미리 로드 (앱 시작 시 호출)
  static void preloadAd() {
    loadInterstitialAd();
  }
}
