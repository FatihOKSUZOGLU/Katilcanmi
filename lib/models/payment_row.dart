import 'package:flutter/foundation.dart';

class PaymentRow {
  final String id = UniqueKey().toString();
  final int ay;
  final double taksit;
  final double ekOdeme;
  final double toplam;
  final double yuzde;

  PaymentRow({
    required this.ay,
    required this.taksit,
    required this.ekOdeme,
    required this.toplam,
    required this.yuzde,
  });
}
