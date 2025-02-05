import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/qrcode.content/qrcode.content.viewmodel.dart';

class QRcodeContentView extends ViewBase<QRcodeContentViewModel> {
  const QRcodeContentView(QRcodeContentViewModel viewModel)
      : super(viewModel, const Key("QRcodeContentView"));

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return PageLayoutV1(
        headerWidget: CustomHeader(
          title: getTitle(context),
          buttonDirection: AxisDirection.left,
          padding: const EdgeInsets.all(0.0),
          button: CloseButtonV1(onPressed: () {
            Navigator.of(context).pop();
          }),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: ProtonColors.white,
            // border: Border.all(color: Colors.black, width: 1.0),
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: defaultPadding),
              Container(
                  color: ProtonColors.white,
                  padding: const EdgeInsets.all(10),
                  child: QrImageView(
                    size: min(MediaQuery.of(context).size.width, 200),
                    data: viewModel.data,
                  )),
              if (viewModel.qRcodeType == QRcodeType.bitcoinAddress)
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: viewModel.data));
                    LocalToast.showToast(
                      context,
                      S.of(context).copied,
                      icon: null,
                    );
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: min(
                                MediaQuery.of(context).size.width -
                                    defaultPadding * 2 -
                                    50,
                                200),
                            child: Text(
                              viewModel.data,
                              style: ProtonStyles.body2Regular(
                                  color: ProtonColors.textWeak),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            )),
                        Icon(
                          Icons.copy_rounded,
                          size: 20,
                          color: ProtonColors.textWeak,
                        )
                      ]),
                ),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      );
    });
  }

  String getTitle(BuildContext context) {
    if (viewModel.qRcodeType == QRcodeType.bitcoinAddress) {
      return S.of(context).bitcoin_address;
    }
    return "";
  }
}
