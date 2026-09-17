import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/secure.webview.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Import for Android features.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_android/webview_flutter_android.dart';

class AccountDeletionView extends StatefulWidget {
  final String checkoutUrl;

  const AccountDeletionView({required this.checkoutUrl, super.key});

  @override
  State<AccountDeletionView> createState() => _AccountDeletionViewState();
}

class _AccountDeletionViewState extends State<AccountDeletionView> {
  WebViewController? controller;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    if (!isAllowedWebViewUrl(widget.checkoutUrl, protonAccountWebViewHosts)) {
      _loadError = 'Account deletion is only available on Proton domains.';
      return;
    }

    EasyLoading.show(maskType: EasyLoadingMaskType.black);

    controller = WebViewController(
      onPermissionRequest: denyWebViewPermissions,
    );
    if (controller!.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
    }

    // Match the WKScriptMessageHandler name
    var channelName = "iOS";
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Match the AndroidInterface name
      channelName = "AndroidInterface";
    }

    controller!
      ..clearCache()
      ..clearLocalStorage()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        channelName,
        onMessageReceived: (JavaScriptMessage message) {
          _handleMessage(message.message);
        },
      )
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            EasyLoading.dismiss();
          },
          onHttpError: (HttpResponseError error) {
            EasyLoading.dismiss();
          },
          onWebResourceError: (WebResourceError error) {
            EasyLoading.dismiss();
            _showErrorDialog("Failed to load page: ${error.description}");
          },
          onNavigationRequest: (NavigationRequest request) {
            return secureNavigationDecision(
              request.url,
              protonAccountWebViewHosts,
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  /// Handles messages from the WebView
  void _handleMessage(String message) {
    try {
      final parsedMessage = jsonDecode(message);
      final type = parsedMessage['type'];
      final payload = parsedMessage['payload'];
      switch (type) {
        case 'SUCCESS':
          _handleSuccess();
        case 'ERROR':
          final errorMessage = payload?['message'] ?? 'Unknown error';
          _handleError(errorMessage);
        case 'CLOSE':
          _handleClose();
        default:
          logger.i("Unknown message type: $type");
      }
    } catch (e) {
      _showErrorDialog("Failed to parse message: $message");
    }
  }

  /// Handle success scenario
  void _handleSuccess() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account deletion successful")),
    );
  }

  /// Handle error scenario
  void _handleError(String errorMessage) {
    _showErrorDialog(errorMessage);
  }

  /// Handle close action
  void _handleClose() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account deletion canceled by user")),
    );
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1,
      expand: false,
      builder: (context, scrollController) {
        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24.0)),
              color: ProtonColors.backgroundNorm,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const CustomHeader(
                    title: "Account Deletion",
                    buttonDirection: AxisDirection.right,
                  ),
                  Expanded(
                    child: _loadError != null
                        ? Center(child: Text(_loadError!))
                        : WebViewWidget(
                            controller: controller!,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
