import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/settings/debug.view/debug.viewmodel.dart';

class DebugView extends ViewBase<DebugViewModel> {
  const DebugView(DebugViewModel viewModel)
      : super(viewModel, const Key("DebugView"));

  @override
  Widget build(BuildContext context) {
    return buildOne(context);
  }

  Widget buildOne(BuildContext context) {
    return Text('Item 1');
  }
}
