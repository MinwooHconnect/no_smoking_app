import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app/routes/app_pages.dart';
import 'app/util/color.dart';

import 'app/widgets/interstitial_ad_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 애드몹 초기화 (에러 발생 시에도 앱은 실행되도록)
  try {
    await MobileAds.instance.initialize();
    // 전면 광고 미리 로드
    InterstitialAdWidget.preloadAd();
  } catch (e) {
    debugPrint('애드몹 초기화 실패: $e');
  }

  runApp(const NoSmokingApp());
}

class NoSmokingApp extends StatelessWidget {
  const NoSmokingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: AppPages.routes,
      initialRoute: AppPages.initial,
      debugShowCheckedModeBanner: true,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
        useMaterial3: true,
      ),
    );
  }
}
