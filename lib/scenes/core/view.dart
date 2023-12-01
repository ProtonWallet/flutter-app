import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:wallet/responsive.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

enum ViewSize { mobile, desktop, tablet }

abstract class ViewBase<V extends ViewModel> extends StatefulWidget {
  final V viewModel;
  late final ViewState<V> _state;
  @protected
  Widget buildWithViewModel(
    BuildContext context,
    V viewModel,
    ViewSize viewSize,
  );

  ViewBase(this.viewModel, Key key) : super(key: key) {
    _state = ViewState<V>();
  }

  @override
  State<ViewBase> createState() {
    // ignore: no_logic_in_create_state
    return _state;
  }

  Future<void> handleRefresh() async {
    return await viewModel.loadData();
  }

  void dispose() {}

  BuildContext get context {
    return _state.context;
  }
}

class ViewState<V extends ViewModel> extends State<ViewBase> {
  late V viewModel;
  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    viewModel = widget.viewModel as V;
    StreamSubscription<ViewModel> streamDatasourceChanged;
    streamDatasourceChanged = viewModel.datasourceChanged.listen((viewModel) {
      setState(() {});
    });
    subscriptions.add(streamDatasourceChanged);
    viewModel.loadData();
    super.initState();
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
    ViewSize size = ViewSize.desktop;
    if (Responsive.isMobile(context)) {
      size = ViewSize.mobile;
    } else if (Responsive.isTablet(context)) {
      size = ViewSize.tablet;
    }
    return widget.buildWithViewModel(context, viewModel, size);
  }
}
