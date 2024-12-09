import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/constants/env.dart';

import '../helper.dart';

void main() {
  testUnit('Equality of ApiEnv.prod instances', () {
    const env1 = ApiEnv.prod();
    const env2 = ApiEnv.prod();
    expect(env1, equals(env2));
    expect(env1.hashCode, equals(env2.hashCode));
  });

  testUnit('Equality of ApiEnv.atlas with the same custom value', () {
    final env1 = ApiEnv.atlas("testEnv");
    final env2 = ApiEnv.atlas("testEnv");
    expect(env1, equals(env2));
    expect(env1.hashCode, equals(env2.hashCode));
  });

  testUnit('Inequality of ApiEnv.atlas with different custom values', () {
    final env1 = ApiEnv.atlas("testEnv1");
    final env2 = ApiEnv.atlas("testEnv2");
    expect(env1, isNot(equals(env2)));
    expect(env1.hashCode, isNot(equals(env2.hashCode)));
  });

  testUnit('Inequality between ApiEnv.prod and ApiEnv.atlas', () {
    const prodEnv = ApiEnv.prod();
    final atlasEnv = ApiEnv.atlas("testEnv");
    expect(prodEnv, isNot(equals(atlasEnv)));
    expect(prodEnv.hashCode, isNot(equals(atlasEnv.hashCode)));
  });

  testUnit('toString representation for ApiEnv.prod', () {
    const env = ApiEnv.prod();
    expect(env.toString(), equals("prod"));
  });

  testUnit('toString representation for ApiEnv.atlas with custom value', () {
    final env = ApiEnv.atlas("testEnv");
    expect(env.toString(), equals("atlas:testEnv"));
  });

  testUnit('toString representation for ApiEnv.atlas without custom value', () {
    final env = ApiEnv.atlas(null);
    expect(env.toString(), equals("atlas"));
  });

  testUnit('apiPath for ApiEnv.prod', () {
    const env = ApiEnv.prod();
    expect(env.apiPath, equals("https://wallet.proton.me/api"));
  });

  testUnit('apiPath for ApiEnv.atlas with custom value', () {
    final env = ApiEnv.atlas("testEnv");
    expect(env.apiPath, equals("https://testEnv.proton.black/api"));
  });

  testUnit('apiPath for ApiEnv.atlas without custom value', () {
    final env = ApiEnv.atlas(null);
    expect(env.apiPath, equals("https://.proton.black/api"));
  });

  testUnit('Predefined payments ApiEnv instance', () {
    final expectedEnv = ApiEnv.atlas("payments");
    expect(payments, equals(expectedEnv));
    expect(payments.hashCode, equals(expectedEnv.hashCode));
    expect(payments.toString(), equals("atlas:payments"));
    expect(payments.apiPath, equals("https://payments.proton.black/api"));
  });
}
