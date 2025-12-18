import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../domain/payment_flow.dart';

class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({
    super.key,
    required this.orderId,
    required this.snapUrl,
    this.remaining = const [],
  });

  final String orderId;
  final String snapUrl;
  final List<PaymentStep> remaining;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _hasNavigated = false;
  bool _goHome = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (request) {
            if (_hasNavigated) return NavigationDecision.prevent;

            final url = request.url;
            if (_shouldNavigateAway(url)) {
              _hasNavigated = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                if (_goHome) {
                  context.go('/app/home');
                } else {
                  context.go(
                    '/app/tx/${widget.orderId}',
                    extra: widget.remaining,
                  );
                }
              });
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.snapUrl));
  }

  bool _shouldNavigateAway(String url) {
    final lower = url.toLowerCase();

    // Preferred: detect our configured callback redirects.
    // Backend uses FRONTEND_URL + /payment/{success|failed|pending}
    if (lower.contains('/payment/success')) {
      _goHome = true;
      return true;
    }
    if (lower.contains('/payment/failed') ||
        lower.contains('/payment/pending')) {
      _goHome = false;
      return true;
    }

    final isFinish = lower.contains('/finish') && !lower.contains('/unfinish');
    final isUnfinish = lower.contains('/unfinish');

    final isSuccess =
        isFinish &&
        lower.contains('status_code=200') &&
        (lower.contains('transaction_status=settlement') ||
            lower.contains('transaction_status=capture'));

    final isPending =
        isUnfinish &&
        lower.contains('status_code=201') &&
        lower.contains('transaction_status=pending');

    final isFailed =
        lower.contains('status_code=202') ||
        lower.contains('transaction_status=deny') ||
        lower.contains('transaction_status=cancel') ||
        lower.contains('transaction_status=expire') ||
        lower.contains('transaction_status=failure');

    final should = isSuccess || isPending || isFailed;
    if (should) {
      // If we only get Midtrans finish/unfinish URLs, keep existing behavior
      // (go to status) so user can verify.
      _goHome = false;
    }
    return should;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              context.go('/app/tx/${widget.orderId}', extra: widget.remaining),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: FilledButton.icon(
          onPressed: () =>
              context.go('/app/tx/${widget.orderId}', extra: widget.remaining),
          icon: const Icon(Icons.receipt_long_outlined),
          label: const Text('Cek status'),
        ),
      ),
    );
  }
}
