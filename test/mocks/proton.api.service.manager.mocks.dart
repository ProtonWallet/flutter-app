// Mocks generated by Mockito 5.4.4 from annotations
// in wallet/test/mocks/proton.api.service.manager.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i16;

import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i18;
import 'package:wallet/constants/env.dart' as _i3;
import 'package:wallet/helper/user.agent.dart' as _i4;
import 'package:wallet/managers/api.service.manager.dart' as _i15;
import 'package:wallet/managers/manager.dart' as _i19;
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart'
    as _i2;
import 'package:wallet/rust/api/api_service/discovery_content_client.dart'
    as _i14;
import 'package:wallet/rust/api/api_service/proton_api_service.dart' as _i6;
import 'package:wallet/rust/api/api_service/proton_email_addr_client.dart'
    as _i7;
import 'package:wallet/rust/api/api_service/proton_settings_client.dart'
    as _i10;
import 'package:wallet/rust/api/api_service/proton_users_client.dart' as _i8;
import 'package:wallet/rust/api/api_service/settings_client.dart' as _i11;
import 'package:wallet/rust/api/api_service/transaction_client.dart' as _i12;
import 'package:wallet/rust/api/api_service/unleash_client.dart' as _i13;
import 'package:wallet/rust/api/api_service/wallet_auth_store.dart' as _i5;
import 'package:wallet/rust/api/api_service/wallet_client.dart' as _i9;
import 'package:wallet/rust/proton_api/auth_credential.dart' as _i17;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeSecureStorageManager_0 extends _i1.SmartFake
    implements _i2.SecureStorageManager {
  _FakeSecureStorageManager_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeApiEnv_1 extends _i1.SmartFake implements _i3.ApiEnv {
  _FakeApiEnv_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUserAgent_2 extends _i1.SmartFake implements _i4.UserAgent {
  _FakeUserAgent_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeProtonWalletAuthStore_3 extends _i1.SmartFake
    implements _i5.ProtonWalletAuthStore {
  _FakeProtonWalletAuthStore_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeProtonApiService_4 extends _i1.SmartFake
    implements _i6.ProtonApiService {
  _FakeProtonApiService_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeProtonEmailAddressClient_5 extends _i1.SmartFake
    implements _i7.ProtonEmailAddressClient {
  _FakeProtonEmailAddressClient_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeProtonUsersClient_6 extends _i1.SmartFake
    implements _i8.ProtonUsersClient {
  _FakeProtonUsersClient_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWalletClient_7 extends _i1.SmartFake implements _i9.WalletClient {
  _FakeWalletClient_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeProtonSettingsClient_8 extends _i1.SmartFake
    implements _i10.ProtonSettingsClient {
  _FakeProtonSettingsClient_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSettingsClient_9 extends _i1.SmartFake
    implements _i11.SettingsClient {
  _FakeSettingsClient_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTransactionClient_10 extends _i1.SmartFake
    implements _i12.TransactionClient {
  _FakeTransactionClient_10(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFrbUnleashClient_11 extends _i1.SmartFake
    implements _i13.FrbUnleashClient {
  _FakeFrbUnleashClient_11(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDiscoveryContentClient_12 extends _i1.SmartFake
    implements _i14.DiscoveryContentClient {
  _FakeDiscoveryContentClient_12(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [ProtonApiServiceManager].
///
/// See the documentation for Mockito's code generation for more information.
class MockProtonApiServiceManager extends _i1.Mock
    implements _i15.ProtonApiServiceManager {
  MockProtonApiServiceManager() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.SecureStorageManager get storage => (super.noSuchMethod(
        Invocation.getter(#storage),
        returnValue: _FakeSecureStorageManager_0(
          this,
          Invocation.getter(#storage),
        ),
      ) as _i2.SecureStorageManager);

  @override
  _i3.ApiEnv get env => (super.noSuchMethod(
        Invocation.getter(#env),
        returnValue: _FakeApiEnv_1(
          this,
          Invocation.getter(#env),
        ),
      ) as _i3.ApiEnv);

  @override
  _i4.UserAgent get userAgent => (super.noSuchMethod(
        Invocation.getter(#userAgent),
        returnValue: _FakeUserAgent_2(
          this,
          Invocation.getter(#userAgent),
        ),
      ) as _i4.UserAgent);

  @override
  set userID(String? _userID) => super.noSuchMethod(
        Invocation.setter(
          #userID,
          _userID,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.ProtonWalletAuthStore get authStore => (super.noSuchMethod(
        Invocation.getter(#authStore),
        returnValue: _FakeProtonWalletAuthStore_3(
          this,
          Invocation.getter(#authStore),
        ),
      ) as _i5.ProtonWalletAuthStore);

  @override
  set authStore(_i5.ProtonWalletAuthStore? _authStore) => super.noSuchMethod(
        Invocation.setter(
          #authStore,
          _authStore,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i16.Future<String> callback(_i17.ChildSession? session) =>
      (super.noSuchMethod(
        Invocation.method(
          #callback,
          [session],
        ),
        returnValue: _i16.Future<String>.value(_i18.dummyValue<String>(
          this,
          Invocation.method(
            #callback,
            [session],
          ),
        )),
      ) as _i16.Future<String>);

  @override
  _i16.Future<void> saveSession(_i17.ChildSession? session) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveSession,
          [session],
        ),
        returnValue: _i16.Future<void>.value(),
        returnValueForMissingStub: _i16.Future<void>.value(),
      ) as _i16.Future<void>);

  @override
  _i16.Future<void> initalOldApiService() => (super.noSuchMethod(
        Invocation.method(
          #initalOldApiService,
          [],
        ),
        returnValue: _i16.Future<void>.value(),
        returnValueForMissingStub: _i16.Future<void>.value(),
      ) as _i16.Future<void>);

  @override
  _i6.ProtonApiService getApiService() => (super.noSuchMethod(
        Invocation.method(
          #getApiService,
          [],
        ),
        returnValue: _FakeProtonApiService_4(
          this,
          Invocation.method(
            #getApiService,
            [],
          ),
        ),
      ) as _i6.ProtonApiService);

  @override
  _i16.Future<void> dispose() => (super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValue: _i16.Future<void>.value(),
        returnValueForMissingStub: _i16.Future<void>.value(),
      ) as _i16.Future<void>);

  @override
  _i16.Future<void> init() => (super.noSuchMethod(
        Invocation.method(
          #init,
          [],
        ),
        returnValue: _i16.Future<void>.value(),
        returnValueForMissingStub: _i16.Future<void>.value(),
      ) as _i16.Future<void>);

  @override
  _i16.Future<void> logout() => (super.noSuchMethod(
        Invocation.method(
          #logout,
          [],
        ),
        returnValue: _i16.Future<void>.value(),
        returnValueForMissingStub: _i16.Future<void>.value(),
      ) as _i16.Future<void>);

  @override
  _i16.Future<void> login(String? userID) => (super.noSuchMethod(
        Invocation.method(
          #login,
          [userID],
        ),
        returnValue: _i16.Future<void>.value(),
        returnValueForMissingStub: _i16.Future<void>.value(),
      ) as _i16.Future<void>);

  @override
  _i16.Future<void> reload() => (super.noSuchMethod(
        Invocation.method(
          #reload,
          [],
        ),
        returnValue: _i16.Future<void>.value(),
        returnValueForMissingStub: _i16.Future<void>.value(),
      ) as _i16.Future<void>);

  @override
  _i7.ProtonEmailAddressClient getProtonEmailAddrApiClient() =>
      (super.noSuchMethod(
        Invocation.method(
          #getProtonEmailAddrApiClient,
          [],
        ),
        returnValue: _FakeProtonEmailAddressClient_5(
          this,
          Invocation.method(
            #getProtonEmailAddrApiClient,
            [],
          ),
        ),
      ) as _i7.ProtonEmailAddressClient);

  @override
  _i8.ProtonUsersClient getProtonUsersApiClient() => (super.noSuchMethod(
        Invocation.method(
          #getProtonUsersApiClient,
          [],
        ),
        returnValue: _FakeProtonUsersClient_6(
          this,
          Invocation.method(
            #getProtonUsersApiClient,
            [],
          ),
        ),
      ) as _i8.ProtonUsersClient);

  @override
  _i9.WalletClient getWalletClient() => (super.noSuchMethod(
        Invocation.method(
          #getWalletClient,
          [],
        ),
        returnValue: _FakeWalletClient_7(
          this,
          Invocation.method(
            #getWalletClient,
            [],
          ),
        ),
      ) as _i9.WalletClient);

  @override
  _i10.ProtonSettingsClient getProtonSettingsApiClient() => (super.noSuchMethod(
        Invocation.method(
          #getProtonSettingsApiClient,
          [],
        ),
        returnValue: _FakeProtonSettingsClient_8(
          this,
          Invocation.method(
            #getProtonSettingsApiClient,
            [],
          ),
        ),
      ) as _i10.ProtonSettingsClient);

  @override
  _i11.SettingsClient getSettingsClient() => (super.noSuchMethod(
        Invocation.method(
          #getSettingsClient,
          [],
        ),
        returnValue: _FakeSettingsClient_9(
          this,
          Invocation.method(
            #getSettingsClient,
            [],
          ),
        ),
      ) as _i11.SettingsClient);

  @override
  _i12.TransactionClient getTransactionClient() => (super.noSuchMethod(
        Invocation.method(
          #getTransactionClient,
          [],
        ),
        returnValue: _FakeTransactionClient_10(
          this,
          Invocation.method(
            #getTransactionClient,
            [],
          ),
        ),
      ) as _i12.TransactionClient);

  @override
  _i13.FrbUnleashClient getUnleashClient() => (super.noSuchMethod(
        Invocation.method(
          #getUnleashClient,
          [],
        ),
        returnValue: _FakeFrbUnleashClient_11(
          this,
          Invocation.method(
            #getUnleashClient,
            [],
          ),
        ),
      ) as _i13.FrbUnleashClient);

  @override
  _i14.DiscoveryContentClient getDiscoveryContentClient() =>
      (super.noSuchMethod(
        Invocation.method(
          #getDiscoveryContentClient,
          [],
        ),
        returnValue: _FakeDiscoveryContentClient_12(
          this,
          Invocation.method(
            #getDiscoveryContentClient,
            [],
          ),
        ),
      ) as _i14.DiscoveryContentClient);

  @override
  _i19.Priority getPriority() => (super.noSuchMethod(
        Invocation.method(
          #getPriority,
          [],
        ),
        returnValue: _i19.Priority.level1,
      ) as _i19.Priority);
}
