import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/user.session.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/provider/locale.provider.dart';
import 'package:wallet/provider/proton.wallet.provider.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/scenes/app/app.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

class AppView extends ViewBase<AppViewModel> {
  const AppView(AppViewModel viewModel, this.rootView)
      : super(viewModel, const Key("AppView"));
  final Widget rootView;

  @override
  Widget buildWithViewModel(
      BuildContext context, AppViewModel viewModel, ViewSize viewSize) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserSessionProvider>(
          create: (context) => UserSessionProvider(),
        ),
        ChangeNotifierProvider<UserSettingProvider>(
          create: (context) => UserSettingProvider(),
        ),
        ChangeNotifierProvider<ProtonWalletProvider>(
          create: (context) => ProtonWalletProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
            create: (context) => ThemeProvider()),
        ChangeNotifierProvider<LocaleProvider>(
            create: (context) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(builder: (context,
          ThemeProvider themeProvider, LocaleProvider localeProvider, child) {
        return MaterialApp(
          debugShowMaterialGrid: false,
          showSemanticsDebugger: false,
          debugShowCheckedModeBanner: kDebugMode,
          title: "Proton Wallet",
          onGenerateTitle: (context) {
            return S.of(context).app_name;
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
            colorScheme:
                ThemeData(brightness: Brightness.light).colorScheme.copyWith(
                      primary: ProtonColors.textNorm,
                      surface: ProtonColors.surfaceLight,
                    ),
            useMaterial3: true,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          themeMode: themeProvider.getThemeMode(
              Provider.of<ThemeProvider>(context, listen: false).themeMode),
          darkTheme: ThemeData(brightness: Brightness.dark),
          initialRoute: '/',
          routes: <String, WidgetBuilder>{
            '/': (BuildContext context) => rootView,
          },
          builder: EasyLoading.init(builder: FToastBuilder()),
          navigatorKey: Coordinator.navigatorKey,
          // home: homeView,
          // routes: ["/", homeView],
        );
      }),
    );
  }
}
