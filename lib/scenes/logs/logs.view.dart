import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/logs/logs.viewmodel.dart';

class LogsView extends ViewBase<LogsViewModel> {
  const LogsView(LogsViewModel viewModel)
      : super(viewModel, const Key("LogsView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      headerWidget: const CustomHeader(
        title: "Application logs",
        buttonDirection: AxisDirection.right,
      ),
      expanded: false,
      child: viewModel.files.isEmpty
          ? const Center(
              child: Text('No files found in the app logs directory.'))
          : SizedBox(
              height: context.height * 2 / 3,
              child: ListView.builder(
                itemCount: viewModel.files.length,
                itemBuilder: (context, index) {
                  final file = viewModel.files[index];
                  final fileName = file.path.split('/').last;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: ListTile(
                      title: Text(fileName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () => viewModel.shareFile(file as File),
                            tooltip: 'Share log file',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await viewModel.deleteFile(file as File);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$fileName is deleted'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
