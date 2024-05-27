import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/core/responsive.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

enum ViewSize { mobile, desktop, tablet }

abstract class ViewBase<V extends ViewModel> extends StatefulWidget {
  final V viewModel;
  @protected
  Widget buildWithViewModel(
    BuildContext context,
    V viewModel,
    ViewSize viewSize,
  );

  const ViewBase(this.viewModel, Key key) : super(key: key);

  @override
  State<ViewBase> createState() {
    return ViewState<V>();
  }

  Future<void> handleRefresh() async {
    return await viewModel.loadData();
  }

  void dispose() {
    logger.d("dispose is called");
  }
}

class ViewState<V extends ViewModel> extends State<ViewBase>
    with AutomaticKeepAliveClientMixin<ViewBase>, WidgetsBindingObserver {
  late V viewModel;
  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    viewModel = widget.viewModel as V;
    super.initState();
    StreamSubscription<ViewModel> streamDatasourceChanged;
    streamDatasourceChanged = viewModel.datasourceChanged.listen((viewModel) {
      setState(() {});
    });
    subscriptions.add(streamDatasourceChanged);
    viewModel.loadData();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

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
    ViewSize size = ViewSize.desktop;
    if (Responsive.isMobile(context)) {
      size = ViewSize.mobile;
    } else if (Responsive.isTablet(context)) {
      size = ViewSize.tablet;
    }
    return widget.buildWithViewModel(context, viewModel, size);
  }

  @override
  bool get wantKeepAlive {
    return viewModel.keepAlive;
  }

  @override
  void reassemble() {
    // add your logic
    super.reassemble();
    logger.i('Hot reload occurred : in $this');
  }
}
