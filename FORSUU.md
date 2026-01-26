# FORSUU.md - Talllk Mobile

## Project Overview

Talllk MobileはFlutterで構築されたクロスプラットフォームモバイルアプリです。iOS/Androidの両方で動作し、会話準備のためのシチュエーション・トピック・質問を管理できます。

---

## Tech Stack

| カテゴリ | 技術 | バージョン |
|---------|------|-----------|
| Framework | Flutter | ≥3.0.0 |
| Language | Dart | ≥3.0.0 |
| State Management | Provider | ^6.1.1 |
| HTTP Client | http | ^1.1.0 |
| Local Storage | SharedPreferences | ^2.2.2 |
| Environment | flutter_dotenv | ^5.1.0 |
| UI | Material Design 3 | - |

---

## Directory Structure

```
lib/
├── main.dart                    # アプリエントリーポイント
├── providers/
│   ├── auth_provider.dart       # 認証状態管理
│   └── theme_provider.dart      # テーマ管理
├── screens/
│   ├── splash_screen.dart       # スプラッシュ
│   ├── login_screen.dart        # ログイン・登録
│   ├── main_screen.dart         # メインページビュー
│   ├── dashboard_screen.dart    # シチュエーション一覧
│   ├── profile_screen.dart      # プロフィール・設定
│   ├── situation_detail_screen.dart  # シチュエーション詳細
│   ├── topic_detail_screen.dart      # トピック詳細
│   ├── discover_screen.dart          # 公開コンテンツ発見
│   ├── discover_situation_detail_screen.dart  # 公開詳細
│   ├── shuffle_screen.dart      # ランダム質問
│   └── search_screen.dart       # 検索
├── services/
│   └── api_service.dart         # API通信
├── widgets/
│   ├── app_bottom_nav.dart      # ボトムナビゲーション
│   └── list_card.dart           # リストカード
└── theme/
    └── app_colors.dart          # カラー定義
```

---

## State Management

### AuthProvider
```dart
class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    _isAuthenticated = token != null;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _isAuthenticated = false;
    notifyListeners();
  }
}
```

### ThemeProvider
```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    // SharedPreferencesに保存
    notifyListeners();
  }
}
```

---

## Screens

### SplashScreen
- トークン存在確認
- ログイン状態に応じて遷移先を決定

### LoginScreen
- ログイン/新規登録の切り替え
- フォームバリデーション
- トークン保存後、ダッシュボードへ

### DashboardScreen（メイン画面）
- シチュエーション一覧（カード形式）
- 新規作成モーダル
- お気に入りタブ
- 最近閲覧した項目

### SituationDetailScreen
- トピック一覧
- トピック作成・編集・削除
- スワイプアクション（flutter_slidable）

### TopicDetailScreen
- 質問一覧（アコーディオン形式）
- 質問の作成・編集・削除
- 回答の表示/非表示

### DiscoverScreen
- 公開シチュエーション一覧
- 検索・フィルタリング
- 保存機能

### ShuffleScreen
- ランダムに質問を表示
- 回答確認モード

### SearchScreen
- キーワード検索
- 結果表示

### ProfileScreen
- ユーザー情報表示
- テーマ切り替え
- ログアウト

---

## API Service

### Configuration
```dart
class ApiService {
  static String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8080/api';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
```

### Endpoints

#### Authentication
```dart
static Future<Map<String, dynamic>> login(String email, String password)
static Future<Map<String, dynamic>> register(String name, String email, String password)
```

#### Situations
```dart
static Future<List<dynamic>> getSituations()
static Future<Map<String, dynamic>> getSituation(int id)
static Future<Map<String, dynamic>> createSituation(String title, String description)
static Future<void> updateSituation(int id, String title, String description)
static Future<void> deleteSituation(int id)
static Future<List<dynamic>> getFavoriteSituations()
static Future<void> addFavorite(int id)
static Future<void> removeFavorite(int id)
static Future<void> publishSituation(int id, bool isPublic)
```

