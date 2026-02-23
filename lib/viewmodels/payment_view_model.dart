import 'package:flutter/material.dart';
import 'package:katilcanmi_app/enums/payment_type.dart';
import 'package:katilcanmi_app/models/payment_row.dart';

class PaymentViewModel extends ChangeNotifier {
  double katilimOrani = 7; // yüzde olarak (7%)
  int katilimTaksitSayisi = 4;

  List<PaymentRow> rows = [];
  String ilkTaksit = "";
  String suggestedPesinat = "";
  String validationResult = "";
  PaymentType paymentType = PaymentType.artan;

  void calculate({
    required int teslimAy,
    required int toplamAy,
    required double pesinat,
    required double anaPara,
  }) {
    rows.clear();

    double value = isValid(
      a: teslimAy.toDouble(),
      x: toplamAy.toDouble(),
      y: pesinat,
      z: anaPara,
    );

    validationResult = value.toStringAsFixed(4);

    if (value < 0) {
      notifyListeners();
      return;
    }

    suggestPesinat(teslimAy, toplamAy, anaPara);

    double ilkAylik = (anaPara * 0.40 - pesinat) / teslimAy;

    if (paymentType == PaymentType.sabit) {
      ilkTaksit = ((anaPara - pesinat) / toplamAy).toStringAsFixed(2);
    } else {
      ilkTaksit = ilkAylik.toStringAsFixed(2);
    }

    double katilimToplam = anaPara * (katilimOrani / 100);
    double aylikKatilim = katilimToplam / katilimTaksitSayisi;

    double kalanToplam = anaPara - pesinat - ilkAylik * teslimAy;

    int weightSum = calculateWeightSum(teslimAy, toplamAy);

    double ekBirim =
        (kalanToplam - ilkAylik * (toplamAy - teslimAy)) / weightSum;

    double yuzdeToplam = 0;

    for (int ay = 1; ay <= toplamAy; ay++) {
      double taksit;

      if (paymentType == PaymentType.sabit) {
        taksit = (anaPara - pesinat) / toplamAy;
      } else {
        if (ay <= teslimAy) {
          taksit = ilkAylik;
        } else {
          int carpan = calculateBlockWeight(teslimAy, ay);
          taksit = ilkAylik + ekBirim * carpan;
        }
      }

      double ek = calculateExtraPayment(ay, pesinat, aylikKatilim);

      yuzdeToplam += (ay == 1) ? (pesinat + taksit) : taksit;
      double yuzde = (yuzdeToplam / anaPara) * 100 > 100
          ? 100
          : (yuzdeToplam / anaPara) * 100;

      rows.add(
        PaymentRow(
          ay: ay,
          taksit: taksit,
          ekOdeme: ek,
          toplam: taksit + ek,
          yuzde: yuzde,
        ),
      );
    }

    notifyListeners();
  }

  double isValid({
    required double a,
    required double x,
    required double y,
    required double z,
  }) {
    if (x == 0 || z == y) return -1;

    double denominator = x * (z - y);
    if (denominator == 0) return -1;

    return (a * z) / denominator;
  }

  int calculateBlockWeight(int teslimAy, int ay) {
    return ((ay - (teslimAy + 1)) ~/ teslimAy) + 1;
  }

  int calculateWeightSum(int teslimAy, int toplamAy) {
    int sum = 0;
    for (int ay = teslimAy + 1; ay <= toplamAy; ay++) {
      sum += calculateBlockWeight(teslimAy, ay);
    }
    return sum;
  }

  double calculateExtraPayment(int ay, double pesinat, double aylikKatilim) {
    if (ay == 1) {
      return pesinat + aylikKatilim;
    }

    if (ay <= katilimTaksitSayisi) {
      return aylikKatilim;
    }

    return 0;
  }

  void suggestPesinat(int a, int x, double z) {
    double target = 0.40;
    double y = z * (target * x - a) / (target * x);
    suggestedPesinat = y.toStringAsFixed(2);
  }
}
