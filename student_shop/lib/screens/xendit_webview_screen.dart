import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class XenditWebViewScreen extends StatefulWidget {
  const XenditWebViewScreen({super.key, required this.invoiceUrl});

  final Uri invoiceUrl;

  @override
  State<XenditWebViewScreen> createState() => _XenditWebViewScreenState();
}

class _XenditWebViewScreenState extends State<XenditWebViewScreen> {
  WebViewController? _controller;
  bool _isLoadingPage = true;
  String? _errorMessage;

  bool get _supportsWebView =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  void initState() {
    super.initState();

    if (_supportsWebView) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (mounted) setState(() => _isLoadingPage = true);
            },
            onPageFinished: (_) {
              if (mounted) setState(() => _isLoadingPage = false);
            },
            onWebResourceError: (error) {
              if (error.isForMainFrame == true && mounted) {
                setState(() {
                  _isLoadingPage = false;
                  _errorMessage = error.description;
                });
              }
            },
          ),
        )
        ..loadRequest(widget.invoiceUrl);
    } else {
      _isLoadingPage = false;
    }
  }

  Future<void> _openInBrowser() async {
    try {
      final didLaunch = await launchUrl(
        widget.invoiceUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!didLaunch) {
        throw StateError('No browser could open the Xendit checkout link.');
      }
      if (mounted) setState(() => _errorMessage = null);
    } on Exception catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xendit Checkout'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check),
            label: const Text('Done'),
          ),
        ],
      ),
      body: _supportsWebView
          ? Stack(
              children: [
                if (_controller != null)
                  WebViewWidget(controller: _controller!),
                if (_isLoadingPage)
                  const Center(child: CircularProgressIndicator()),
                if (_errorMessage != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Material(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(_errorMessage!),
                      ),
                    ),
                  ),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.open_in_browser,
                      size: 64,
                      color: Colors.indigo,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Open Xendit checkout in your browser, complete the '
                      'payment, then return here and tap Done.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _openInBrowser,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open checkout'),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
