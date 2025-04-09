import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/l10n/generated/locale.dart';

typedef ScanResultCallback = void Function(String result);

void showQRScanBottomSheet(
  BuildContext context,
  TextEditingController textEditingController,
  ScanResultCallback? resultCallback,
) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Container(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 50),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    S.of(context).scan_btc_address,
                    style:
                        ProtonStyles.body1Regular(color: ProtonColors.textNorm),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: QRScannerWidget(
                  textEditingController: textEditingController,
                  resultCallback: resultCallback,
                ),
              ),
            ])),
      );
    },
  );
}

class QRScannerWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  final ScanResultCallback? resultCallback;

  const QRScannerWidget(
      {required this.textEditingController, super.key, this.resultCallback});

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
    if (defaultTargetPlatform == TargetPlatform.android) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
        onTap: () async {
          await controller?.flipCamera();
        },
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flip_camera_ios_rounded,
                color: ProtonColors.protonBlue,
                size: 22,
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                S.of(context).flip_camera,
                style: ProtonStyles.body2Regular(
                  color: ProtonColors.protonBlue,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: defaultPadding),
      SizedBox(
        height: MediaQuery.of(context).size.height / 3,
        child: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
      ),
    ]);
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing) {
        setState(() {
          _isProcessing = true;
        });
        try {
          final scanResult = scanData.code ?? "";
          widget.resultCallback?.call(scanResult);
          if (mounted) {
            Navigator.of(context).pop();
          }
        } catch (e) {
          logger.e(e.toString());
          CommonHelper.showErrorDialog(e.toString());
          if (mounted) {
            Navigator.of(context).pop();
          }
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
