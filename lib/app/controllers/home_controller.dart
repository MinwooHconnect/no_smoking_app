import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/future_reward.dart';
import '../services/notification_service.dart';

class HomeController extends GetxController {
  // Observable 변수들
  final elapsed = Duration.zero.obs;
  final targetPeriod = '3일'.obs; // 기본값 3일
  final currentMotivationalMessage = '저는 자제 중입니다!'.obs;
  final isQuittingStarted = false.obs; // 금연 시작 여부
  final isNotificationVisible = true.obs; // 알림 표시 여부
  final customMotivationalMessages = <String>[].obs; // 사용자 정의 응원 메시지
  final disabledMotivationalMessages = <String>{}.obs; // 비활성화된 응원 메시지

  // 금연 동기부여 문구 목록 (기본)
  static const List<String> defaultMotivationalMessages = [
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

  // 사용 가능한 모든 응원 메시지 (기본 + 사용자 정의, 비활성화된 것 제외)
  List<String> get allMotivationalMessages {
    final allMessages = <String>[];
    if (customMotivationalMessages.isNotEmpty) {
      allMessages.addAll(customMotivationalMessages);
    }
    allMessages.addAll(defaultMotivationalMessages);
    // 비활성화된 메시지 제외
    return allMessages
        .where((msg) => !disabledMotivationalMessages.contains(msg))
        .toList();
  }

  // 모든 메시지 (비활성화 여부와 관계없이)
  List<String> get allMessagesIncludingDisabled {
    final allMessages = <String>[];
    if (customMotivationalMessages.isNotEmpty) {
      allMessages.addAll(customMotivationalMessages);
    }
    allMessages.addAll(defaultMotivationalMessages);
    return allMessages;
  }

  // 설정값
  final cigarettesPerDay = 10.obs; // 하루 담배 개비 수 (초기값 10개)
  final isCigarettesPerDaySet = false.obs; // 사용자가 설정했는지 여부
  final double pricePerPack = 4500;
  final int cigarettesPerPack = 20;

  DateTime? quitDate; // 금연 시작일 (null이면 아직 시작하지 않음)
  Timer? _timer;
  Timer? _messageTimer;
  final _random = Random();
  final NotificationService _notificationService = NotificationService();

  // SharedPreferences 키
  static const String _keyQuitDate = 'quitDate';
  static const String _keyCigarettesPerDay = 'cigarettesPerDay';
  static const String _keyIsCigarettesPerDaySet = 'isCigarettesPerDaySet';
  static const String _keyIsQuittingStarted = 'isQuittingStarted';
  static const String _keyTargetPeriod = 'targetPeriod';
  static const String _keyIsNotificationVisible = 'isNotificationVisible';
  static const String _keyCustomMotivationalMessages =
      'customMotivationalMessages';
  static const String _keyDisabledMotivationalMessages =
      'disabledMotivationalMessages';

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
    _loadData();
    _startTimer();
    _startMessageTimer();
  }

  // 알림 초기화
  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  // 데이터 불러오기
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 금연 시작일 불러오기
      final quitDateString = prefs.getString(_keyQuitDate);
      if (quitDateString != null) {
        quitDate = DateTime.parse(quitDateString);
        isQuittingStarted.value = true;
        _updateElapsed();
      } else {
        quitDate = null;
        isQuittingStarted.value = false;
        elapsed.value = Duration.zero;
      }

      // 하루 담배 개비 수 불러오기
      final savedCigarettesPerDay = prefs.getInt(_keyCigarettesPerDay);
      if (savedCigarettesPerDay != null) {
        cigarettesPerDay.value = savedCigarettesPerDay;
      }

      // 설정 여부 불러오기
      final savedIsCigarettesPerDaySet = prefs.getBool(
        _keyIsCigarettesPerDaySet,
      );
      if (savedIsCigarettesPerDaySet != null) {
        isCigarettesPerDaySet.value = savedIsCigarettesPerDaySet;
      }

      // 목표 기간 불러오기
      final savedTargetPeriod = prefs.getString(_keyTargetPeriod);
      if (savedTargetPeriod != null) {
        targetPeriod.value = savedTargetPeriod;
      }

      // 알림 표시 여부 불러오기
      final savedIsNotificationVisible = prefs.getBool(
        _keyIsNotificationVisible,
      );
      if (savedIsNotificationVisible != null) {
        isNotificationVisible.value = savedIsNotificationVisible;
      }

