import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Import for Android features.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_android/webview_flutter_android.dart';

/// Import for iOS features.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class AccountDeletionView extends StatefulWidget {
  final String checkoutUrl;

  const AccountDeletionView({required this.checkoutUrl, super.key});

  @override
  State<AccountDeletionView> createState() => _AccountDeletionViewState();
}

class _AccountDeletionViewState extends State<AccountDeletionView> {
  late final WebViewController controller;
  @override
  void initState() {
    super.initState();
    EasyLoading.show(maskType: EasyLoadingMaskType.black);

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    controller = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: (request) {
        request.grant();
      },
    );
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    // Match the WKScriptMessageHandler name
    var channelName = "iOS";
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Match the AndroidInterface name
      channelName = "AndroidInterface";
    }

    ///
    controller
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
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            //
          },
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
            return NavigationDecision.navigate;
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
                    child: WebViewWidget(
                      controller: controller,
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
