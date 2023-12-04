import 'package:flutter/material.dart';
import 'package:wallet/provider/locale.provider.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/scenes/app/app.viewmodel.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

class AppView extends ViewBase<AppViewModel> {
  AppView(AppViewModel viewModel, this.homeView)
      : super(viewModel, const Key("AppView"));
  final Widget homeView;

  @override
  Widget buildWithViewModel(
      BuildContext context, AppViewModel viewModel, ViewSize viewSize) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
            create: (context) => ThemeProvider()),
        ChangeNotifierProvider<LocaleProvider>(
            create: (context) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(builder: (context,
          ThemeProvider themeProvider, LocaleProvider localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'Proton Wallet',
          onGenerateTitle: (context) {
            return S.of(context)!.appName;
          },

          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          supportedLocales: const [
            Locale('en', ''),
            ...S.supportedLocales,
          ],

          localeResolutionCallback: (locale, supportLocales) {
            if (locale?.languageCode == 'zh') {
              if (locale?.scriptCode == 'Hant') {
                return const Locale('zh', 'HK'); //tranditional
              } else {
                return const Locale('zh', 'CN'); //simplified
              }
            }
            return null;
          },

          locale: Provider.of<LocaleProvider>(context, listen: false).locale,

          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),

          themeMode: themeProvider.getThemeMode(
              Provider.of<ThemeProvider>(context, listen: false).themeMode),

          darkTheme: ThemeData(brightness: Brightness.dark),

          initialRoute: '/',

          routes: <String, WidgetBuilder>{
            '/': (BuildContext context) => homeView,
          },
          // home: homeView,
          // routes: ["/", homeView],
        );
      }),
    );
  }
}
