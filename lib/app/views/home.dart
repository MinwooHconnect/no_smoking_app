import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../util/color.dart';
import '../widgets/progress_card.dart';
import '../widgets/stats_grid_card.dart';
import '../widgets/smoking_period_card.dart';
import '../widgets/future_rewards_card.dart';

class Home extends GetView<HomeController> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 메인 진행률 카드
            const ProgressCard(),

            // 통계 그리드
            const StatsGridCard(),

            // 과거 흡연 기간 카드
            const SmokingPeriodCard(),

            // 미래 보상 카드
            const FutureRewardsCard(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        '금연 앱',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
        IconButton(icon: const Icon(Icons.gps_fixed), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
    );
  }
}
