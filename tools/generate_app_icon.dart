import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

/// 스플래시 화면의 디자인을 기반으로 앱 아이콘 이미지를 생성하는 스크립트
/// 사용법: flutter run tools/generate_app_icon.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // assets/icon 디렉토리 생성
  final iconDir = Directory('assets/icon');
  if (!await iconDir.exists()) {
    await iconDir.create(recursive: true);
  }

  // 메인 아이콘 생성 (1024x1024)
  final mainIcon = await _generateAppIcon(1024);
  final mainFile = File('assets/icon/app_icon.png');
  await mainFile.writeAsBytes(mainIcon);
  print('생성됨: ${mainFile.path}');

  // Adaptive icon foreground 생성 (1024x1024, 투명 배경)
  final foregroundIcon = await _generateAppIconForeground(1024);
  final foregroundFile = File('assets/icon/app_icon_foreground.png');
  await foregroundFile.writeAsBytes(foregroundIcon);
  print('생성됨: ${foregroundFile.path}');
  
  print('\n모든 아이콘이 생성되었습니다!');
  print('이제 다음 명령어를 실행하세요:');
  print('flutter pub run flutter_launcher_icons');
}

Future<Uint8List> _generateAppIcon(int size) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final sizeF = size.toDouble();
  
  // 배경색 (흰색)
  final backgroundPaint = Paint()..color = Colors.white;
  
  // 둥근 사각형 그리기 (24px radius를 비율로 조정)
  final radius = sizeF * 0.2; // 24/120 비율
  final rect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, sizeF, sizeF),
    Radius.circular(radius),
  );
  canvas.drawRRect(rect, backgroundPaint);
  
  // 그림자 효과 (간단한 그라데이션)
  final shadowPaint = Paint()
    ..color = Colors.black.withOpacity(0.15)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(sizeF * 0.05, sizeF * 0.05, sizeF * 0.9, sizeF * 0.9),
      Radius.circular(radius),
    ),
    shadowPaint,
  );
  
  // 아이콘 그리기
  final iconSize = sizeF * 0.67; // 80/120 비율
  final iconPaint = Paint()..color = const Color(0xFFBF5656); // AppColor.primary
  
  // smoking_rooms 아이콘 그리기
  _drawSmokingIcon(canvas, sizeF / 2, sizeF / 2, iconSize, iconPaint);
  
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<Uint8List> _generateAppIconForeground(int size) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final sizeF = size.toDouble();
  
  // 투명 배경 (그리지 않음)
  
  // 아이콘 그리기
  final iconSize = sizeF * 0.67; // 80/120 비율
  final iconPaint = Paint()..color = const Color(0xFFBF5656); // AppColor.primary
  
  // smoking_rooms 아이콘 그리기
  _drawSmokingIcon(canvas, sizeF / 2, sizeF / 2, iconSize, iconPaint);
  
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

void _drawSmokingIcon(Canvas canvas, double centerX, double centerY, double size, Paint paint) {
  // 간단한 담배 아이콘 그리기
  // 원형 (담배 끝)
  canvas.drawCircle(
    Offset(centerX - size * 0.15, centerY),
    size * 0.1,
    paint,
  );
  
  // 직선 (담배 몸통)
  final strokePaint = Paint()
    ..color = paint.color
    ..style = PaintingStyle.stroke
    ..strokeWidth = size * 0.15;
  
  canvas.drawLine(
    Offset(centerX - size * 0.05, centerY),
    Offset(centerX + size * 0.3, centerY),
    strokePaint,
  );
  
  // 연기 효과 (작은 원들)
  final smokePaint = Paint()
    ..color = paint.color.withOpacity(0.3)
    ..style = PaintingStyle.fill;
  
  canvas.drawCircle(
    Offset(centerX + size * 0.35, centerY - size * 0.1),
    size * 0.08,
    smokePaint,
  );
  canvas.drawCircle(
    Offset(centerX + size * 0.4, centerY - size * 0.15),
    size * 0.06,
    smokePaint,
  );
  canvas.drawCircle(
    Offset(centerX + size * 0.45, centerY - size * 0.2),
    size * 0.05,
    smokePaint,
  );
}

