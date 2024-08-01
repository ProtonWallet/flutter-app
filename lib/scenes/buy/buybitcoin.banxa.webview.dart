import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Import for Android features.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_android/webview_flutter_android.dart';

/// Import for iOS features.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebViewExample extends StatefulWidget {
  final String checkoutUrl;
  const WebViewExample({required this.checkoutUrl, super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
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

    ///
    controller
      ..clearCache()
      ..clearLocalStorage()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            //
            EasyLoading.dismiss();
          },
          onHttpError: (HttpResponseError error) {
            //
            EasyLoading.dismiss();
          },
          onWebResourceError: (WebResourceError error) {
            //
            EasyLoading.dismiss();
          },
          onNavigationRequest: (NavigationRequest request) {
            // if (request.url.startsWith('proton.me')) {
            // return NavigationDecision.prevent;
            // }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString("""
<!DOCTYPE html>
<html lang="en">
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <meta http-equiv="Permissions-Policy" content="camera=(); microphone=()">
  <style>
    .iframe-container {
      position: relative;
      width: 100%;
      aspect-ratio: 16 / 9;
      height: 800px;
      overflow: hidden;
    }
    .iframe-container iframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border: 0;
    }
  </style>
</head>
<body>
  <div class="iframe-container">
    <iframe allow="camera *; microphone *" src="${widget.checkoutUrl}"></iframe>
  </div>
</body>
</html>
""");
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
              color: ProtonColors.backgroundProton,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const CustomHeader(
                    title: "Banxa",
                    buttonDirection: AxisDirection.left,
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
