@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Flutter AAB Build Script
echo ========================================
echo.

REM 프로젝트 이름 (원하는 이름으로 변경 가능)
set PROJECT_NAME=no_smoking_app

REM 현재 날짜 가져오기 (YYYYMMDD 형식)
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set DATE_STR=%dt:~0,8%

REM pubspec.yaml에서 버전 가져오기
for /f "tokens=2 delims=: " %%a in ('findstr /r "^version:" pubspec.yaml') do set VERSION_LINE=%%a
REM + 기호 제거 (1.0.0+1 -> 1.0.0)
for /f "tokens=1 delims=+" %%a in ("%VERSION_LINE%") do set VERSION=%%a

echo Project: %PROJECT_NAME%
echo Date: %DATE_STR%
echo Version: %VERSION%
echo.

REM Flutter 클린 및 의존성 설치
echo [1/4] Cleaning...
call flutter clean
echo.

echo [2/4] Getting dependencies...
call flutter pub get
echo.

REM AAB 빌드
echo [3/4] Building AAB...
call flutter build appbundle --release
echo.

REM 빌드 성공 여부 확인
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================
    echo Build FAILED!
    echo ========================================
    pause
    exit /b 1
)

REM 파일명 생성 및 복사
set OUTPUT_NAME=%PROJECT_NAME%_%DATE_STR%_%VERSION%.aab
set SOURCE_FILE=build\app\outputs\bundle\release\app-release.aab
set DEST_DIR=release
set DEST_FILE=%DEST_DIR%\%OUTPUT_NAME%

echo [4/4] Copying AAB file...

REM release 폴더가 없으면 생성
if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"

REM 파일 복사
copy "%SOURCE_FILE%" "%DEST_FILE%"

echo.
echo ========================================
echo Build SUCCESS!
echo ========================================
echo Output: %DEST_FILE%
echo.

REM 파일 탐색기로 폴더 열기
explorer "%DEST_DIR%"

pause