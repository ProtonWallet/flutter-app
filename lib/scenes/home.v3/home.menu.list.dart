// home.view.dart

import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';

class HomeMoreSettings extends StatelessWidget {
  final GestureTapCallback? onUpgrade;
  final GestureTapCallback? onDiscover;
  final GestureTapCallback? onSettings;
  final GestureTapCallback? onSecurity;
  final GestureTapCallback? onRecovery;
  final GestureTapCallback? onReportBug;
  final GestureTapCallback? onLogout;
  final bool hideReport = true;
  final bool hidePayment = true;

  const HomeMoreSettings({
    super.key,
    this.onUpgrade,
    this.onDiscover,
    this.onSettings,
    this.onSecurity,
    this.onRecovery,
    this.onReportBug,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Divider(thickness: 0.2),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              S.of(context).more,
              style: ProtonStyles.body2Regular(color: ProtonColors.textHint),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (!hidePayment)
          _buildListTile(
            context,
            onTap: onUpgrade,
            icon: Assets.images.icon.icDiamondwalletPlus,
            text: S.of(context).wallet_plus,
            textColor: ProtonColors.drawerWalletPlus,
          ),
        _buildListTile(
          context,
          onTap: onDiscover,
          icon: Assets.images.icon.icSquaresInSquarediscover,
          text: S.of(context).discover,
        ),
        _buildListTile(
          context,
          onTap: onSettings,
          icon: Assets.images.icon.icCogWheel,
          text: S.of(context).settings_title,
        ),
        _buildListTile(
          context,
          onTap: onSecurity,
          icon: Assets.images.icon.icShield,
          text: S.of(context).security,
        ),
        _buildListTile(
          context,
          onTap: onRecovery,
          icon: Assets.images.icon.icArrowRotateRight,
          text: S.of(context).recovery,
        ),
        if (!hideReport)
          _buildListTile(
            context,
            onTap: onReportBug,
            icon: Assets.images.icon.icBugreport,
            text: S.of(context).report_a_problem,
          ),
        _buildListTile(
          context,
          onTap: onLogout,
          icon: Assets.images.icon.icArrowOutFromRectanglesignout,
          text: S.of(context).logout,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required GestureTapCallback? onTap,
    required SvgGenImage icon,
    required String text,
    Color? textColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: icon.svg(
        fit: BoxFit.fill,
        width: 20,
        height: 20,
      ),
      title: Transform.translate(
        offset: const Offset(-8, 0),
        child: Text(
          text,
          style: ProtonStyles.body2Medium(
              color: textColor ?? ProtonColors.textHint),
        ),
      ),
    );
  }
}
