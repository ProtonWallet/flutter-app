import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/nested.navigator.dart';
import 'package:wallet/scenes/core/responsive.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

enum ViewSize { mobile, desktop }

abstract class ViewBase<V extends ViewModel> extends StatefulWidget {
  final V viewModel;
  final Widget? locker;

  @protected
  Widget build(BuildContext context);

  const ViewBase(this.viewModel, Key key, {this.locker}) : super(key: key);

  @override
  State<ViewBase> createState() {
    return ViewState<V>();
  }

  Future<void> handleRefresh() async {
    return viewModel.loadData();
  }

  void dispose() {
    logger.d("$key dispose is called");
  }

  /// Helper build large/small screen drawer and content switcher.
  /// this reqire nested navigator key and view model screen size state configuration
  Widget buildDrawerNavigator(
    BuildContext context, {
    required double drawerMaxWidth,
    required AppBar Function(BuildContext context) appBar,
    required WidgetBuilder drawer,
    required WidgetBuilder content,
    required DrawerCallback onDrawerChanged,
  }) {
    return Responsive(
      mobile: _buildMobile(
        context,
        appBar,
        drawer,
        content,
        onDrawerChanged,
      ),
      desktop: _buildDesktop(
        drawerMaxWidth,
        context,
        appBar,
        drawer,
        content,
        onDrawerChanged,
      ),
    );
  }

  Widget _buildMobile(
    BuildContext context,
    AppBar Function(BuildContext context) appBar,
    WidgetBuilder drawer,
    WidgetBuilder content,
    DrawerCallback onDrawerChanged,
  ) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: ProtonColors.backgroundProton,
          drawer:
              viewModel.currentSize == ViewSize.mobile ? null : drawer(context),
          onDrawerChanged:
              viewModel.currentSize == ViewSize.mobile ? null : onDrawerChanged,
          body: _buildNavigatorView(
            context,
            appBar,
            drawer,
            content,
            onDrawerChanged,
          ),
        ),
        // const LockOverlay(),
      ],
    );
  }

  Widget _buildDesktop(
    double drawerMaxWidth,
    BuildContext context,
    AppBar Function(BuildContext context) appBar,
    WidgetBuilder drawer,
    WidgetBuilder content,
    DrawerCallback onDrawerChanged,
  ) {
    return Scaffold(
        body: Row(children: [
      ConstrainedBox(
          constraints: BoxConstraints(maxWidth: drawerMaxWidth),
          child: drawer(context)),
      const VerticalDivider(thickness: 1, width: 1),
      Expanded(
          child: _buildNavigatorView(
        context,
        appBar,
        drawer,
        content,
        onDrawerChanged,
      ))
    ]));
  }

  Widget _buildNavigatorView(
    BuildContext context,
    AppBar Function(BuildContext context) appBar,
    WidgetBuilder drawer,
    WidgetBuilder content,
    DrawerCallback onDrawerChanged,
  ) {
    /// in case the nested navigator key is not set, set it.
    ///   need to rearrange the location
    Coordinator.nestedNavigatorKey ??= GlobalKey<NavigatorState>();
    return NestedNavigator(
      builder: (context) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: ProtonColors.backgroundProton,
          appBar: appBar(context),
          drawer:
              viewModel.currentSize == ViewSize.mobile ? drawer(context) : null,
          onDrawerChanged:
              viewModel.currentSize == ViewSize.mobile ? onDrawerChanged : null,
          body: content(context),
        );
      },
      navigatorKey: viewModel.nestedNavigatorKey,
    );
  }
}

// view base state
class ViewState<V extends ViewModel> extends State<ViewBase>
    with AutomaticKeepAliveClientMixin<ViewBase> {
  late V viewModel;
  ViewSize? current;
  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    viewModel = widget.viewModel as V;
    super.initState();
    final streamDatasourceChanged =
        viewModel.datasourceChanged.listen((viewModel) {
      setState(() {});
    });
    subscriptions.add(streamDatasourceChanged);
    viewModel.loadData();
  }

  @override
  void dispose() {
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
    widget.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // if not enable size state, skip the size check
    if (viewModel.screenSizeState) {
      ViewSize size = ViewSize.desktop;
      if (Responsive.isMobile(context)) {
        size = ViewSize.mobile;
      } else if (Responsive.isTablet(context)) {
        size = ViewSize.mobile;
      }
      viewModel.currentSize ??= size;
      if (viewModel.currentSize != size) {
        viewModel.currentSize = size;
        setState(() {});
      }
    }

    final Widget? lockOverlay = widget.locker;
    return lockOverlay == null
        ? widget.build(context)
        : Stack(
            children: [
              widget.build(context),
              lockOverlay,
            ],
          );
  }

  @override
  bool get wantKeepAlive {
    // keep a live, when navigation screen goes to backgroun
    return viewModel.keepAlive;
  }

  @override
  void reassemble() {
    // add your logic
    super.reassemble();
    logger.i('Hot reload occurred : in $this');
  }
}
