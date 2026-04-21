import 'package:flutter/material.dart';

import '../features/game/presentation/pages/game_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/result/presentation/pages/result_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';

final class AppRouter {
  static const String homeRoute = '/';
  static const String gameRoute = '/game';
  static const String settingsRoute = '/settings';
  static const String resultRoute = '/result';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case gameRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const GamePage(),
          settings: settings,
        );
      case settingsRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );
      case resultRoute:
        return MaterialPageRoute<void>(
          builder: (_) => const ResultPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
    }
  }
}
