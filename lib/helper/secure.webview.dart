import 'package:webview_flutter/webview_flutter.dart';
import 'package:wallet/helper/logger.dart';

/// HTTPS host suffixes allowed for embedded Proton account flows.
const Set<String> protonAccountWebViewHosts = {
  'account.proton.me',
  'proton.me',
  'proton.black',
};

bool isAllowedWebViewHost(Uri uri, Set<String> allowedBaseHosts) {
  if (uri.scheme != 'https') {
    return false;
  }
  final host = uri.host.toLowerCase();
  for (final allowed in allowedBaseHosts) {
    if (host == allowed || host.endsWith('.$allowed')) {
      return true;
    }
  }
  return false;
}

bool isAllowedWebViewUrl(String url, Set<String> allowedBaseHosts) {
  final uri = Uri.tryParse(url);
  return uri != null && isAllowedWebViewHost(uri, allowedBaseHosts);
}

NavigationDecision secureNavigationDecision(
  String url,
  Set<String> allowedBaseHosts,
) {
  if (!isAllowedWebViewUrl(url, allowedBaseHosts)) {
    logger.w('Blocked embedded WebView navigation to: $url');
    return NavigationDecision.prevent;
  }
  return NavigationDecision.navigate;
}

void denyWebViewPermissions(WebViewPermissionRequest request) {
  request.deny();
}
