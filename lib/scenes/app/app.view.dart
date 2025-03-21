import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/provider/locale.provider.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/scenes/app/app.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';

class AppView extends ViewBase<AppViewModel> {
  const AppView(AppViewModel viewModel, this.rootView)
      : super(viewModel, const Key("AppView"));
  final Widget rootView;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserSettingProvider>(
          create: (context) => UserSettingProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
            create: (context) => viewModel.themeProvider),
        ChangeNotifierProvider<LocaleProvider>(
            create: (context) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(builder: (context,
          ThemeProvider themeProvider, LocaleProvider localeProvider, child) {
        return MaterialApp(
          // ignore: avoid_redundant_argument_values
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
          locale: Provider.of<LocaleProvider>(context, listen: false).locale,
          theme: ThemeData(
            colorScheme: ThemeData(
              brightness: Brightness.light,
            ).colorScheme.copyWith(primary: ProtonColors.textNorm),
            useMaterial3: true,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            extensions: [
              viewModel.lightColorScheme,
              viewModel.lightSvgImage,
            ],
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            extensions: [
              viewModel.darkColorScheme,
              viewModel.darkSvgImage,
            ],
          ),
          themeMode: themeProvider.getThemeMode(
            Provider.of<ThemeProvider>(context, listen: false).themeMode,
          ),
          initialRoute: '/',
          routes: <String, WidgetBuilder>{
            '/': (BuildContext context) => rootView,
          },
          builder: EasyLoading.init(builder: FToastBuilder()),
          navigatorKey: Coordinator.rootNavigatorKey,
        );
      }),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      /// use system themed background before protonColor initialized
      color: ProtonColors.initialized
          ? ProtonColors.backgroundSecondary
          : context.isDarkMode
              ? ProtonColors.defaultLoadBackgroundDark
              : ProtonColors.defaultLoadBackgroundLight,
      child: Center(
        child: Assets.images.welcome.protonWalletLogoMark.svg(
          fit: BoxFit.fitWidth,
          width: MediaQuery.of(context).size.width / 3,
        ),
      ),
    );
  }
}
