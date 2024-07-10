import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/logs/logs.viewmodel.dart';

class LogsView extends ViewBase<LogsViewModel> {
  const LogsView(LogsViewModel viewModel)
      : super(viewModel, const Key("SettingsView"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => {viewModel.shareLogs()},
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => {viewModel.clearLogs()},
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: viewModel.scrollController,
        padding: const EdgeInsets.all(16.0),
        child: SelectableText(
          viewModel.logs,
          style: const TextStyle(fontSize: 14.0),
        ),
      ),
    );
  }
}
