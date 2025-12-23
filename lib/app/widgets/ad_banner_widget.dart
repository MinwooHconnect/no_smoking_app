import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../util/color.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // 플랫폼별 배너 광고 단위 ID
  String get _adUnitId {
    if (Platform.isIOS) {
      // iOS 배너 광고 ID
      return 'ca-app-pub-3653426435604549/5935250665';
    } else {
      // Android 배너 광고 ID
      return 'ca-app-pub-3653426435604549/6782107095';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    try {
      _bannerAd = BannerAd(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        size: AdSize.mediumRectangle, // 세로로 긴 직사각형 (320x250)
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            // 광고 로드 실패 시 광고를 해제
            ad.dispose();
            _bannerAd = null;
            debugPrint('광고 로드 실패: $error');
          },
        ),
      );

      _bannerAd?.load();
    } catch (e) {
      debugPrint('광고 생성 실패: $e');
      _bannerAd = null;
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
