//dotstudios

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hugeicons/hugeicons.dart';


import 'package:flutter/material.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/screens/search_page.dart';
import 'package:dottunes/services/data_manager.dart';
import 'package:dottunes/services/router_service.dart';
import 'package:dottunes/services/settings_manager.dart';
import 'package:dottunes/style/app_colors.dart';
import 'package:dottunes/style/app_themes.dart';
import 'package:dottunes/utilities/common_variables.dart';
import 'package:dottunes/utilities/flutter_bottom_sheet.dart';
import 'package:dottunes/utilities/flutter_toast.dart';
import 'package:dottunes/utilities/url_launcher.dart';
import 'package:dottunes/utilities/utils.dart';
import 'package:dottunes/widgets/bottom_sheet_bar.dart';
import 'package:dottunes/widgets/confirmation_dialog.dart';
import 'package:dottunes/widgets/custom_bar.dart';
import 'package:dottunes/widgets/section_title.dart';
import 'package:hugeicons/hugeicons.dart';


import 'package:hugeicons/hugeicons.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final activatedColor = Theme.of(context).colorScheme.secondaryContainer;
    final inactivatedColor = Theme.of(context).colorScheme.surfaceContainerHigh;

    return Scaffold(
      body: CustomScrollView(
          slivers: [
      // SliverAppBar with the same style as in dottunes

            SliverAppBar(
              expandedHeight: 160.0,
              floating: false,
              pinned: true,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  var top = constraints.biggest.height;
                  bool isCollapsed = top <= kToolbarHeight + MediaQuery.of(context).padding.top;
                  double roundedCorner = isCollapsed ? 20.0 : 30.0;

                  return FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: EdgeInsets.only(
                      top: isCollapsed ? 0.0 : 80.0, // Adjust padding when collapsed
                      left: 16.0,
                    ),
                    title: Align(
                      alignment: isCollapsed ? Alignment.centerLeft : Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown, // Ensures the text scales down to fit
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: isCollapsed ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                          children: [
                            Text(
                              'customization',
                              style: TextStyle(
                                fontFamily: 'Nothing',
                                fontSize: isCollapsed ? 24.0 : 30.0, // Adjust font size for collapsed state
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              'Your Experience with Easy Controls.',
                              style: TextStyle(
                                fontFamily: 'Nothing',
                                fontSize: isCollapsed ? 10.0 : 14.0,
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(

                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(roundedCorner),
                        ),
                      ),
                    ),
                  );
                },
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
            ),
    SliverList(
    delegate: SliverChildListDelegate(
    [
            // CATEGORY: PREFERENCES
            SectionTitle(
              context.l10n!.preferences,
              primaryColor,
            ),
            CustomBar(
              context.l10n!.accentColor,
              HugeIcons.strokeRoundedPaintBoard,
              borderRadius: commonCustomBarRadiusFirst,
              onTap: () => showCustomBottomSheet(
                context,
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                  ),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: availableColors.length,
                  itemBuilder: (context, index) {
                    final color = availableColors[index];
                    final isSelected = color == primaryColorSetting;

                    return GestureDetector(
                      onTap: () {
                        //TODO: migrate this
                        addOrUpdateData(
                          'settings',
                          'accentColor',
                          // ignore: deprecated_member_use
                          color.value,
                        );
                        dottunes.updateAppState(
                          context,
                          newAccentColor: color,
                          useSystemColor: false,
                        );
                        showToast(
                          context,
                          context.l10n!.accentChangeMsg,
                        );
                        Navigator.pop(context);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 60,  // Set the width of the square
                            height: 40, // Set the height of the square
                            decoration: BoxDecoration(
                              color: themeMode == ThemeMode.light
                                  ? color.withAlpha(150)
                                  : color,
                              borderRadius: BorderRadius.circular(16),  // Adjust the radius for rounded corners
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            CustomBar(
              context.l10n!.themeMode,
              HugeIcons.strokeRoundedSolarSystem,
              onTap: () {
                final availableModes = [
                  ThemeMode.system,
                  ThemeMode.light,
                  ThemeMode.dark,
                ];
                showCustomBottomSheet(
                  context,
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: commonListViewBottmomPadding,
                    itemCount: availableModes.length,
                    itemBuilder: (context, index) {
                      final mode = availableModes[index];

                      final borderRadius = getItemBorderRadius(
                        index,
                        availableModes.length,
                      );

                      return BottomSheetBar(
                        mode.name,
                        () {
                          addOrUpdateData(
                            'settings',
                            'themeMode',
                            mode.name,
                          );
                          dottunes.updateAppState(
                            context,
                            newThemeMode: mode,
                          );

                          Navigator.pop(context);
                        },
                        themeMode == mode ? activatedColor : inactivatedColor,
                        borderRadius: borderRadius,
                      );
                    },
                  ),
                );
              },
            ),

      CustomBar(
        context.l10n!.doters,
        HugeIcons.strokeRoundedDashedLine02,
        onTap: () {
          final availableClients = clients.keys.toList();
          showCustomBottomSheet(
            context,
            StatefulBuilder(
              builder: (context, setState) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: commonListViewBottmomPadding,
                  itemCount: availableClients.length,
                  itemBuilder: (context, index) {
                    final client = availableClients[index];
                    final _clientInModel = clients[client];
                    final isSelected =
                    userChosenClients.contains(_clientInModel);

                    final borderRadius = getItemBorderRadius(
                      index,
                      availableClients.length,
                    );

                    return BottomSheetBar(
                      client,
                          () {
                        setState(() {
                          if (isSelected) {
                            clientsSetting.value.remove(client);
                            userChosenClients.remove(_clientInModel);
                          } else {
                            if (_clientInModel != null) {
                              clientsSetting.value.add(client);
                              userChosenClients.add(_clientInModel);
                            }
                          }
                        });
                        addOrUpdateData(
                          'settings',
                          'clients',
                          clientsSetting.value,
                        );
                      },
                      isSelected ? activatedColor : inactivatedColor,
                      borderRadius: borderRadius,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    /*  CustomBar(
              context.l10n!.language,
              HugeIcons.strokeRoundedTranslate,
              onTap: () {
                final availableLanguages = appLanguages.keys.toList();
                final activeLanguageCode =
                    Localizations.localeOf(context).languageCode;
                showCustomBottomSheet(
                  context,
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: commonListViewBottmomPadding,
                    itemCount: availableLanguages.length,
                    itemBuilder: (context, index) {
                      final language = availableLanguages[index];
                      final languageCode = appLanguages[language] ?? 'en';

                      final borderRadius = getItemBorderRadius(
                        index,
                        availableLanguages.length,
                      );

                      return BottomSheetBar(
                        language,
                        () {
                          addOrUpdateData(
                            'settings',
                            'language',
                            language,
                          );
                          dottunes.updateAppState(
                            context,
                            newLocale: Locale(
                              languageCode,
                            ),
                          );
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) {
                              showToast(
                                context,
                                context.l10n!.languageMsg,
                              );
                              Navigator.pop(context);
                            },
                          );
                        },
                        activeLanguageCode == languageCode
                            ? activatedColor
                            : inactivatedColor,
                        borderRadius: borderRadius,
                      );
                    },
                  ),
                );
              },
            ), */
            CustomBar(
              context.l10n!.audioQuality,
              HugeIcons.strokeRoundedMusicNoteSquare02,
              onTap: () {
                final availableQualities = ['Low', 'Medium', 'High'];

                showCustomBottomSheet(
                  context,
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: commonListViewBottmomPadding,
                    itemCount: availableQualities.length,
                    itemBuilder: (context, index) {
                      final quality = availableQualities[index];
                      final isCurrentQuality =
                          audioQualitySetting.value == quality;

                      final borderRadius = getItemBorderRadius(
                        index,
                        availableQualities.length,
                      );

                      return BottomSheetBar(
                        quality,
                        () {
                          addOrUpdateData(
                            'settings',
                            'audioQuality',
                            quality,
                          );
                          audioQualitySetting.value = quality;

                          showToast(
                            context,
                            context.l10n!.audioQualityMsg,
                          );
                          Navigator.pop(context);
                        },
                        isCurrentQuality ? activatedColor : inactivatedColor,
                        borderRadius: borderRadius,
                      );
                    },
                  ),
                );
              },
            ),
            CustomBar(
              context.l10n!.dynamicColor,
              HugeIcons.strokeRoundedToggleOff,
              trailing: Switch(
                value: useSystemColor.value,
                onChanged: (value) {
                  addOrUpdateData(
                    'settings',
                    'useSystemColor',
                    value,
                  );
                  useSystemColor.value = value;
                  dottunes.updateAppState(
                    context,
                    newAccentColor: primaryColorSetting,
                    useSystemColor: value,
                  );
                  showToast(
                    context,
                    context.l10n!.settingChangedMsg,
                  );
                },
              ),
            ),
            //if (themeMode == ThemeMode.Dark)
             /* CustomBar(
                context.l10n!.pureBlackTheme,
                FluentIcons.color_background_24_filled,
                trailing: Switch(
                  value: usePureBlackColor.value,
                  onChanged: (value) {
                    addOrUpdateData(
                      'settings',
                      'usePureBlackColor',
                      value,
                    );
                    usePureBlackColor.value = value;
                    dottunes.updateAppState(context);
                    showToast(
                      context,
                      context.l10n!.settingChangedMsg,
                    );
                  },
                ),
              ),*/

        /*    ValueListenableBuilder<bool>(
              valueListenable: predictiveBack,
              builder: (_, value, __) {
                return CustomBar(
                  context.l10n!.predictiveBack,
                  FluentIcons.position_backward_24_filled,
                  trailing: Switch(
                    value: predictiveBack.value,
                    onChanged: (value) {
                      addOrUpdateData(
                        'settings',
                        'predictiveBack',
                        value,
                      );
                      predictiveBack.value = value;
                      transitionsBuilder = value
                          ? const PredictiveBackPageTransitionsBuilder()
                          : const CupertinoPageTransitionsBuilder();
                      dottunes.updateAppState(context);
                      showToast(
                        context,
                        context.l10n!.settingChangedMsg,
                      );
                    },
                  ),
                );
              },
            ),*/
           /* ValueListenableBuilder<bool>(
              valueListenable: useSquigglySlider,
              builder: (_, value, __) {
                return CustomBar(
                  context.l10n!.useSquigglySlider,
                  FluentIcons.options_24_filled,
                  trailing: Switch(
                    value: useSquigglySlider.value,
                    onChanged: (value) {
                      addOrUpdateData(
                        'settings',
                        'useSquigglySlider',
                        value,
                      );
                      useSquigglySlider.value = value;
                      showToast(
                        context,
                        context.l10n!.settingChangedMsg,
                      );
                    },
                  ),
                );
              },
            ),*/
            ValueListenableBuilder<bool>(
              valueListenable: offlineMode,
              builder: (_, value, __) {
                return CustomBar(
                  context.l10n!.offlineMode,
                  HugeIcons.strokeRoundedWifiDisconnected04,
                  trailing: Switch(
                    value: value,
                    onChanged: (value) {
                      addOrUpdateData(
                        'settings',
                        'offlineMode',
                        value,
                      );
                      offlineMode.value = value;
                      showToast(
                        context,
                        context.l10n!.restartAppMsg,
                      );
                    },
                  ),
                );
              },
            ),
            if (!offlineMode.value)
              Column(
                children: [
                /*  ValueListenableBuilder<bool>(
                    valueListenable: sponsorBlockSupport,
                    builder: (_, value, __) {
                      return CustomBar(
                        'SponsorBlock',
                        FluentIcons.presence_blocked_24_regular,
                        trailing: Switch(
                          value: value,
                          onChanged: (value) {
                            addOrUpdateData(
                              'settings',
                              'sponsorBlockSupport',
                              value,
                            );
                            sponsorBlockSupport.value = value;
                            showToast(
                              context,
                              context.l10n!.settingChangedMsg,
                            );
                          },
                        ),
                      );
                    },
                  ),*/
               /*   ValueListenableBuilder<bool>(
                    valueListenable: playNextSongAutomatically,
                    builder: (_, value, __) {
                      return CustomBar(
                        context.l10n!.automaticSongPicker,
                        FluentIcons.music_note_2_play_20_filled,
                        trailing: Switch(
                          value: value,
                          onChanged: (value) {
                            audioHandler.changeAutoPlayNextStatus();
                            showToast(
                              context,
                              context.l10n!.settingChangedMsg,
                            );
                          },
                        ),
                      );
                    },
                  ),*/
             /*     ValueListenableBuilder<bool>(
                    valueListenable: defaultRecommendations,
                    builder: (_, value, __) {
                      return CustomBar(
                        context.l10n!.originalRecommendations,
                        FluentIcons.channel_share_24_regular,
                        borderRadius: commonCustomBarRadiusLast,
                        trailing: Switch(
                          value: value,
                          onChanged: (value) {
                            addOrUpdateData(
                              'settings',
                              'defaultRecommendations',
                              value,
                            );
                            defaultRecommendations.value = value;
                            showToast(
                              context,
                              context.l10n!.settingChangedMsg,
                            );
                          },
                        ),
                      );
                    },
                  ),
*/
                  // CATEGORY: TOOLS
                  SectionTitle(
                    context.l10n!.tools,
                    primaryColor,
                  ),
                  CustomBar(
                    context.l10n!.clearCache,
                    HugeIcons.strokeRoundedClean,
                    borderRadius: commonCustomBarRadiusFirst,
                    onTap: () {
                      clearCache();
                      showToast(
                        context,
                        '${context.l10n!.cacheMsg}!',
                      );
                    },
                  ),
                  CustomBar(
                    context.l10n!.clearSearchHistory,
                    HugeIcons.strokeRoundedWorkHistory,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmationDialog(
                            submitMessage: context.l10n!.clear,
                            confirmationMessage:
                                context.l10n!.clearSearchHistoryQuestion,
                            onCancel: () => {Navigator.of(context).pop()},
                            onSubmit: () => {
                              Navigator.of(context).pop(),
                              searchHistory = [],
                              deleteData('user', 'searchHistory'),
                              showToast(
                                context,
                                '${context.l10n!.searchHistoryMsg}!',
                              ),
                            },
                          );
                        },
                      );
                    },
                  ),
                  CustomBar(
                    context.l10n!.clearRecentlyPlayed,
                    HugeIcons.strokeRoundedClipboard,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmationDialog(
                            submitMessage: context.l10n!.clear,
                            confirmationMessage:
                                context.l10n!.clearRecentlyPlayedQuestion,
                            onCancel: () => {Navigator.of(context).pop()},
                            onSubmit: () => {
                              Navigator.of(context).pop(),
                              userRecentlyPlayed = [],
                              deleteData('user', 'recentlyPlayedSongs'),
                              showToast(
                                context,
                                '${context.l10n!.recentlyPlayedMsg}!',
                              ),
                            },
                          );
                        },
                      );
                    },
                  ),

                  // CATEGORY: BECOME A SPONSO
                ],
              ),
            // CATEGORY: OTHERS
            SectionTitle(
              context.l10n!.others,
              primaryColor,
            ),
      CustomBar(
        context.l10n!.licenses,
        HugeIcons.strokeRoundedDocumentCode,
        borderRadius: commonCustomBarRadiusFirst,
        onTap: () => NavigationManager.router.go(
          '/settings/license',
        ),
      ),
            CustomBar(
              '${context.l10n!.copyLogs} (${logger.getLogCount()})',
    HugeIcons.strokeRoundedCodeFolder,
              onTap: () async =>
                  showToast(context, await logger.copyLogs(context)),
            ),
      CustomBar(
          context.l10n!.dottunes,
          HugeIcons.strokeRoundedCode,
          borderRadius: commonCustomBarRadiusFirst,
          onTap: () => NavigationManager.router.go(
            '/settings/dottunes',
          )),
            CustomBar(
              context.l10n!.about,
              HugeIcons.strokeRoundedAlien01,
              borderRadius: commonCustomBarRadiusLast,
              onTap: () => NavigationManager.router.go(
                '/settings/about',
              ),
            ),
      CustomBar(
        context.l10n!.update,
        HugeIcons.strokeRoundedWorkUpdate,
        borderRadius: commonCustomBarRadiusLast,
        onTap: () => NavigationManager.router.go(
          '/settings/aboutupdate',
        ),
      ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    ]));
  }
}
