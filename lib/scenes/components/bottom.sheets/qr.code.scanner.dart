import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';

void showQRScanBottomSheet(
  BuildContext context,
  TextEditingController textEditingController,
  VoidCallback? callback,
) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Container(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 50),
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    S.of(context).scan_btc_address,
                    style: FontManager.body2Regular(ProtonColors.textNorm),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: QRScannerWidget(
                  textEditingController: textEditingController,
                  callback: callback,
                ),
              ),
            ])),
      );
    },
  );
}

class QRScannerWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  final VoidCallback? callback;

  const QRScannerWidget(
      {required this.textEditingController, super.key, this.callback});

  @override
  QRScannerWidgetState createState() => QRScannerWidgetState();
}

class QRScannerWidgetState extends State<QRScannerWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing) {
        setState(() {
          _isProcessing = true;
        });
        try {
          widget.textEditingController.text = scanData.code ?? "";
          if (widget.callback != null) {
            Navigator.of(context).pop();
            widget.callback!();
          }
        } catch (e) {
          CommonHelper.showErrorDialog(e.toString());
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
