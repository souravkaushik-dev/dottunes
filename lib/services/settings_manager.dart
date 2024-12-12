/*dottunes envor studios*/

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dottunes/main.dart';

// Preferences

final playNextSongAutomatically = ValueNotifier<bool>(
  Hive.box('settings').get('playNextSongAutomatically', defaultValue: false),
);

final useSystemColor = ValueNotifier<bool>(
  Hive.box('settings').get('useSystemColor', defaultValue: true),
);

final usePureBlackColor = ValueNotifier<bool>(
  Hive.box('settings').get('usePureBlackColor', defaultValue: false),
);

final useSquigglySlider = ValueNotifier<bool>(
  Hive.box('settings').get('useSquigglySlider', defaultValue: false),
);

final offlineMode = ValueNotifier<bool>(
  Hive.box('settings').get('offlineMode', defaultValue: false),
);

final predictiveBack = ValueNotifier<bool>(
  Hive.box('settings').get('predictiveBack', defaultValue: false),
);

final sponsorBlockSupport = ValueNotifier<bool>(
  Hive.box('settings').get('sponsorBlockSupport', defaultValue: false),
);

final defaultRecommendations = ValueNotifier<bool>(
  Hive.box('settings').get('defaultRecommendations', defaultValue: false),
);

final audioQualitySetting = ValueNotifier<String>(
  Hive.box('settings').get('audioQuality', defaultValue: 'high'),
);

Locale languageSetting = Locale(
  appLanguages[Hive.box('settings').get('language', defaultValue: 'English')
          as String] ??
      'en',
);

final themeModeSetting =
    Hive.box('settings').get('themeMode', defaultValue: 'dark') as String;

Color primaryColorSetting =
    Color(Hive.box('settings').get('accentColor', defaultValue: 0xff91cef4));

// Non-Storage Notifiers

final shuffleNotifier = ValueNotifier<bool>(false);
final repeatNotifier = ValueNotifier<bool>(false);
