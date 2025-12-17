import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../util/color.dart';
import '../widgets/interstitial_ad_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // 2초 대기
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 전면 광고 표시 시도 (광고가 없으면 바로 넘어감)
    await InterstitialAdWidget.showInterstitialAd();

    if (!mounted) return;

    // 홈 화면으로 이동 (바인딩 포함)
    Get.offAllNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 아이콘 또는 로고
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smoking_rooms,
                size: 80,
                color: AppColor.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '도와줘 금연',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '건강한 금연 여정을 시작하세요',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
