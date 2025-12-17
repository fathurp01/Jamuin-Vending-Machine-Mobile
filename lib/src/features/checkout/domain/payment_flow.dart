class PaymentStep {
  const PaymentStep({required this.orderId, required this.snapUrl});

  final String orderId;
  final String snapUrl;
}

class PaymentFlowArgs {
  const PaymentFlowArgs({required this.snapUrl, this.remaining = const []});

  final String snapUrl;
  final List<PaymentStep> remaining;
}
