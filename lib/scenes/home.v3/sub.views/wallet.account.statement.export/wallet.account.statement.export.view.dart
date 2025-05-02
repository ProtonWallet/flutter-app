import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/date.input.v1.dart';
import 'package:wallet/scenes/components/dropdown.button.v3.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.statement.export/wallet.account.statement.export.viewmodel.dart';

class WalletAccountStatementExportView
    extends ViewBase<WalletAccountStatementExportViewModel> {
  const WalletAccountStatementExportView(
      WalletAccountStatementExportViewModel viewModel)
      : super(viewModel, const Key("WalletAccountStatementExportView"));

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return PageLayoutV1(
        headerWidget: CustomHeader(
          buttonDirection: AxisDirection.right,
          padding: const EdgeInsets.all(0.0),
          button: CloseButtonV1(
            backgroundColor: ProtonColors.backgroundSecondary,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        child: Transform.translate(
          offset: const Offset(0, -30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              context.images.download.image(
                fit: BoxFit.fill,
                width: 240,
                height: 167,
              ),
              Text(
                context.local.export_account_statement,
                style: ProtonStyles.headline(color: ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                context.local.export_account_statement_content,
                style: ProtonStyles.body2Regular(color: ProtonColors.textWeak),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                width: context.width,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: ProtonColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Column(children: [
                  DateInputV1(
                    textController: viewModel.dateTextEditingController,
                    myFocusNode: viewModel.dateFocusNode,
                    initialDate: viewModel.initialDate,
                    labelText: context.local.export_date,
                  ),
                  const Divider(
                    thickness: 0.2,
                    height: 1,
                  ),
                  DropdownButtonV3(
                    labelText: context.local.export_format,
                    width: context.width,
                    maxSuffixIconWidth: 0,
                    items: [
                      ExportType.pdf,
                      ExportType.csv,
                    ],
                    itemsText: [
                      context.local.export_format_pdf,
                      context.local.export_format_csv,
                    ],
                    selected: viewModel.exportType,
                    onChanged: viewModel.changeExportType,
                    padding: const EdgeInsets.only(
                      left: defaultPadding,
                      right: 38,
                      top: 12,
                      bottom: 4,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                ]),
              ),
              const SizedBox(
                height: 30,
              ),
              ButtonV6(
                onPressed: () async {
                  final fileExt =
                      viewModel.exportType == ExportType.pdf ? "pdf" : "csv";
                  try {
                    final data = await viewModel.getAccountStatementData();
                    if (context.mounted) {
                      final fileDest = await FilePicker.platform.saveFile(
                        dialogTitle:
                            context.local.export_select_output_file_desc,
                        fileName:
                            "${context.local.export_select_output_file_default_name}.$fileExt",
                        bytes: data,
                      );
                      if (context.mounted && fileDest != null) {
                        LocalToast.showToast(
                            context, context.local.save_file_to(fileDest));
                      }
                    }
                  } catch (e) {
                    e.toString();
                  }
                },
                text: context.local.export,
                width: context.width,
                backgroundColor: ProtonColors.protonBlue,
                textStyle: ProtonStyles.body1Medium(
                  color: ProtonColors.textInverted,
                ),
                height: 55,
              ),
            ],
          ),
        ),
      );
    });
  }
}
