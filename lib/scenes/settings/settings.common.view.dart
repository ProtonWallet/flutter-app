import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';
import 'package:wallet/provider/locale.provider.dart';
import 'package:wallet/provider/theme.provider.dart';

class CommonSettings extends StatelessWidget {
  const CommonSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // use MediaQuery get screen size
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 10),
            child: Text(S.of(context)!.settings_title),
          ),
          const SizedBox(
            height: 10,
          ),
          ExpansionTile(
            initiallyExpanded: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.of(context)!.themeMode),
                Text(ThemeProvider.getThemeModeName(
                    Provider.of<ThemeProvider>(context).themeMode, context)),
              ],
            ),
            children: [
              // auto
              _themeModeItem(const Icon(Icons.sync), 'system', context),
              // dark
              _themeModeItem(const Icon(Icons.brightness_2), 'dark', context),
              // light
              _themeModeItem(
                  const Icon(Icons.wb_sunny_outlined), 'light', context),
            ],
          ),
          ExpansionTile(
            initiallyExpanded: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.of(context)!.settingLanguage),
                Text(LocaleProvider.localeName(
                    Provider.of<LocaleProvider>(context).language, context)),
              ],
            ),
            children: [
              // auto
              _languageItem('', context),
              _languageItem('zh', context),
              _languageItem('en', context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _languageItem(String lang, context) {
    return InkWell(
      onTap: () {
        Provider.of<LocaleProvider>(context, listen: false)
            .toggleChangeLocale(lang);
      },
      child: Container(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 0,
          bottom: 0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Provider.of<LocaleProvider>(context).language == lang
                ? Theme.of(context).primaryColor
                : null,
          ),
          child: ListTile(
            leading: const Icon(Icons.drag_handle),
            title: Container(
              transform: Matrix4.translationValues(0, 0.0, 0.0),
              child: Text(
                LocaleProvider.localeName(lang, context),
                // style: TextStyle(
                //   color: Provider.of<LocaleProvider>(context).language == lang
                //       ? Theme.of(context).primaryColor
                //       : null,
                // ),
              ),
            ),
            // title: Text(LocaleProvider.localeName(lang, context)),
            // trailing: const Opacity(
            //   opacity: 1,
            //   // Provider.of<LocaleProvider>(context).language == lang ? 1 : 0,
            //   child: Icon(Icons.done),
            // ),
            trailing: Provider.of<LocaleProvider>(context).language == lang
                ? const Icon(Icons.done)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _themeModeItem(Icon icon, String mode, context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => InkWell(
        onTap: () {
          themeProvider.toggleChangeTheme(mode);
        },
        child: Container(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 0,
            bottom: 0,
          ),
          child: ListTile(
            leading: icon,
            title: Container(
              transform: Matrix4.translationValues(0, 0.0, 0.0),
              child: Text(ThemeProvider.getThemeModeName(mode, context)),
            ),
            // trailing: Opacity(
            //   opacity: themeProvider.themeMode == mode ? 1 : 0,
            //   child: Icon(Icons.done),
            // ),
            trailing:
                themeProvider.themeMode == mode ? const Icon(Icons.done) : null,
          ),
        ),
      ),
    );
  }
}
