// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myApiProvider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categories)
const categoriesProvider = CategoriesProvider._();

final class CategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  const CategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    return categories(ref);
  }
}

String _$categoriesHash() => r'0c6b9c558451e79adc306b4e99b8c9b87eb6583a';

@ProviderFor(items)
const itemsProvider = ItemsProvider._();

final class ItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  const ItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemsHash();

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    return items(ref);
  }
}

String _$itemsHash() => r'cdc3f4926a2e28d9dc7af99d33cbc49f1e4d6ca6';

@ProviderFor(login)
const loginProvider = LoginFamily._();

final class LoginProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  const LoginProvider._({
    required LoginFamily super.from,
    required ({String email, String password}) super.argument,
  }) : super(
         retry: null,
         name: r'loginProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$loginHash();

  @override
  String toString() {
    return r'loginProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<dynamic> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<dynamic> create(Ref ref) {
    final argument = this.argument as ({String email, String password});
    return login(ref, email: argument.email, password: argument.password);
  }

  @override
  bool operator ==(Object other) {
    return other is LoginProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$loginHash() => r'f77d259994fb006592797a0d76db42dc90f39b7b';

final class LoginFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<dynamic>,
          ({String email, String password})
        > {
  const LoginFamily._()
    : super(
        retry: null,
        name: r'loginProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LoginProvider call({required String email, required String password}) =>
      LoginProvider._(argument: (email: email, password: password), from: this);

  @override
  String toString() => r'loginProvider';
}

@ProviderFor(purchase)
const purchaseProvider = PurchaseFamily._();

final class PurchaseProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  const PurchaseProvider._({
    required PurchaseFamily super.from,
    required (int, int, List<int>, List<int>) super.argument,
  }) : super(
         retry: null,
         name: r'purchaseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseHash();

  @override
  String toString() {
    return r'purchaseProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<dynamic> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<dynamic> create(Ref ref) {
    final argument = this.argument as (int, int, List<int>, List<int>);
    return purchase(ref, argument.$1, argument.$2, argument.$3, argument.$4);
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseHash() => r'a4e10ef16cca932e9bcfb97b755f86744b77b861';

final class PurchaseFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<dynamic>,
          (int, int, List<int>, List<int>)
        > {
  const PurchaseFamily._()
    : super(
        retry: null,
        name: r'purchaseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PurchaseProvider call(
    int userId,
    int paymentId,
    List<int> itemIds,
    List<int> quantities,
  ) => PurchaseProvider._(
    argument: (userId, paymentId, itemIds, quantities),
    from: this,
  );

  @override
  String toString() => r'purchaseProvider';
}

@ProviderFor(payments)
const paymentsProvider = PaymentsProvider._();

final class PaymentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  const PaymentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentsHash();

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    return payments(ref);
  }
}

String _$paymentsHash() => r'07a0090309cf8d7d7f7fd4a804c5b1cb698d30fa';

@ProviderFor(purchaseHistory)
const purchaseHistoryProvider = PurchaseHistoryFamily._();

final class PurchaseHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  const PurchaseHistoryProvider._({
    required PurchaseHistoryFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'purchaseHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseHistoryHash();

  @override
  String toString() {
    return r'purchaseHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    final argument = this.argument as int;
    return purchaseHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseHistoryHash() => r'b42b308b443ceb9b6836af90719a381b68141937';

final class PurchaseHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<dynamic>>, int> {
  const PurchaseHistoryFamily._()
    : super(
        retry: null,
        name: r'purchaseHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PurchaseHistoryProvider call(int user_id) =>
      PurchaseHistoryProvider._(argument: user_id, from: this);

  @override
  String toString() => r'purchaseHistoryProvider';
}

@ProviderFor(updateUser)
const updateUserProvider = UpdateUserFamily._();

final class UpdateUserProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  const UpdateUserProvider._({
    required UpdateUserFamily super.from,
    required ({
      int id,
      String name,
      String email,
      String hashed_password,
      String tel,
      int prefecture_id,
      String address,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'updateUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$updateUserHash();

  @override
  String toString() {
    return r'updateUserProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<dynamic> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<dynamic> create(Ref ref) {
    final argument =
        this.argument
            as ({
              int id,
              String name,
              String email,
              String hashed_password,
              String tel,
              int prefecture_id,
              String address,
            });
    return updateUser(
      ref,
      id: argument.id,
      name: argument.name,
      email: argument.email,
      hashed_password: argument.hashed_password,
      tel: argument.tel,
      prefecture_id: argument.prefecture_id,
      address: argument.address,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateUserHash() => r'3fa73505a685513ecb3079497c76eab45b5714d1';

final class UpdateUserFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<dynamic>,
          ({
            int id,
            String name,
            String email,
            String hashed_password,
            String tel,
            int prefecture_id,
            String address,
          })
        > {
  const UpdateUserFamily._()
    : super(
        retry: null,
        name: r'updateUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UpdateUserProvider call({
    required int id,
    required String name,
    required String email,
    required String hashed_password,
    required String tel,
    required int prefecture_id,
    required String address,
  }) => UpdateUserProvider._(
    argument: (
      id: id,
      name: name,
      email: email,
      hashed_password: hashed_password,
      tel: tel,
      prefecture_id: prefecture_id,
      address: address,
    ),
    from: this,
  );

  @override
  String toString() => r'updateUserProvider';
}

@ProviderFor(changePassword)
const changePasswordProvider = ChangePasswordFamily._();

final class ChangePasswordProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  const ChangePasswordProvider._({
    required ChangePasswordFamily super.from,
    required ({int id, String newPassword}) super.argument,
  }) : super(
         retry: null,
         name: r'changePasswordProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$changePasswordHash();

  @override
  String toString() {
    return r'changePasswordProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as ({int id, String newPassword});
    return changePassword(
      ref,
      id: argument.id,
      newPassword: argument.newPassword,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChangePasswordProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$changePasswordHash() => r'bffdd128bf29f827bdca09646721abca0b7eb330';

final class ChangePasswordFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<String>,
          ({int id, String newPassword})
        > {
  const ChangePasswordFamily._()
    : super(
        retry: null,
        name: r'changePasswordProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChangePasswordProvider call({required int id, required String newPassword}) =>
      ChangePasswordProvider._(
        argument: (id: id, newPassword: newPassword),
        from: this,
      );

  @override
  String toString() => r'changePasswordProvider';
}

@ProviderFor(prefectures)
const prefecturesProvider = PrefecturesProvider._();

final class PrefecturesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  const PrefecturesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'prefecturesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$prefecturesHash();

  @$internal
  @override
  $FutureProviderElement<List<dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<dynamic>> create(Ref ref) {
    return prefectures(ref);
  }
}

String _$prefecturesHash() => r'cd69b2351f196ec4ac095a957d564100572296fe';
