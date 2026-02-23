import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/payment_view_model.dart';
import '../enums/payment_type.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final teslimController = TextEditingController(text: "8");
  final toplamController = TextEditingController(text: "33");
  final pesinatController = TextEditingController(text: "1970000");
  final anaParaController = TextEditingController(text: "5000000");
  final katilimController = TextEditingController(text: "7");
  int selectedKatilimTaksit = 4;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Artan Taksitli Ödeme"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildField("Katılım Oranı (%)", katilimController),

            const SizedBox(height: 8),

            DropdownButtonFormField<int>(
              value: selectedKatilimTaksit,
              decoration: const InputDecoration(
                labelText: "Katılım Kaç Taksit?",
                border: OutlineInputBorder(),
              ),
              items: List.generate(12, (index) => index + 1)
                  .map(
                    (e) => DropdownMenuItem(value: e, child: Text("$e Taksit")),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedKatilimTaksit = val!;
                });
              },
            ),

            // Payment Type Picker
            const SizedBox(height: 12),
            DropdownButtonFormField<PaymentType>(
              value: vm.paymentType,
              decoration: const InputDecoration(
                labelText: "Taksit Türü",
                border: OutlineInputBorder(),
              ),
              items: PaymentType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type == PaymentType.artan ? "Artan" : "Sabit"),
                );
              }).toList(),
              onChanged: (val) {
                vm.paymentType = val!;
                vm.notifyListeners();
              },
            ),

            const SizedBox(height: 12),

            buildField("Teslim Ödeme", teslimController),
            buildField("Toplam Ödeme", toplamController),
            buildField("Peşinat", pesinatController),
            buildField("Kredi Tutarı", anaParaController),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                vm.katilimOrani = double.tryParse(katilimController.text) ?? 0;

                vm.katilimTaksitSayisi = selectedKatilimTaksit;

                vm.calculate(
                  teslimAy: int.tryParse(teslimController.text) ?? 0,
                  toplamAy: int.tryParse(toplamController.text) ?? 0,
                  pesinat: double.tryParse(pesinatController.text) ?? 0,
                  anaPara: double.tryParse(anaParaController.text) ?? 0,
                );
              },
              child: const Text("Hesapla"),
            ),

            const SizedBox(height: 10),

            // Sonuç Alanı
            Builder(
              builder: (_) {
                final value = double.tryParse(vm.validationResult) ?? 0;

                final isValid = value >= 0.40;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isValid
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isValid ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    "Validation: ${vm.validationResult}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isValid ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            ),
            Text("Önerilen Peşinat: ${vm.suggestedPesinat}"),
            Text("İlk Taksit: ${vm.ilkTaksit}"),

            const Divider(),

            // Liste
            Expanded(
              child: vm.rows.isEmpty
                  ? const Center(child: Text("Henüz hesaplama yapılmadı"))
                  : ListView.builder(
                      itemCount: vm.rows.length,
                      itemBuilder: (_, index) {
                        final row = vm.rows[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ay ${row.ay}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Taksit: ${row.taksit.toStringAsFixed(2)}",
                                ),
                                Text(
                                  "Ek Ödeme: ${row.ekOdeme.toStringAsFixed(2)}",
                                ),
                                Text(
                                  "Toplam: ${row.toplam.toStringAsFixed(2)}",
                                ),
                                Text(
                                  "Tamamlanan: %${row.yuzde.toStringAsFixed(1)}",
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    teslimController.dispose();
    toplamController.dispose();
    pesinatController.dispose();
    anaParaController.dispose();
    katilimController.dispose();
    super.dispose();
  }
}
