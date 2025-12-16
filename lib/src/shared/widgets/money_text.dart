import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class MoneyText extends StatelessWidget {
  MoneyText(this.amount, {super.key, this.style})
    : _formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

  final int amount;
  final TextStyle? style;
  final NumberFormat _formatter;

  @override
  Widget build(BuildContext context) {
    return Text(_formatter.format(amount), style: style);
  }
}