#### Topics
```dart
static Future<List<dynamic>> getTopics(int situationId)
static Future<Map<String, dynamic>> getTopic(int situationId, int topicId)
static Future<Map<String, dynamic>> createTopic(int situationId, String title, String description, int? parentId)
static Future<void> updateTopic(int situationId, int topicId, String title, String description)
static Future<void> deleteTopic(int situationId, int topicId)
```

#### Questions
```dart
static Future<Map<String, dynamic>> createQuestion(int situationId, int topicId, String question, String answer)
static Future<void> updateQuestion(int situationId, int topicId, int questionId, String question, String answer)
static Future<void> deleteQuestion(int situationId, int topicId, int questionId)
```

#### Discover
```dart
static Future<List<dynamic>> getPublicSituations()
static Future<Map<String, dynamic>> getPublicSituation(int id)
static Future<void> saveSituation(int id)
static Future<void> saveTopic(int topicId, int targetSituationId)
static Future<void> saveQuestion(int questionId, int targetTopicId)
```

---

## Theme System

### Colors (app_colors.dart)
```dart
class AppColors {
  // Light Mode
  static const lightScaffold = Color(0xFFFAFAFA);
  static const lightText = Color(0xFF111827);
  static const lightSubText = Color(0xFF6B7280);

  // Dark Mode
  static const darkScaffold = Color(0xFF0A0A0A);
  static const darkText = Color(0xFFF9FAFB);
  static const darkSubText = Color(0xFF9CA3AF);

  // Brand
  static const primary = Colors.orange;
  static const primaryLight = Color(0xFFFB8C00);  // orange600
  static const primaryDark = Color(0xFFFF9800);   // orange500
}
```

### Font
```dart
GoogleFonts.inter(fontWeight: FontWeight.w300)
```

---

## Local Storage

### SharedPreferences Keys
```dart
'token'                  // JWTトークン
'user_name'              // ユーザー名
'isDarkMode'             // テーマ設定
'recent_situation_ids'   // 最近閲覧したID
```

---

## Navigation Flow

```
SplashScreen
    │
    ├─ token exists → MainScreen
    │                    ├─ DashboardScreen
    │                    ├─ ShuffleScreen
    │                    ├─ SearchScreen
    │                    └─ DiscoverScreen
    │
    └─ no token → LoginScreen

DashboardScreen
    └─ tap situation → SituationDetailScreen
                           └─ tap topic → TopicDetailScreen
```

---

## Key Features

### 1. 階層的データ管理
- Situation > Topic > Question
- 親子関係のトピック・質問

### 2. お気に入り機能
- シチュエーションをお気に入り登録
- 専用タブで一覧表示

### 3. 公開・発見機能
- シチュエーションを公開設定
- 他ユーザーの公開コンテンツを発見
- コンテンツを自分用に複製

### 4. シャッフル機能
- ランダムに質問を表示
- 練習モードとして活用

### 5. 検索機能
- キーワードで検索
- シチュエーション・トピック横断

### 6. ダークモード
- システム設定連動
- 手動切り替え可能

---

## Environment Variables

`.env` file:
```
API_BASE_URL=http://127.0.0.1:8080/api
```

---

## Build & Run

### Development
```bash
flutter run
```

### iOS Build
```bash
flutter build ios
```

### Android Build
```bash
flutter build apk
```

---

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  flutter_secure_storage: ^9.0.0
  flutter_dotenv: ^5.1.0
  flutter_slidable: ^3.1.0
  google_fonts: ^6.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

---

## UI Components

### AppBottomNav
4タブのボトムナビゲーション:
- ホーム（Dashboard）
- シャッフル
- 検索
- 発見（Discover）

### ListCard
再利用可能なカードコンポーネント:
- タイトル
- 説明
- アクションボタン

---

## Platform Support

| Platform | Status |
|----------|--------|
| iOS | ✅ |
| Android | ✅ |
| Web | ⚠️ (未テスト) |
| macOS | ⚠️ (未テスト) |
| Windows | ⚠️ (未テスト) |
