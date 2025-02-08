# kakeibo

35日（5週間）を一周期とする家計簿アプリを作りたい！

メリットは以下！

- 無理なく出費を抑えることができる
- 年に2回ボーナス月がやってくる
- ボーナス月で旅行・豪華ディナーが楽しめる！

35日で1周期の**35カケイボ**を使って楽しく無理なく家計簿を付けよう！

# コミットログ規則

[Angular.js/DEVELOPERS.md](https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#type)のものを参考に以下のprefixを付けること．

| prefix  | explain                                                                                                |
|---------|--------------------------------------------------------------------------------------------------------|
| feat    | A new feature                                                                                          |
| fix     | A bug fix                                                                                              |
| docs    | Documentation only changes                                                                             |
| style   | Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc) |
| refactor | A code change that neither fixes a bug nor adds a feature                                              |
| perf    | A code change that improves performance                                                                |
| test    | Adding missing or correcting existing tests                                                            |
| chore   |  Changes to the build process or auxiliary tools and libraries such as documentation generation        |

# フォルダ構成

```shell

lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   │   ├── app_theme.dart       // テーマクラス（ThemeDataを管理）
│   │   └── theme_extension.dart // extensionでスタイルや色を管理
│   ├── utils/
│   │   ├── date_utils.dart      // 日付関連のユーティリティ（例）
│   │   └── format_utils.dart    // 文字列フォーマット関連（例）
│   └── constants/
│       └── app_colors.dart      // 色を定数で管理（オプション）
├── presentation/
│   ├── pages/
│   │   ├── input/
│   │   │   └── input_page.dart
│   │   ├── calendar/
│   │   │   └── calendar_page.dart
│   │   ├── report/
│   │   │   └── report_page.dart
│   │   └── assets/
│   │       └── assets_page.dart
│   └── widgets/
│       └── bottom_navigation.dart
├── application/
├── data/
└── domain/


```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
