import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';

class DropdownButtonV3 extends StatefulWidget {
  const DropdownButtonV3({super.key});
  @override
  CurrencyInputExampleState createState() => CurrencyInputExampleState();
}

class CurrencyInputExampleState extends State<DropdownButtonV3> {
  // final _formKey = GlobalKey<FormState>();
  // final _moneyController = TextEditingController();
  // final String _selectedRecommendation = 'Ramp';

  // final FiatCurrencyInfo _selectedCountry = FiatCurrencyInfo(
  // name: 'Swiss Franc', symbol: 'chf', sign: 'Fr', cents: 100);

  // final Map<FiatCurrency, FiatCurrencyInfo> _countries = fiatCurrency2Info;
  // final List<String> _recommendations = ['Ramp', 'Option 2', 'Option 3'];

  @override
  void initState() {
    super.initState();
    // _countries = FiatCurrency.values.map((e) => e.toString()).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              inputFormatters: [
                CurrencyTextInputFormatter.currency(
                  locale: 'ko',
                  decimalDigits: 0,
                  symbol: 'KRW(원)',
                ),
              ],
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 8),
          // DropdownButton<FiatCurrencyInfo>(
          //   value: _selectedCountry,
          //   onChanged: (FiatCurrencyInfo? newValue) {
          //     setState(() {
          //       _selectedCountry = newValue!;
          //       // _updateMoneyController(); // Update the formatting when the country changes
          //     });
          //   },
          //   items: fiatCurrency2Info.values
          //       .map<DropdownMenuItem<FiatCurrencyInfo>>(
          //           (FiatCurrencyInfo value) {
          //     return DropdownMenuItem<FiatCurrencyInfo>(
          //       value: value,
          //       child: Row(
          //         children: [
          //           const Icon(Icons.attach_money),
          //           const SizedBox(width: 4),
          //           Text(value.toString()),
          //         ],
          //       ),
          //     );
          //   }).toList(),
          // ),
        ],
      ),
    );

    // return const Text("123123123213");
    // return Padding(
    //   padding: const EdgeInsets.all(16.0),
    //   child: Form(
    //     key: _formKey,
    //     child: Row(
    //       children: [
    //         Row(
    //           children: [
    //             Expanded(
    //               child: TextFormField(
    //                 controller: _moneyController,
    //                 decoration: const InputDecoration(labelText: 'You pay'),
    //                 keyboardType: TextInputType.number,
    //                 inputFormatters: [
    //                   FilteringTextInputFormatter.allow(
    //                       RegExp(r'^\d+\.?\d{0,2}')),
    //                 ],
    //                 validator: (value) {
    //                   if (value == null || value.isEmpty) {
    //                     return 'Please enter an amount';
    //                   }
    //                   if (double.tryParse(value) == null) {
    //                     return 'Please enter a valid number';
    //                   }
    //                   return null;
    //                 },
    //               ),
    //             ),
    //             const SizedBox(width: 8),
    //             DropdownButton<String>(
    //               value: _selectedCountry,
    //               onChanged: (String? newValue) {
    //                 setState(() {
    //                   _selectedCountry = newValue!;
    //                   _updateMoneyController(); // Update the formatting when the country changes
    //                 });
    //               },
    //               items:
    //                   _countries.map<DropdownMenuItem<String>>((String value) {

    //           ],
    //         ),
    //         const SizedBox(height: 20),
    //         Row(
    //           children: [
    //             Expanded(
    //               child: DropdownButtonFormField<String>(
    //                 value: _selectedRecommendation,
    //                 decoration: const InputDecoration(labelText: 'Recommended'),
    //                 onChanged: (String? newValue) {
    //                   setState(() {
    //                     _selectedRecommendation = newValue!;
    //                   });
    //                 },
    //                 items: _recommendations
    //                     .map<DropdownMenuItem<String>>((String value) {
    //                   return DropdownMenuItem<String>(
    //                     value: value,
    //                     child: Text(value),
    //                   );
    //                 }).toList(),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
