// const SizedBox(height = 20.0),
//                     Center(
//                       child = ElevatedButton(
//                         onPressed: () {
//                           viewModel.move(NavID.rampExternal);
//                         },
//                         child: const Text("Present Ramp"),
//                       ),
//                     ),
//                     Row(
//                       mainAxisAlignment = MainAxisAlignment.center,
//                       children = [
//                         const Text(
//                           'Receive to BTC address',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                         const SizedBox(width: 5.0),
//                         TextButton(
//                           onPressed: () {},
//                           style: TextButton.styleFrom(
//                               foregroundColor: Colors.blue),
//                           child: const Text('Change'),
//                         ),
//                       ],
//                     ),
//                     BlocBuilder<BuyBitcoinBloc, BuyBitcoinState>(
//                       builder = (context, state) {
//                         return Column(
//                           children: [
//                             if (state.isAddressLoaded)
//                               const Text("Address Loaded"),
//                             if (state.isCountryLoaded)
//                               const Text("Country Loaded"),
//                             if (!state.isAddressLoaded ||
//                                 !state.isCountryLoaded)
//                               const CircularProgressIndicator(),
//                             if (!state.isAddressLoaded)
//                               ElevatedButton(
//                                 onPressed: () => {},
//                                 child: const Text('Load State A'),
//                               ),
//                             if (!state.isCountryLoaded)
//                               ElevatedButton(
//                                 onPressed: () => {},
//                                 child: const Text('Load State B'),
//                               ),
//                           ],
//                         );
//                       },
//                     ),
//                     Row(
//                       mainAxisAlignment = MainAxisAlignment.center,
//                       children = [
//                         DropdownButton<String>(
//                           value: 'USD', //selectedCurrency,
//                           onChanged: (String? newValue) {
//                             // setState(() {
//                             //   selectedCurrency = newValue!;
//                             // });
//                           },
//                           items: <String>['USD', 'EUR', 'GBP', 'JPY']
//                               .map<DropdownMenuItem<String>>((String value) {
//                             return DropdownMenuItem<String>(
//                               value: value,
//                               child: Text(value),
//                             );
//                           }).toList(),
//                         ),
//                         const SizedBox(width: 20.0),
//                         DropdownButton<String>(
//                           value: 'USA', // selectedCountry,
//                           onChanged: (String? newValue) {
//                             // setState(() {
//                             //   selectedCountry = newValue!;
//                             // });
//                           },
//                           items: <String>['USA', 'UK', 'Germany', 'Japan']
//                               .map<DropdownMenuItem<String>>((String value) {
//                             return DropdownMenuItem<String>(
//                               value: value,
//                               child: Row(
//                                 children: [
//                                   // Image.asset(
//                                   //   'assets/flags/${value.toLowerCase()}.png',
//                                   //   width: 24,
//                                   //   height: 24,
//                                   // ),
//                                   const SizedBox(width: 10.0),
//                                   Text(value),
//                                 ],
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ],
//                     ),







// Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration:
//                             const BoxDecoration(color: Color(0xFFE6E8EC)),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Container(
//                               width: 40,
//                               height: 40,
//                               decoration: ShapeDecoration(
//                                 color: const Color(0xFFF3F5F6),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(200),
//                                 ),
//                               ),
//                               child: const Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   SizedBox(
//                                     width: 20,
//                                     height: 20,
//                                     child: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         SizedBox(
//                                           width: 14.42,
//                                           height: 17.78,
//                                           child: FlutterLogo(),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             const Expanded(
//                               child: SizedBox(
//                                 child: Text(
//                                   'Apple pay',
//                                   style: TextStyle(
//                                     color: Color(0xFF0C0C14),
//                                     fontSize: 14,
//                                     fontFamily: 'Inter',
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             const SizedBox(
//                               width: 90,
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   SizedBox(
//                                     child: Text(
//                                       'Take minutes',
//                                       textAlign: TextAlign.right,
//                                       style: TextStyle(
//                                         color: Color(0xFF191C32),
//                                         fontSize: 14,
//                                         fontFamily: 'Inter',
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(16),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Container(
//                               width: 40,
//                               height: 40,
//                               decoration: ShapeDecoration(
//                                 color: const Color(0xFFF3F5F6),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(200),
//                                 ),
//                               ),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Container(
//                                     width: 16,
//                                     height: 16,
//                                     clipBehavior: Clip.antiAlias,
//                                     decoration: const BoxDecoration(),
//                                     child: const FlutterLogo(),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             const Expanded(
//                               child: SizedBox(
//                                 child: Text(
//                                   'Bank transfer',
//                                   style: TextStyle(
//                                     color: Color(0xFF0C0C14),
//                                     fontSize: 14,
//                                     fontFamily: 'Inter',
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             const SizedBox(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   SizedBox(
//                                     child: Text(
//                                       'Up to 2 business days',
//                                       textAlign: TextAlign.right,
//                                       style: TextStyle(
//                                         color: Color(0xFF191C32),
//                                         fontSize: 14,
//                                         fontFamily: 'Inter',
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),