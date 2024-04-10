import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/theme/theme.font.dart';

class CommonSettings extends StatelessWidget {
  const CommonSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            S.of(context).dark_mode,
            style: FontManager.body2Median(ProtonColors.textNorm),
          ),
          ToggleSwitch(
            minWidth: 60.0,
            cornerRadius: 20.0,
            activeBgColors: [
              [ProtonColors.signalError],
              [ProtonColors.signalSuccess],
            ],
            activeFgColor: Colors.white,
            inactiveBgColor: ProtonColors.textWeak,
            inactiveFgColor: Colors.white,
            initialLabelIndex:
                Provider.of<ThemeProvider>(context).themeMode == "light"
                    ? 0
                    : 1,
            totalSwitches: 2,
            labels: [S.of(context).no, S.of(context).yes],
            radiusStyle: true,
            onToggle: (index) {
              if (index == 0) {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleChangeTheme("light");
              } else {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleChangeTheme("dark");
              }
            },
          ),
        ],
      ),
    );
  }
}
