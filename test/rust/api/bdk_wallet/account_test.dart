import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bdk functions', () {
    ///
    test('test_peek_reset_address', () async {
//         let test_wpkh = "wpkh(tprv8hwWMmPE4BVNxGdVt3HhEERZhondQvodUY7Ajyseyhudr4WabJqWKWLr4Wi2r26CDaNCQhhxEftEaNzz7dPGhWuKFU4VULesmhEfZYyBXdE/0/*)";
//         let descriptor = BdkDescriptor::new(test_wpkh.to_string(), Network::Regtest).unwrap();
//         let change_descriptor = BdkDescriptor::new(
//             test_wpkh.to_string().replace("/0/*", "/1/*"),
//             Network::Regtest,
//         )
//         .unwrap();

//         let wallet_id = Wallet::new_wallet(
//             descriptor.as_string_private(),
//             Some(change_descriptor.as_string_private()),
//             Network::Regtest,
//             DatabaseConfig::Memory,
//         )
//         .unwrap();
//         let wallet = Wallet::retrieve_wallet(wallet_id);
//         assert_eq!(
//             wallet
//                 .get_address(AddressIndex::Peek { index: 2 })
//                 .await
//                 .unwrap()
//                 .address,
//             "bcrt1q5g0mq6dkmwzvxscqwgc932jhgcxuqqkjv09tkj"
//         );

//         assert_eq!(
//             wallet
//                 .get_address(AddressIndex::Peek { index: 1 })
//                 .await
//                 .unwrap()
//                 .address,
//             "bcrt1q0xs7dau8af22rspp4klya4f7lhggcnqfun2y3a"
//         );

//         // new index still 0
//         assert_eq!(
//             wallet.get_address(AddressIndex::New).await.unwrap().address,
//             "bcrt1qqjn9gky9mkrm3c28e5e87t5akd3twg6xezp0tv"
//         );

//         // new index now 1
//         assert_eq!(
//             wallet.get_address(AddressIndex::New).await.unwrap().address,
//             "bcrt1q0xs7dau8af22rspp4klya4f7lhggcnqfun2y3a"
//         );

//         // new index now 2
//         assert_eq!(
//             wallet.get_address(AddressIndex::New).await.unwrap().address,
//             "bcrt1q5g0mq6dkmwzvxscqwgc932jhgcxuqqkjv09tkj"
//         );

//         // peek index 1
//         assert_eq!(
//             wallet
//                 .get_address(AddressIndex::Peek { index: 1 })
//                 .await
//                 .unwrap()
//                 .address,
//             "bcrt1q0xs7dau8af22rspp4klya4f7lhggcnqfun2y3a"
//         );

//         // reset to index 0
//         assert_eq!(
//             wallet
//                 .get_address(AddressIndex::Reset { index: 0 })
//                 .await
//                 .unwrap()
//                 .address,
//             "bcrt1qqjn9gky9mkrm3c28e5e87t5akd3twg6xezp0tv"
//         );

//         // new index 1 again
//         assert_eq!(
//             wallet.get_address(AddressIndex::New).await.unwrap().address,
//             "bcrt1q0xs7dau8af22rspp4klya4f7lhggcnqfun2y3a"
//         );
    });

    test('test_get_address', () async {
      //         let test_wpkh = "wpkh(tprv8hwWMmPE4BVNxGdVt3HhEERZhondQvodUY7Ajyseyhudr4WabJqWKWLr4Wi2r26CDaNCQhhxEftEaNzz7dPGhWuKFU4VULesmhEfZYyBXdE/0/*)";
//         let descriptor = BdkDescriptor::new(test_wpkh.to_string(), Network::Regtest).unwrap();
//         let change_descriptor = BdkDescriptor::new(
//             test_wpkh.to_string().replace("/0/*", "/1/*"),
//             Network::Regtest,
//         )
//         .unwrap();

//         let wallet_id = Wallet::new_wallet(
//             descriptor.as_string_private(),
//             Some(change_descriptor.as_string_private()),
//             Network::Regtest,
//             DatabaseConfig::Memory,
//         )
//         .unwrap();
//         let wallet = Wallet::retrieve_wallet(wallet_id);

//         assert_eq!(
//             wallet.get_address(AddressIndex::New).await.unwrap().address,
//             "bcrt1qqjn9gky9mkrm3c28e5e87t5akd3twg6xezp0tv"
//         );

//         assert_eq!(
//             wallet.get_address(AddressIndex::New).await.unwrap().address,
//             "bcrt1q0xs7dau8af22rspp4klya4f7lhggcnqfun2y3a"
//         );

//         assert_eq!(
//             wallet
//                 .get_address(AddressIndex::LastUnused)
//                 .await
//                 .unwrap()
//                 .address,
//             "bcrt1q0xs7dau8af22rspp4klya4f7lhggcnqfun2y3a"
//         );

//         assert_eq!(
//             wallet
//                 .get_internal_address(AddressIndex::New)
//                 .await
//                 .unwrap()
//                 .address,
//             "bcrt1qpmz73cyx00r4a5dea469j40ax6d6kqyd67nnpj"
//         );

//         assert_eq!(
//             wallet
//                 .get_internal_address(AddressIndex::New)
//                 .await
//                 .unwrap()
//                 .address,
//             "bcrt1qaux734vuhykww9632v8cmdnk7z2mw5lsf74v6k"
//         );

//         assert_eq!(
//             wallet
//                 .get_internal_address(AddressIndex::LastUnused)
//                 .await
//                 .unwrap()
//                 .address,
//             "bcrt1qaux734vuhykww9632v8cmdnk7z2mw5lsf74v6k"
//         );
    });

    ///
  });
}
