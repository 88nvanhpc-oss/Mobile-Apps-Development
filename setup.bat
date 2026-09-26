@echo off
setlocal
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter khong co trong PATH.
  exit /b 1
)
if not exist android (
  if exist _platform_seed rmdir /s /q _platform_seed
  flutter create _platform_seed --project-name expense_tracker --platforms=android,ios
  xcopy /e /i /q /y _platform_seed\android android >nul
  xcopy /e /i /q /y _platform_seed\ios ios >nul
  rmdir /s /q _platform_seed
)
copy /y platform_templates\android\AndroidManifest.xml android\app\src\main\AndroidManifest.xml >nul
if exist android\app\build.gradle.kts copy /y platform_templates\android\build.gradle.kts android\app\build.gradle.kts >nul
if exist android\app\build.gradle copy /y platform_templates\android\build.gradle android\app\build.gradle >nul
flutter pub get
flutter analyze
endlocal
