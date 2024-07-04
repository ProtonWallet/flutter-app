import 'package:flutter/material.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';

class ExampleSheet {
  static void show(BuildContext context, HomeViewModel viewModel) {
    HomeModalBottomSheet.show(context, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return const SizedBox();
    }));
  }
}
