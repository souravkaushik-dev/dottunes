/*dottunes envor studios*/

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/screens/search_page.dart';
import 'package:dottunes/services/data_manager.dart';
import 'package:dottunes/services/router_service.dart';
import 'package:dottunes/services/settings_manager.dart';
import 'package:dottunes/style/app_colors.dart';
import 'package:dottunes/style/app_themes.dart';
import 'package:dottunes/utilities/flutter_bottom_sheet.dart';
import 'package:dottunes/utilities/flutter_toast.dart';
import 'package:dottunes/utilities/url_launcher.dart';
import 'package:dottunes/widgets/confirmation_dialog.dart';
import 'package:dottunes/widgets/custom_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final activatedColor = Theme.of(context).colorScheme.inversePrimary;
    final inactivatedColor = Theme.of(context).colorScheme.secondaryContainer;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Settings', style: TextStyle(
                fontFamily: 'Nothing',  // Replace with your custom font family
                fontSize: 34, // Set the desired font size
                fontWeight: FontWeight.bold, // Optional: Add weight if needed
              ),
              ),
              background: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer, // Set the color for the background
                ),
              ),
            ),
            pinned: true,
            floating: true,
            snap: false,
            backgroundColor: Colors.transparent, // Remove the default color to let the rounded corner show
          ),
          _buildPreferencesSection(primaryColor, activatedColor, inactivatedColor, context),
          _buildToolsSection(primaryColor, activatedColor, inactivatedColor, context),
          _buildOthersSection(primaryColor, activatedColor, inactivatedColor, context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(Color primaryColor, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  SliverList _buildPreferencesSection(
      Color primaryColor,
      Color activatedColor,
      Color inactivatedColor,
      BuildContext context,
      ) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          _buildSectionTitle(primaryColor, context.l10n!.preferences),
          CustomBar(
            context.l10n!.accentColor,
            HugeIcons.strokeRoundedPaintBoard,
            onTap: () => showCustomBottomSheet(
              context,
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: availableColors.length,
                itemBuilder: (context, index) {
                  final color = availableColors[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (availableColors.length > index)
                          GestureDetector(
                            onTap: () {
                              addOrUpdateData(
                                'settings',
                                'accentColor',
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
                            child: Material(
                              elevation: 4,
                              shape: const CircleBorder(),
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: themeMode == ThemeMode.light
                                    ? color.withAlpha(150)
                                    : color,
                              ),
                            ),
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
                  itemCount: availableModes.length,
                  itemBuilder: (context, index) {
                    final mode = availableModes[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      color: themeMode == mode ? activatedColor : inactivatedColor,
                      child: ListTile(
                        minVerticalPadding: 65,
                        title: Text(
                          mode.name,
                        ),
                        onTap: () {
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
                      ),
                    );
                  },
                ),
              );
            },
          ),
          CustomBar(
            context.l10n!.language,
            HugeIcons.strokeRoundedTranslation,
            onTap: () {
              final availableLanguages = appLanguages.keys.toList();
              final activeLanguageCode =
                  Localizations.localeOf(context).languageCode;
              showCustomBottomSheet(
                context,
                ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: availableLanguages.length,
                  itemBuilder: (context, index) {
                    final language = availableLanguages[index];
                    final languageCode = appLanguages[language] ?? 'en';
                    return Card(
                      color: activeLanguageCode == languageCode
                          ? activatedColor
                          : inactivatedColor,
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        minVerticalPadding: 65,
                        title: Text(
                          language,
                        ),
                        onTap: () {
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

                          showToast(
                            context,
                            context.l10n!.languageMsg,
                          );
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
          CustomBar(
            context.l10n!.audioQuality,
            Icons.music_note,
            onTap: () {
              final availableQualities = ['low', 'medium', 'high'];

              showCustomBottomSheet(
                context,
                ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: availableQualities.length,
                  itemBuilder: (context, index) {
                    final quality = availableQualities[index];
                    final isCurrentQuality =
                        audioQualitySetting.value == quality;

                    return Card(
                      color: isCurrentQuality ? activatedColor : inactivatedColor,
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        minVerticalPadding: 65,
                        title: Text(quality),
                        onTap: () {
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
                      ),
                    );
                  },
                ),
              );
            },
          ),
          CustomBar(
            context.l10n!.dynamicColor,
            HugeIcons.strokeRoundedToggleOn,
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

        ],
      ),
    );
  }

  SliverList _buildToolsSection(
      Color primaryColor,
      Color activatedColor,
      Color inactivatedColor,
      BuildContext context,
      ) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          _buildSectionTitle(primaryColor, context.l10n!.tools),
          CustomBar(
            context.l10n!.clearCache,
            HugeIcons.strokeRoundedClean,
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
            HugeIcons.strokeRoundedRotateClockwise,
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
            HugeIcons.strokeRoundedFileSearch,
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
          CustomBar(
            context.l10n!.backupUserData,
            HugeIcons.strokeRoundedFolderSync,
            onTap: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Text(context.l10n!.folderRestrictions),
                    actions: <Widget>[
                      TextButton(
                        child: Text(
                          context.l10n!.understand.toUpperCase(),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
              final response = await backupData(context);
              showToast(context, response);
            },
          ),

          CustomBar(
            context.l10n!.restoreUserData,
            HugeIcons.strokeRoundedFolderAdd,
            onTap: () async {
              final response = await restoreData(context);
              showToast(context, response);
            },
          ),
        ],
      ),
    );
  }

  SliverList _buildOthersSection(
      Color primaryColor,
      Color activatedColor,
      Color inactivatedColor,
      BuildContext context,
      ) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          _buildSectionTitle(primaryColor, context.l10n!.others),
          CustomBar(
            context.l10n!.licenses,
            HugeIcons.strokeRoundedSoftwareLicense,
            onTap: () => NavigationManager.router.go(
              '/settings/license',
            ),
          ),
          CustomBar(
            '${context.l10n!.copyLogs} (${logger.getLogCount()})',
            HugeIcons.strokeRoundedRssError,
            onTap: () async =>
                showToast(context, await logger.copyLogs(context)),
          ),
          CustomBar(
            context.l10n!.about,
            HugeIcons.strokeRoundedBookOpen01,
            onTap: () => NavigationManager.router.go(
              '/settings/about',
            ),
          ),
          CustomBar(
            'Dottunes', // Directly pass the string
            HugeIcons.strokeRoundedAiProgramming,
            onTap: () => NavigationManager.router.go(
              '/settings/aboutdottunes',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

class CustomBar extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const CustomBar(this.title, this.icon, {this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(title),
      leading: Icon(icon),
      trailing: trailing,
    );
  }
}