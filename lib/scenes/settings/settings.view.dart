import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/url.external.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/custom.loading.dart';
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
    return PageLayoutV1(
      title: S.of(context).settings_title,
      child: Column(
        children: [
          // User Information
          const SizedBox(height: 24),
          SectionUserInfo(
            displayName: viewModel.displayName,
            displayEmail: viewModel.displayEmail,
          ),

          // Section: Account Settings
          const SizedBox(height: 24),
          const SectionHeader(title: 'Account Settings'),
          SettingsGroup(
            children: [
              SettingsItem(
                title: 'Subscription',
                subtitle: 'free',
                onTap: () {},
              ),
              SettingsItem(
                title: 'Sentinel Settings',
                hidden: true,
                onTap: () {},
              ),
              SettingsItem(
                title: 'Account',
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
          const SizedBox(height: 12),
          const SectionHeader(title: 'System Settings'),
          SettingsGroup(
            children: [
              SettingsItem(
                title: 'Theme',
                subtitle: 'System default / Light / Dark',
                onTap: () {},
              ),
              SettingsItem(
                title: 'Default Browser',
                subtitle: 'System default',
                onTap: () {},
              ),
              SettingsItem(
                title: 'Languages',
                onTap: () {},
              ),
              SettingsItem(
                title: S.of(context).setting_receive_inviter_notification,
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
                title: S.of(context).setting_receive_bve_notification,
                logo: !viewModel.loadedWalletUserSettings
                    ? const CustomLoading()
                    : CupertinoSwitch(
                        value: viewModel.receiveEmailIntegrationNotification,
                        activeColor: ProtonColors.protonBlue,
                        onChanged:
                            viewModel.updateReceiveEmailIntegrationNotification,
                      ),
                onTap: () {},
              ),
            ],
          ),

          // Section: Logs
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
              ),
              SettingsItem(
                title: 'Clear all logs',
                onTap: () {},
              ),
            ],
          ),

          // Section: Help Center
          const SizedBox(height: 12),
          const SectionHeader(title: 'Help Center'),
          SettingsGroup(
            children: [
              SettingsItem(
                title: S.of(context).report_a_problem,
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
                title: 'Privacy policy',
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
                title: 'Terms of service',
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
                title: 'How to import your wallet to Proton Wallet',
                hidden: true,
                logo: Assets.images.icon.icArrowOutSquare.svg(
                  height: 20,
                  width: 20,
                  fit: BoxFit.fill,
                ),
                onTap: () {},
              ),
              SettingsItem(
                title: 'Feedback',
                hidden: true,
                logo: Assets.images.icon.icArrowOutSquare.svg(
                  height: 20,
                  width: 20,
                  fit: BoxFit.fill,
                ),
                onTap: () {},
              ),
              SettingsItem(
                title: 'Help center & knowledge base',
                logo: Assets.images.icon.icArrowOutSquare.svg(
                  height: 20,
                  width: 20,
                  fit: BoxFit.fill,
                ),
                onTap: () {
                  ExternalUrl.shared.launchProtonHelpCenter();
                },
              ),
            ],
          ),

          ///
          const SizedBox(height: 24),

          /// Debug tools -- code will the Tree shaking in production
          if (kDebugMode) ...[
            buildDebugSection(),
          ]
        ],
      ),
    );
  }
}
