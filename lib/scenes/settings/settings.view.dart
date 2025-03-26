import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/settings/clear.cache.bloc.dart';
import 'package:wallet/provider/locale.provider.dart';
import 'package:wallet/scenes/components/custom.loading.dart';
import 'package:wallet/scenes/components/dropdown.button.v2.dart';
import 'package:wallet/scenes/components/dropdown.button.v3.dart';
import 'package:wallet/scenes/components/page.layout.v2.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/settings/settings.group.dart';
import 'package:wallet/scenes/settings/settings.header.dart';
import 'package:wallet/scenes/settings/settings.info.dart';
import 'package:wallet/scenes/settings/settings.item.dart';
import 'package:wallet/scenes/settings/settings.viewmodel.dart';

part 'settings.view.debug.dart';

class SettingsView extends ViewBase<SettingsViewModel> with SettingsViewMixin {
  const SettingsView(SettingsViewModel viewModel)
      : super(viewModel, const Key("SettingsView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV2(
      title: context.local.settings_title,
      backgroundColor: ProtonColors.backgroundNorm,
      cbtBgColor: ProtonColors.backgroundSecondary,
      dividerOffset: 8.0,
      child: BlocProvider(
        create: (context) => viewModel.clearCacheBloc,
        child: Column(
          children: [
            SizedBoxes.box8,

            /// User info section
            SectionUserInfo(
              displayName: viewModel.displayName,
              displayEmail: viewModel.displayEmail,
            ),

            // Section: Account Settings
            SizedBoxes.box24,
            SectionHeader(title: context.local.account_settings),
            SettingsGroup(
              children: [
                SettingsItem(
                  title: context.local.subscription,
                  subtitle: 'free',
                  onTap: () {},
                  hidden: true,
                ),
                SettingsItem(
                  title: context.local.sentinel_settings,
                  hidden: true,
                  onTap: () {},
                ),
                SettingsItem(
                  title: context.local.account,
                  onTap: () {
                    ExternalUrl.shared.launchProtonAccount();
                  },
                ),
              ],
            ),

            // Section: System Settings
            SizedBoxes.box12,
            SectionHeader(title: context.local.system_settings),
            SettingsGroup(
              children: [
                SettingsItem(
                  title: context.local.theme_mode,
                  logo: !viewModel.loadedWalletUserSettings
                      ? const CustomLoading()
                      : DropdownButtonV3(
                          labelText: context.local.theme_mode,
                          displayLabel: false,
                          width: 170,
                          maxSuffixIconWidth: 0,
                          items: [
                            ThemeMode.system,
                            ThemeMode.light,
                            ThemeMode.dark
                          ],
                          itemsText: [
                            context.local.system_default_mode,
                            context.local.light_mode,
                            context.local.dark_mode
                          ],
                          selected: viewModel.themeModeValue,
                          onChanged: viewModel.updateThemeMode,
                        ),
                  onTap: () {},
                ),
                SettingsItem(
                  title: context.local.languages,
                  logo: !viewModel.loadedWalletUserSettings
                      ? const CustomLoading()
                      : Consumer<LocaleProvider>(
                          builder: (context, model, child) {
                            return DropdownButtonV3(
                              labelText: context.local.languages,
                              displayLabel: false,
                              width: 170,
                              maxSuffixIconWidth: 0,
                              items: [LocaleProvider.systemDefault] +
                                  S.supportedLocales
                                      .where((e) => e.toLanguageTag() != "zh")
                                      .map((e) => e.toLanguageTag())
                                      .toList(),
                              itemsText: [
                                    LocaleProvider.localeName(
                                        LocaleProvider.systemDefault, context)
                                  ] +
                                  S.supportedLocales
                                      .where((e) => e.toLanguageTag() != "zh")
                                      .map((e) => LocaleProvider.localeName(
                                            e.toLanguageTag(),
                                            context,
                                          ))
                                      .toList(),
                              selected: viewModel.localeValue,
                              onChanged: viewModel.updateLocale,
                            );
                          },
                        ),
                  onTap: () {},
                ),
              ],
            ),

            SizedBoxes.box12,
            SectionHeader(title: context.local.wallet_settings),
            SettingsGroup(
              children: [
                SettingsItem(
                  title: context.local.setting_receive_inviter_notification,
                  logo: !viewModel.loadedWalletUserSettings
                      ? const CustomLoading()
                      : CupertinoSwitch(
                          value: viewModel.receiveInviterNotification,
                          activeColor: ProtonColors.protonBlue,
                          thumbColor: ProtonColors.backgroundNorm,
                          trackColor: ProtonColors.textHint,
                          onChanged: viewModel.updateReceiveInviterNotification,
                        ),
                  onTap: () {},
                ),
                SettingsItem(
                  title: context.local.setting_receive_bve_notification,
                  logo: !viewModel.loadedWalletUserSettings
                      ? const CustomLoading()
                      : CupertinoSwitch(
                          value: viewModel.receiveEmailIntegrationNotification,
                          activeColor: ProtonColors.protonBlue,
                          thumbColor: ProtonColors.backgroundNorm,
                          trackColor: ProtonColors.textHint,
                          onChanged: viewModel
                              .updateReceiveEmailIntegrationNotification,
                        ),
                  onTap: () {},
                ),
                SettingsItem(
                  title: context.local.setting_custom_stopgap,
                  logo: !viewModel.loadedWalletUserSettings
                      ? const CustomLoading()
                      : Transform.translate(
                          offset: const Offset(
                            10,
                            0,
                          ),
                          child: DropdownButtonV2(
                            title: context.local.setting_custom_stopgap,
                            width: 80,
                            maxSuffixIconWidth: 20,
                            items: stopgapOptions,
                            itemsText: stopgapOptions
                                .map((v) => v.toString())
                                .toList(),
                            valueNotifier: viewModel.stopgapValueNotifier,
                          ),
                        ),
                  onTap: () {},
                ),
              ],
            ),
            if (viewModel.isTraceLoggerEnabled()) ...[
              /// Section: Logs
              const SizedBox(height: 12),
              const SectionHeader(title: 'Logs'),
              SettingsGroup(
                children: [
                  SettingsItem(
                    title: 'Application logs',
                    subtitle: 'View logs',
                    onTap: () {
                      viewModel.move(NavID.logs);
                    },
                  ),
                  SettingsItem(
                    title: 'Force reload the application',
                    subtitle: 'Wipe cache and reload',
                    onTap: () {},
                    hidden: true,
                  ),
                  SettingsItem(
                    title: 'Clear all logs',
                    subtitle: viewModel.logsFolderSize,
                    onTap: () async {
                      EasyLoading.show(status: 'Clearing logs...');
                      await viewModel.clearLogs();
                      EasyLoading.dismiss();
                    },
                  ),
                ],
              ),
            ],

            // Section: Help Center
            SizedBoxes.box12,
            SectionHeader(title: context.local.help_center),
            BlocListener<ClearCacheBloc, ClearCacheState>(
              listener: (context, state) {
                if (!state.isClearing && state.hasCache) {
                  context.showSnackbar(S.of(context).local_cache_clear);
                }
              },
              child: BlocSelector<ClearCacheBloc, ClearCacheState, bool>(
                selector: (state) {
                  return state.isClearing;
                },
                builder: (context, isClearing) {
                  return SettingsGroup(
                    children: [
                      SettingsItem(
                        title: context.local.report_a_problem,
                        logo: Assets.images.icon.icBugreport.svg(
                          height: 20,
                          width: 20,
                          fit: BoxFit.fill,
                        ),
                        onTap: () {
                          viewModel.move(NavID.natvieReportBugs);
                        },
                      ),
                      SettingsItem(
                        title: context.local.privacy_policy,
                        onTap: () {
                          ExternalUrl.shared.lanuchPrivacy();
                        },
                      ),
                      SettingsItem(
                        title: context.local.terms_of_service,
                        onTap: () {
                          ExternalUrl.shared.lanuchTerms();
                        },
                      ),
                      SettingsItem(
                        title: context.local.how_to_import_wallet_,
                        hidden: true,
                        onTap: () {},
                      ),
                      SettingsItem(
                        title: context.local.feedback,
                        hidden: true,
                        onTap: () {},
                      ),
                      SettingsItem(
                        title: context.local.help_center_knowledge_base,
                        onTap: () {
                          ExternalUrl.shared.launchProtonHelpCenter();
                        },
                      ),
                      SettingsItem(
                        title: context.local.help_center_clear_caches,
                        logo: isClearing
                            ? const CustomLoading(size: 20)
                            : const SizedBox(),
                        onTap: () {
                          if (!isClearing) {
                            viewModel.clearCacheBloc.add(ClearingCache());
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            ///
            SizedBoxes.box24,

            /// Debug tools -- code will the Tree shaking in production
            if (kDebugMode) ...[
              buildDebugSection(viewModel),
            ],

            /// account delete
            if (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS) ...[
              SettingsGroup(
                children: [
                  SettingsItem(
                    title: S.of(context).delete_proton_account,
                    color: ProtonColors.notificationError,
                    logo: Icon(
                      Icons.delete_rounded,
                      size: 20,
                      color: ProtonColors.notificationError,
                    ),
                    onTap: viewModel.deleteAccount,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
