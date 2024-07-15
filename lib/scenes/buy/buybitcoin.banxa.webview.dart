import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

    EasyLoading.show(
        status: "Loading Banxa..", maskType: EasyLoadingMaskType.black);

    // #docregion webview_controller
    controller = WebViewController()
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
  <style>
    .iframe-container {
      position: relative;
      width: 100%;
      padding-bottom: 56.25%; /* 16:9 aspect ratio */
      height: 400px;
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
    <iframe src="${widget.checkoutUrl}""></iframe>
  </div>
</body>
</html>
""");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banxa')),
      body: SafeArea(
        child: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}
