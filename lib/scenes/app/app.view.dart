import 'package:flutter/material.dart';
import 'package:wallet/scenes/app/app.viewmodel.dart';
import 'package:wallet/scenes/core/view.dart';

class AppView extends ViewBase<AppViewModel> {
  AppView(AppViewModel viewModel, this.homeView)
      : super(viewModel, const Key("AppView"));
  final Widget homeView;
  // final _formKey = GlobalKey<FormState>();

  @override
  Widget buildWithViewModel(
      BuildContext context, AppViewModel viewModel, ViewSize viewSize) {
    return MaterialApp(
      title: 'Flutter Wallet Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => homeView,
      },
      // home: homeView,
      // routes: ["/", homeView],
    );
  }
}
