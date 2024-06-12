// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    // #docregion webview_controller
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(
          '<iframe src="https://proton.banxa-sandbox.com/?orderType?=buy&coinType=BTC&fiatType=USD&fiatAmount=500&blockchain=BTC&backgroundColor=ffffff&primaryColor=e014c2&secondaryColor=4287f5&textColor=000000&theme=light&walletAddress=0xf831d1781287e499bd546cc4831cf783af84b8e3" style="border:0; width: 100%; min-height: 80vh;"></iframe>');
// https://proton.banxa-sandbox.com/?coinType=ETH&fiatType=USD&fiatAmount=500&blockchain=ETH&backgroundColor=ffffff&primaryColor=e014c2&secondaryColor=4287f5&textColor=000000&theme=light&walletAddress=0xf831d1781287e499bd546cc4831cf783af84b8e3
// https://proton.banxa-sandbox.com/portal?expires=xxx&oid=xxx&signature=xxx
  }

  // #docregion webview_widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pay with Banxa')),
      body: WebViewWidget(controller: controller),
    );
  }
  // #enddocregion webview_widget
}
