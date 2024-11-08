import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/settings/clear.cache.bloc.dart';
import 'package:wallet/scenes/components/custom.loading.dart';
import 'package:wallet/scenes/components/dropdown.button.v2.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
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
    return BlocProvider(
      create: (context) => viewModel.clearCacheBloc,
      child: PageLayoutV1(
        title: context.local.settings_title,
        child: Column(
          children: [
            // User Information
            SizedBoxes.box24,
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
                  logo: Assets.images.icon.icArrowOutSquare.svg(
                    height: 20,
                    width: 20,
                    fit: BoxFit.fill,
                  ),
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
                  title: context.local.theme,
                  subtitle: 'System default / Light / Dark',
                  onTap: () {},
                  hidden: true,
                ),
                SettingsItem(
                  title: context.local.default_browser,
                  subtitle: 'System default',
                  hidden: true,
                  onTap: () {},
                ),
                SettingsItem(
                  title: context.local.languages,
                  hidden: true,
                  onTap: () {},
                ),
                SettingsItem(
                  title: context.local.setting_receive_inviter_notification,
                  logo: !viewModel.loadedWalletUserSettings
                      ? const CustomLoading()
                      : CupertinoSwitch(
                          value: viewModel.receiveInviterNotification,
                          activeColor: ProtonColors.protonBlue,
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
                  onTap: () {},
                  hidden: true,
                ),
              ],
            ),

            // Section: Help Center
            SizedBoxes.box12,
            SectionHeader(title: context.local.help_center),
            BlocListener<ClearCacheBloc, ClearCacheState>(
              listener: (context, state) {
                if (!state.isClearing && state.hasCache) {
                  CommonHelper.showSnackbar(
                      context, S.of(context).local_cache_clear);
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
                        logo: Assets.images.icon.icArrowOutSquare.svg(
                          height: 20,
                          width: 20,
                          fit: BoxFit.fill,
                        ),
                        onTap: () {
                          ExternalUrl.shared.lanuchPrivacy();
                        },
                      ),
                      SettingsItem(
                        title: context.local.terms_of_service,
                        logo: Assets.images.icon.icArrowOutSquare.svg(
                          height: 20,
                          width: 20,
                          fit: BoxFit.fill,
                        ),
                        onTap: () {
                          ExternalUrl.shared.lanuchTerms();
                        },
                      ),
                      SettingsItem(
                        title: context.local.how_to_import_wallet_,
                        hidden: true,
                        logo: Assets.images.icon.icArrowOutSquare.svg(
                          height: 20,
                          width: 20,
                          fit: BoxFit.fill,
                        ),
                        onTap: () {},
                      ),
                      SettingsItem(
                        title: context.local.feedback,
                        hidden: true,
                        logo: Assets.images.icon.icArrowOutSquare.svg(
                          height: 20,
                          width: 20,
                          fit: BoxFit.fill,
                        ),
                        onTap: () {},
                      ),
                      SettingsItem(
                        title: context.local.help_center_knowledge_base,
                        logo: Assets.images.icon.icArrowOutSquare.svg(
                          height: 20,
                          width: 20,
                          fit: BoxFit.fill,
                        ),
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
              buildDebugSection(),
            ]
          ],
        ),
      ),
    );
  }
}
