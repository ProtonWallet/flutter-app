import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:wallet/responsive.dart';
import 'package:wallet/scenes/core/view_model.dart';

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

  void dispose() {}
}

class ViewState<V extends ViewModel> extends State<ViewBase> {
  late V viewModel;
  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    viewModel = widget.viewModel as V;
    // StreamSubscription<ViewModel> _streamDatasourceChanged;
    // _streamDatasourceChanged = viewModel.datasourceChanged.listen((viewModel) {
    //   setState(() {});
    // });
    // subscriptions.add(_streamDatasourceChanged);
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
