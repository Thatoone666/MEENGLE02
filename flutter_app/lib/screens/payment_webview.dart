import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class PaymentWebView extends StatefulWidget {
  final String initialUrl;
  final String successUrlContains;
  final String cancelUrlContains;
  final String? htmlForm; // optional HTML form to POST and auto-submit
  const PaymentWebView(
      {super.key,
      required this.initialUrl,
      this.htmlForm,
      this.successUrlContains = 'payment-success',
      this.cancelUrlContains = 'payment-cancel'});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  bool _loading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(onPageStarted: (url) {
        if (url.contains(widget.successUrlContains)) {
          Navigator.of(context).pop({'status': 'success', 'url': url});
        } else if (url.contains(widget.cancelUrlContains)) {
          Navigator.of(context).pop({'status': 'cancel', 'url': url});
        }
      }, onPageFinished: (url) {
        setState(() => _loading = false);
      }));

    if (widget.htmlForm != null && widget.htmlForm!.isNotEmpty) {
      final content = Uri.dataFromString(widget.htmlForm!,
          mimeType: 'text/html', encoding: utf8);
      _controller.loadRequest(content);
    } else {
      _controller.loadRequest(Uri.parse(widget.initialUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
