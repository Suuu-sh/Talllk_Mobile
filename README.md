# Talllk Mobile

Flutterで作成されたTalllkのモバイルアプリ版

## セットアップ

### 必要なもの
- Flutter SDK (3.0.0以上)
- Android Studio / Xcode
- バックエンドAPI（http://localhost:8080）

### インストール

```bash
cd mobile
flutter pub get
```

### 実行

```bash
# Android
flutter run

# iOS
flutter run -d ios

# 特定のデバイス
flutter devices
flutter run -d <device-id>
```

### ビルド

```bash
# Android APK
flutter build apk

# iOS
flutter build ios
```

## 機能

- ✅ ユーザー認証（ログイン・登録）
- ✅ トピック管理（作成・表示・削除）
- ✅ 質問と回答の管理（追加・編集・削除）
- ✅ ダークモード対応
- ✅ 展開可能な質問カード
- ✅ プルして更新
- ✅ レスポンシブデザイン

## API設定

`lib/services/api_service.dart`でAPIのベースURLを変更できます：

```dart
static const String baseUrl = 'http://localhost:8080/api';
```

実機でテストする場合は、ローカルIPアドレスに変更してください：

```dart
static const String baseUrl = 'http://192.168.1.XXX:8080/api';
```
