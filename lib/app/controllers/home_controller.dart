import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import '../models/future_reward.dart';

class HomeController extends GetxController {
  // Observable 변수들
  final elapsed = Duration.zero.obs;
  final targetPeriod = '3일'.obs; // 기본값 3일
  final currentMotivationalMessage = '저는 자제 중입니다!'.obs;

  // 금연 동기부여 문구 목록
  static const List<String> motivationalMessages = [
    '저는 자제 중입니다!',
    '나는 강하다! 금연을 이겨낼 수 있다!',
    '건강한 미래를 위해 지금 선택한다!',
    '금연은 나에게 주는 최고의 선물이다!',
    '매 순간이 새로운 시작이다!',
    '나는 담배 없이도 행복할 수 있다!',
    '금연으로 더 나은 나를 만들어간다!',
    '지금의 선택이 내 인생을 바꾼다!',
    '금연은 나의 힘을 보여주는 증거다!',
    '자유로운 호흡, 자유로운 나!',
    '금연으로 더 건강하고 행복한 나를 만든다!',
  ];

  // 설정값
  final cigarettesPerDay = 20.obs; // 하루 담배 개비 수
  final double pricePerPack = 4500;
  final int cigarettesPerPack = 20;

  late DateTime quitDate;
  Timer? _timer;
  Timer? _messageTimer;
  final _random = Random();

