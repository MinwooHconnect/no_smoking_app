#!/bin/bash

echo "========================================"
echo "Flutter Build Script (Android & iOS)"
echo "========================================"
echo ""

# 프로젝트 이름 (원하는 이름으로 변경 가능)
PROJECT_NAME="no_smoking_app"

# 현재 날짜 가져오기 (YYYYMMDD 형식)
DATE_STR=$(date +%Y%m%d)

# pubspec.yaml에서 버전 가져오기
VERSION_LINE=$(grep "^version:" pubspec.yaml | awk '{print $2}')
VERSION=$(echo $VERSION_LINE | cut -d'+' -f1)

echo "Project: $PROJECT_NAME"
echo "Date: $DATE_STR"
echo "Version: $VERSION"
echo ""

# Flutter 클린 및 의존성 설치
echo "[1/6] Cleaning..."
flutter clean
echo ""

echo "[2/6] Getting dependencies..."
flutter pub get
echo ""

# Android AAB 빌드
echo "[3/6] Building Android AAB..."
flutter build appbundle --release

if [ $? -ne 0 ]; then
    echo ""
    echo "========================================"
    echo "Android Build FAILED!"
    echo "========================================"
    exit 1
fi
echo ""

# iOS IPA 빌드
echo "[4/6] Building iOS IPA..."
flutter build ipa --release

if [ $? -ne 0 ]; then
    echo ""
    echo "========================================"
    echo "iOS Build FAILED!"
    echo "========================================"
    exit 1
fi
echo ""

# release 폴더 생성
DEST_DIR="release"
mkdir -p "$DEST_DIR"

# Android AAB 파일 복사
echo "[5/6] Copying Android AAB..."
AAB_OUTPUT_NAME="${PROJECT_NAME}_${DATE_STR}_${VERSION}.aab"
AAB_SOURCE="build/app/outputs/bundle/release/app-release.aab"
AAB_DEST="$DEST_DIR/$AAB_OUTPUT_NAME"

if [ -f "$AAB_SOURCE" ]; then
    cp "$AAB_SOURCE" "$AAB_DEST"
    echo "✓ Android AAB copied: $AAB_DEST"
else
    echo "✗ Android AAB file not found!"
fi
echo ""

# iOS IPA 파일 복사
echo "[6/6] Copying iOS IPA..."
IPA_OUTPUT_NAME="${PROJECT_NAME}_${DATE_STR}_${VERSION}.ipa"
IPA_SOURCE="build/ios/ipa/*.ipa"
IPA_DEST="$DEST_DIR/$IPA_OUTPUT_NAME"

# ipa 파일 찾기 (와일드카드 사용)
IPA_FILE=$(ls build/ios/ipa/*.ipa 2>/dev/null | head -n 1)

if [ -f "$IPA_FILE" ]; then
    cp "$IPA_FILE" "$IPA_DEST"
    echo "✓ iOS IPA copied: $IPA_DEST"
else
    echo "✗ iOS IPA file not found!"
    echo "  Make sure you have configured signing in Xcode"
fi
echo ""

echo "========================================"
echo "Build SUCCESS!"
echo "========================================"
echo "Output directory: $DEST_DIR"
echo ""
echo "Files created:"
[ -f "$AAB_DEST" ] && echo "  - $AAB_OUTPUT_NAME (Android)"
[ -f "$IPA_DEST" ] && echo "  - $IPA_OUTPUT_NAME (iOS)"
echo ""

# Finder로 폴더 열기
open "$DEST_DIR"

echo "Press any key to continue..."
read -n 1