      // 사용자 정의 응원 메시지 불러오기
      final savedCustomMessages = prefs.getStringList(
        _keyCustomMotivationalMessages,
      );
      if (savedCustomMessages != null) {
        customMotivationalMessages.value = savedCustomMessages;
      }
    } catch (e) {
      // 에러 발생 시 기본값 사용
      quitDate = null;
      isQuittingStarted.value = false;
      elapsed.value = Duration.zero;
    }
  }

  // 데이터 저장하기
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 금연 시작일 저장
      if (quitDate != null) {
        await prefs.setString(_keyQuitDate, quitDate!.toIso8601String());
      } else {
        await prefs.remove(_keyQuitDate);
      }

      // 하루 담배 개비 수 저장
      await prefs.setInt(_keyCigarettesPerDay, cigarettesPerDay.value);

      // 설정 여부 저장
      await prefs.setBool(
        _keyIsCigarettesPerDaySet,
        isCigarettesPerDaySet.value,
      );

      // 금연 시작 여부 저장
      await prefs.setBool(_keyIsQuittingStarted, isQuittingStarted.value);

      // 목표 기간 저장
      await prefs.setString(_keyTargetPeriod, targetPeriod.value);

      // 알림 표시 여부 저장
      await prefs.setBool(
        _keyIsNotificationVisible,
        isNotificationVisible.value,
      );

      // 사용자 정의 응원 메시지 저장
      await prefs.setStringList(
        _keyCustomMotivationalMessages,
        customMotivationalMessages,
      );

      // 비활성화된 응원 메시지 저장
      await prefs.setStringList(
        _keyDisabledMotivationalMessages,
        disabledMotivationalMessages.toList(),
      );
    } catch (e) {
      // 저장 실패 시 에러 무시 (선택적)
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    _messageTimer?.cancel();
    _notificationService.cancelNotification();
    super.onClose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isQuittingStarted.value && quitDate != null) {
        _updateElapsed();
      }
    });
  }

  void _startMessageTimer() {
    // 5초마다 문구 변경
    _messageTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _changeMotivationalMessage();
    });
  }

  void _changeMotivationalMessage() {
    final allMessages = allMotivationalMessages;
    if (allMessages.isEmpty) {
      currentMotivationalMessage.value = '저는 자제 중입니다!';
      return;
    }

    // 현재 문구와 다른 랜덤 문구 선택
    String newMessage;
    do {
      newMessage = allMessages[_random.nextInt(allMessages.length)];
    } while (newMessage == currentMotivationalMessage.value &&
        allMessages.length > 1);

    currentMotivationalMessage.value = newMessage;
  }

  // 사용자 정의 응원 메시지 설정
  // messages는 모든 메시지(기본 + 사용자 정의)를 포함할 수 있음
  void setCustomMotivationalMessages(List<String> messages) {
    // 기본 메시지와 겹치는 메시지는 제외하고 사용자 정의 메시지만 저장
    customMotivationalMessages.value = messages
        .where((msg) => !defaultMotivationalMessages.contains(msg))
        .toList();
    _saveData();
    // 메시지 변경 후 즉시 새 메시지 표시
    if (allMotivationalMessages.isNotEmpty) {
      _changeMotivationalMessage();
    }
  }

  // 메시지 활성화/비활성화 상태 설정
  void setMessageEnabled(String message, bool enabled) {
    if (enabled) {
      disabledMotivationalMessages.remove(message);
    } else {
      disabledMotivationalMessages.add(message);
    }
    _saveData();
    // 메시지 변경 후 즉시 새 메시지 표시
    if (allMotivationalMessages.isNotEmpty) {
      _changeMotivationalMessage();
    }
  }

  // 메시지가 활성화되어 있는지 확인
  bool isMessageEnabled(String message) {
    return !disabledMotivationalMessages.contains(message);
  }

  void _updateElapsed() {
    if (quitDate != null) {
      elapsed.value = DateTime.now().difference(quitDate!);
      // 알림 업데이트 (표시 여부 확인)
      if (isQuittingStarted.value && isNotificationVisible.value) {
        _notificationService.updateQuittingTimer(elapsedFormatted);
      } else if (!isNotificationVisible.value) {
        _notificationService.cancelNotification();
      }
    } else {
      elapsed.value = Duration.zero;
      // 알림 제거
      _notificationService.cancelNotification();
    }
  }

  void refresh() {
    _updateElapsed();
  }

  // 알림 숨기기/보이기 토글
  void toggleNotification() {
    isNotificationVisible.value = !isNotificationVisible.value;
    if (isNotificationVisible.value &&
        isQuittingStarted.value &&
        quitDate != null) {
      _notificationService.updateQuittingTimer(elapsedFormatted);
    } else {
      _notificationService.cancelNotification();
    }
    _saveData();
  }

  void startQuitting() {
    quitDate = DateTime.now();
    isQuittingStarted.value = true;
    elapsed.value = Duration.zero;
    _updateElapsed();
    _saveData();
  }

  void reset() {
    quitDate = DateTime.now();
    elapsed.value = Duration.zero;
    isQuittingStarted.value = true;
    _updateElapsed();
    _saveData();
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
    if (!isQuittingStarted.value || quitDate == null) {
      return 0.0;
    }
    final targetSeconds = targetDuration.inSeconds;
    final progress = elapsed.value.inSeconds / targetSeconds;
    return (progress * 100).clamp(0, 100);
  }

  void setTargetPeriod(String period) {
    targetPeriod.value = period;
    _saveData();
  }

  // 한 개비당 225원으로 계산
  int get moneySaved {
    return cigarettesNotSmoked * 225;
  }

  // 숫자에 천 단위 콤마 추가
  String formatMoney(double amount) {
    final amountInt = amount.toInt();
    final amountStr = amountInt.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < amountStr.length; i++) {
      if (i > 0 && (amountStr.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(amountStr[i]);
    }

    return buffer.toString();
  }

  Duration get lifeRegained {
    // 담배 한 개비당 11분의 수명 단축
    final totalCigarettesNotSmoked =
        (elapsed.value.inMinutes / (24 * 60)) * cigarettesPerDay.value;
    return Duration(minutes: (totalCigarettesNotSmoked * 11).round());
  }

  // 설정한 하루 담배 개비 수와 경과 시간에 의거하여 피우지 않은 담배 개비 수 계산
  int get cigarettesNotSmoked {
    if (!isQuittingStarted.value || quitDate == null) {
      return 0;
    }
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
      isCigarettesPerDaySet.value = true;
      _saveData();
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
    return '₩ ${formatMoney(moneySaved.toDouble())}';
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

  List<FutureReward> get futureRewards {
    const pricePerCigarette = 225.0; // 한 개비당 225원
    const minutesPerCigarette = 11; // 한 개비당 11분의 수명 회복
    final dailyCigarettes = cigarettesPerDay.value.toDouble();

    return [
      FutureReward(
        period: '1주',
        money: (7 * dailyCigarettes * pricePerCigarette).toDouble(),
        life: Duration(
          minutes: (7 * dailyCigarettes * minutesPerCigarette).round(),
        ),
      ),
      FutureReward(
        period: '1개월',
        money: (30 * dailyCigarettes * pricePerCigarette).toDouble(),
        life: Duration(
          minutes: (30 * dailyCigarettes * minutesPerCigarette).round(),
        ),
      ),
      FutureReward(
        period: '1년',
        money: (365 * dailyCigarettes * pricePerCigarette).toDouble(),
        life: Duration(
          minutes: (365 * dailyCigarettes * minutesPerCigarette).round(),
        ),
      ),
      FutureReward(
        period: '5년',
        money: (5 * 365 * dailyCigarettes * pricePerCigarette).toDouble(),
        life: Duration(
          minutes: (5 * 365 * dailyCigarettes * minutesPerCigarette).round(),
        ),
      ),
      FutureReward(
        period: '10년',
        money: (10 * 365 * dailyCigarettes * pricePerCigarette).toDouble(),
        life: Duration(
          minutes: (10 * 365 * dailyCigarettes * minutesPerCigarette).round(),
        ),
      ),
      FutureReward(
        period: '20년',
        money: (20 * 365 * dailyCigarettes * pricePerCigarette).toDouble(),
        life: Duration(
          minutes: (20 * 365 * dailyCigarettes * minutesPerCigarette).round(),
        ),
      ),
    ];
  }

  String formatFutureLife(Duration duration) {
    final totalDays = duration.inDays;
    final totalHours = duration.inHours;
    final years = totalDays ~/ 365;
    final months = (totalDays % 365) ~/ 30;
    final days = (totalDays % 365) % 30;

    // 일 단위 이상이 있으면 일 단위 이상으로만 표시
    if (totalDays > 0) {
      if (years > 0) {
        if (months > 0) {
          // 달 이상이 있으면 일 표시하지 않음
          return '${years}년 ${months}달';
        }
        // 년만 있으면 일 표시하지 않음
        return '${years}년';
      } else if (months > 0) {
        // 달만 있으면 일 표시하지 않음
        return '${months}달';
      } else {
        // 일만 있으면 일 표시
        return '${days}일';
      }
    } else {
      // 일 단위가 안되면 시간으로 표시
      return '${totalHours}시간';
    }
  }
}