  @override
  void onInit() {
    super.onInit();
    // 금연 시작일 (1일 18시간 4분 34초 전)
    quitDate = DateTime.now().subtract(
      const Duration(days: 1, hours: 18, minutes: 4, seconds: 34),
    );
    _updateElapsed();
    _startTimer();
    _startMessageTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _messageTimer?.cancel();
    super.onClose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsed();
    });
  }

  void _startMessageTimer() {
    // 5초마다 문구 변경
    _messageTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _changeMotivationalMessage();
    });
  }

  void _changeMotivationalMessage() {
    // 현재 문구와 다른 랜덤 문구 선택
    String newMessage;
    do {
      newMessage =
          motivationalMessages[_random.nextInt(motivationalMessages.length)];
    } while (newMessage == currentMotivationalMessage.value &&
        motivationalMessages.length > 1);

    currentMotivationalMessage.value = newMessage;
  }

  void _updateElapsed() {
    elapsed.value = DateTime.now().difference(quitDate);
  }

  void refresh() {
    _updateElapsed();
  }

  void reset() {
    quitDate = DateTime.now();
    elapsed.value = Duration.zero;
    _updateElapsed();
  }

  // Getters
  int get days => elapsed.value.inDays;

  Duration get targetDuration {
    return _parseTargetPeriod(targetPeriod.value);
  }

  Duration _parseTargetPeriod(String period) {
    if (period.contains('일')) {
      final days = int.tryParse(period.replaceAll('일', '')) ?? 3;
      return Duration(days: days);
    } else if (period.contains('주')) {
      final weeks = int.tryParse(period.replaceAll('주', '')) ?? 1;
      return Duration(days: weeks * 7);
    } else if (period.contains('개월')) {
      final months = int.tryParse(period.replaceAll('개월', '')) ?? 1;
      return Duration(days: months * 30);
    } else if (period.contains('년')) {
      final years = int.tryParse(period.replaceAll('년', '')) ?? 1;
      return Duration(days: years * 365);
    }
    return const Duration(days: 3); // 기본값
  }

  double get progressPercentage {
    final targetSeconds = targetDuration.inSeconds;
    final progress = elapsed.value.inSeconds / targetSeconds;
    return (progress * 100).clamp(0, 100);
  }

  void setTargetPeriod(String period) {
    targetPeriod.value = period;
  }

  // 한 개비당 225원으로 계산
  int get moneySaved {
    return cigarettesNotSmoked * 225;
  }

  Duration get lifeRegained {
    // 담배 한 개비당 11분의 수명 단축
    final totalCigarettesNotSmoked =
        (elapsed.value.inMinutes / (24 * 60)) * cigarettesPerDay.value;
    return Duration(minutes: (totalCigarettesNotSmoked * 11).round());
  }

  // 설정한 하루 담배 개비 수와 경과 시간에 의거하여 피우지 않은 담배 개비 수 계산
  int get cigarettesNotSmoked {
    // 경과 시간(일 단위) * 하루 담배 개비 수
    final daysElapsed = elapsed.value.inDays;
    final hoursElapsed = elapsed.value.inHours % 24;
    final minutesElapsed = elapsed.value.inMinutes % 60;

    // 일 단위 + 시간 단위 + 분 단위를 모두 고려
    final totalDays =
        daysElapsed + (hoursElapsed / 24) + (minutesElapsed / (24 * 60));
    return (totalDays * cigarettesPerDay.value).round();
  }

  void setCigarettesPerDay(int value) {
    if (value > 0) {
      cigarettesPerDay.value = value;
    }
  }

  String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '${days}일 ${hours}시간 ${minutes}분 ${seconds}초';
    } else if (hours > 0) {
      return '${hours}시간 ${minutes}분 ${seconds}초';
    } else if (minutes > 0) {
      return '${minutes}분 ${seconds}초';
    } else {
      return '${seconds}초';
    }
  }

  String get elapsedFormatted => formatDuration(elapsed.value);
  String get lifeRegainedFormatted => formatDuration(lifeRegained);
  String get moneySavedFormatted {
    final amount = moneySaved;
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '₩ $formatted';
  }

  String get cigarettesNotSmokedFormatted => '${cigarettesNotSmoked}개비';

  // 과거 흡연 기간 데이터 (예시 데이터 - 실제로는 사용자 입력 또는 저장된 데이터 사용)
  // 스크린샷 기준: 29,200개비, ₩ 4,379,999.5, 7달 13일 1시간
  int get totalCigarettesSmoked => 29200;
  double get totalMoneyWasted => 4379999.5;
  Duration get totalLifeLost {
    // 7달 13일 1시간 = 약 223일 1시간
    return const Duration(days: 223, hours: 1);
  }

  String formatLifeLost(Duration duration) {
    final months = duration.inDays ~/ 30;
    final days = duration.inDays % 30;
    final hours = duration.inHours % 24;

    if (months > 0) {
      return '${months}달 ${days}일 ${hours}시간';
    } else if (days > 0) {
      return '${days}일 ${hours}시간';
    } else {
      return '${hours}시간';
    }
  }

  String get totalLifeLostFormatted => formatLifeLost(totalLifeLost);
  String get totalMoneyWastedFormatted =>
      '₩ ${totalMoneyWasted.toStringAsFixed(1)}';

  List<FutureReward> get futureRewards => [
    FutureReward(
      period: '1주',
      money: 16800,
      life: const Duration(hours: 20, minutes: 32),
    ),
    FutureReward(
      period: '1개월',
      money: 72000,
      life: const Duration(days: 3, hours: 16),
    ),
    FutureReward(
      period: '1년',
      money: 876000,
      life: const Duration(days: 44, hours: 14), // 1달 14일 14시간
    ),
    FutureReward(
      period: '5년',
      money: 4380000,
      life: const Duration(days: 223, hours: 1), // 7달 13일 1시간
    ),
    FutureReward(
      period: '10년',
      money: 8760000,
      life: const Duration(days: 446, hours: 0), // 1년 2달 26일
    ),
    FutureReward(
      period: '20년',
      money: 17520000,
      life: const Duration(days: 892, hours: 0), // 2년 5달 22일
    ),
  ];

  String formatFutureLife(Duration duration) {
    final years = duration.inDays ~/ 365;
    final months = (duration.inDays % 365) ~/ 30;
    final days = (duration.inDays % 365) % 30;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (years > 0) {
      if (months > 0) {
        if (days > 0) {
          return '${years}년 ${months}달 ${days}일';
        }
        return '${years}년 ${months}달';
      }
      return '${years}년';
    } else if (months > 0) {
      if (days > 0) {
        if (hours > 0) {
          return '${months}달 ${days}일 ${hours}시간';
        }
        return '${months}달 ${days}일';
      }
      if (hours > 0) {
        return '${months}달 ${hours}시간';
      }
      return '${months}달';
    } else if (days > 0) {
      if (hours > 0) {
        if (minutes > 0) {
          return '${days}일 ${hours}시간 ${minutes}분';
        }
        return '${days}일 ${hours}시간';
      }
      return '${days}일';
    } else if (hours > 0) {
      if (minutes > 0) {
        return '${hours}시간 ${minutes}분';
      }
      return '${hours}시간';
    } else {
      return '${minutes}분';
    }
  }
}
