cd ../mobile-user

# Get dependencies
flutter pub get

# Generate necessary files
flutter gen-l10n

# Build Android APK
flutter build apk --release --split-per-abi

# Build Android App Bundle (Play Store)
flutter build appbundle --release

# Build iOS (requires macOS)
flutter build ios --release