import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dottunes/services/audio_service.dart';
import 'package:dottunes/services/data_manager.dart';
import 'package:dottunes/services/logger_service.dart';
import 'package:dottunes/services/router_service.dart';
import 'package:dottunes/services/settings_manager.dart';
import 'package:dottunes/splash/onboarding_screen.dart';
import 'package:dottunes/style/app_themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

late dottunesAudioHandler audioHandler;

final logger = Logger();

bool isFdroidBuild = false;
bool isUpdateChecked = false;

final appLanguages = <String, String>{
  'English': 'en',
  'Arabic': 'ar',
  'French': 'fr',
  'Galician': 'gl',
  'Georgian': 'ka',
  'German': 'de',
  'Greek': 'el',
  'Indonesian': 'id',
  'Italian': 'it',
  'Japanese': 'ja',
  'Korean': 'ko',
  'Russian': 'ru',
  'Polish': 'pl',
  'Portuguese': 'pt',
  'Spanish': 'es',
  'Turkish': 'tr',
  'Ukrainian': 'uk',
};

final appSupportedLocales = appLanguages.values
    .map((languageCode) => Locale.fromSubtags(languageCode: languageCode))
    .toList();

class dottunes extends StatefulWidget {
  const dottunes({super.key});

  static Future<void> updateAppState(
      BuildContext context, {
        ThemeMode? newThemeMode,
        Locale? newLocale,
        Color? newAccentColor,
        bool? useSystemColor,
      }) async {
    context.findAncestorStateOfType<_dottunesState>()!.changeSettings(
      newThemeMode: newThemeMode,
      newLocale: newLocale,
      newAccentColor: newAccentColor,
      systemColorStatus: useSystemColor,
    );
  }

  @override
  _dottunesState createState() => _dottunesState();
}

class _dottunesState extends State<dottunes> {
  void changeSettings({
    ThemeMode? newThemeMode,
    Locale? newLocale,
    Color? newAccentColor,
    bool? systemColorStatus,
  }) {
    setState(() {
      if (newThemeMode != null) {
        themeMode = newThemeMode;
        brightness = getBrightnessFromThemeMode(newThemeMode);
      }
      if (newLocale != null) {
        languageSetting = newLocale;
      }
      if (newAccentColor != null) {
        if (systemColorStatus != null &&
            useSystemColor.value != systemColorStatus) {
          useSystemColor.value = systemColorStatus;
          addOrUpdateData(
            'settings',
            'useSystemColor',
            systemColorStatus,
          );
        }
        primaryColorSetting = newAccentColor;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    final trickyFixForTransparency = Colors.black.withOpacity(0.002);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: trickyFixForTransparency,
          systemNavigationBarColor: trickyFixForTransparency,
        ),
      );
    });

    try {
      LicenseRegistry.addLicense(() async* {
        final license =
        await rootBundle.loadString('assets/licenses/paytone.txt');
        yield LicenseEntryWithLineBreaks(['paytoneOne'], license);
      });
    } catch (e, stackTrace) {
      logger.log('License Registration Error', e, stackTrace);
    }
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        final colorScheme =
        getAppColorScheme(lightColorScheme, darkColorScheme);

        return MaterialApp.router(
          themeMode: themeMode,
          darkTheme: getAppTheme(colorScheme),
          theme: getAppTheme(colorScheme),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: appSupportedLocales,
          locale: languageSetting,
          routerConfig: NavigationManager.router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure proper initialization before checking onboarding completion
  await initialisation();

  // Check if onboarding has been completed
  bool onboardingCompleted = await isOnboardingCompleted();

  // Run the app
  runApp(
    MaterialApp(
      theme: ThemeData.light(),
      locale: Locale('en'), // default language
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: appSupportedLocales,
      debugShowCheckedModeBanner: false,
      home: onboardingCompleted ? const dottunes() : OnboardingScreen(),
    ),
  );
}

// Function to check if onboarding was completed
Future<bool> isOnboardingCompleted() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboardingCompleted') ?? false;
}

// Function to set onboarding status as completed
Future<void> setOnboardingStatus(bool completed) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('onboardingCompleted', completed);
}

// Function for initializing necessary services and boxes
Future<void> initialisation() async {
  try {
    await Hive.initFlutter();

    final boxNames = ['settings', 'user', 'userNoBackup', 'cache'];

    for (final boxName in boxNames) {
      await Hive.openBox(boxName);
    }

    audioHandler = await AudioService.init(
      builder: dottunesAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.dotstudios.dottunes',
        androidNotificationChannelName: 'dottunes',
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidShowNotificationBadge: true,
      ),
    );

    NavigationManager.instance;

    // Init clients
    if (clientsSetting.value.isNotEmpty) {
      final chosenClients = <YoutubeApiClient>[];
      for (final client in clientsSetting.value) {
        final _client = clients[client];
        if (_client != null) {
          chosenClients.add(_client);
        }
      }
      userChosenClients = chosenClients;
    }
  } catch (e, stackTrace) {
    logger.log('Initialization Error', e, stackTrace);
  }
}
