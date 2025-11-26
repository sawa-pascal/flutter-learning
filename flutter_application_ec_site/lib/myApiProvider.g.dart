// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myApiProvider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// カテゴリー一覧を取得するProvider
///
/// サーバーからカテゴリーのリストを取得します。
/// 戻り値: カテゴリー情報のリスト

@ProviderFor(categories)
const categoriesProvider = CategoriesProvider._();

/// カテゴリー一覧を取得するProvider
///
/// サーバーからカテゴリーのリストを取得します。
/// 戻り値: カテゴリー情報のリスト

final class CategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  /// カテゴリー一覧を取得するProvider
  ///
  /// サーバーからカテゴリーのリストを取得します。
  /// 戻り値: カテゴリー情報のリスト
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

String _$categoriesHash() => r'5aaf292782a83131410a3e24d01619cd61ab5612';

/// 商品一覧を取得するProvider
///
/// サーバーから商品のリストを取得します。
/// 戻り値: 商品情報のリスト

@ProviderFor(items)
const itemsProvider = ItemsProvider._();

/// 商品一覧を取得するProvider
///
/// サーバーから商品のリストを取得します。
/// 戻り値: 商品情報のリスト

final class ItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  /// 商品一覧を取得するProvider
  ///
  /// サーバーから商品のリストを取得します。
  /// 戻り値: 商品情報のリスト
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

String _$itemsHash() => r'064e1f33fc6cace5bd5411948e2521c372577fb3';

/// ユーザーログインを実行するProvider
///
/// [email]: ユーザーのメールアドレス
/// [password]: ユーザーのパスワード
///
/// 戻り値: ログイン成功時のユーザー情報

@ProviderFor(login)
const loginProvider = LoginFamily._();

/// ユーザーログインを実行するProvider
///
/// [email]: ユーザーのメールアドレス
/// [password]: ユーザーのパスワード
///
/// 戻り値: ログイン成功時のユーザー情報

final class LoginProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  /// ユーザーログインを実行するProvider
  ///
  /// [email]: ユーザーのメールアドレス
  /// [password]: ユーザーのパスワード
  ///
  /// 戻り値: ログイン成功時のユーザー情報
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

String _$loginHash() => r'be4c4c8bf5c2bcddc2966683f386ea870f9e8e21';

/// ユーザーログインを実行するProvider
///
/// [email]: ユーザーのメールアドレス
/// [password]: ユーザーのパスワード
///
/// 戻り値: ログイン成功時のユーザー情報

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

  /// ユーザーログインを実行するProvider
  ///
  /// [email]: ユーザーのメールアドレス
  /// [password]: ユーザーのパスワード
  ///
  /// 戻り値: ログイン成功時のユーザー情報

  LoginProvider call({required String email, required String password}) =>
      LoginProvider._(argument: (email: email, password: password), from: this);

  @override
  String toString() => r'loginProvider';
}

/// 購入処理を実行するProvider
///
/// [userId]: 購入するユーザーのID
/// [paymentId]: 支払い方法のID
/// [itemIds]: 購入する商品のIDリスト
/// [quantities]: 各商品の数量リスト（itemIdsと順序が一致している必要がある）
///
/// 戻り値: 購入処理の結果

@ProviderFor(purchase)
const purchaseProvider = PurchaseFamily._();

/// 購入処理を実行するProvider
///
/// [userId]: 購入するユーザーのID
/// [paymentId]: 支払い方法のID
/// [itemIds]: 購入する商品のIDリスト
/// [quantities]: 各商品の数量リスト（itemIdsと順序が一致している必要がある）
///
/// 戻り値: 購入処理の結果

final class PurchaseProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  /// 購入処理を実行するProvider
  ///
  /// [userId]: 購入するユーザーのID
  /// [paymentId]: 支払い方法のID
  /// [itemIds]: 購入する商品のIDリスト
  /// [quantities]: 各商品の数量リスト（itemIdsと順序が一致している必要がある）
  ///
  /// 戻り値: 購入処理の結果
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

String _$purchaseHash() => r'04fc9669e96049cb50bfaf4214f98662d090beb5';

/// 購入処理を実行するProvider
///
/// [userId]: 購入するユーザーのID
/// [paymentId]: 支払い方法のID
/// [itemIds]: 購入する商品のIDリスト
/// [quantities]: 各商品の数量リスト（itemIdsと順序が一致している必要がある）
///
/// 戻り値: 購入処理の結果

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

  /// 購入処理を実行するProvider
  ///
  /// [userId]: 購入するユーザーのID
  /// [paymentId]: 支払い方法のID
  /// [itemIds]: 購入する商品のIDリスト
  /// [quantities]: 各商品の数量リスト（itemIdsと順序が一致している必要がある）
  ///
  /// 戻り値: 購入処理の結果

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

/// 支払い方法一覧を取得するProvider
///
/// 戻り値: 支払い方法情報のリスト

@ProviderFor(payments)
const paymentsProvider = PaymentsProvider._();

/// 支払い方法一覧を取得するProvider
///
/// 戻り値: 支払い方法情報のリスト

final class PaymentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  /// 支払い方法一覧を取得するProvider
  ///
  /// 戻り値: 支払い方法情報のリスト
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

String _$paymentsHash() => r'2f9007f8ffc40cdd29a90c390d44f887b2c028a8';

/// 購入履歴を取得するProvider
///
/// [user_id]: 購入履歴を取得するユーザーのID
///
/// 戻り値: 購入履歴情報のリスト

@ProviderFor(purchaseHistory)
const purchaseHistoryProvider = PurchaseHistoryFamily._();

/// 購入履歴を取得するProvider
///
/// [user_id]: 購入履歴を取得するユーザーのID
///
/// 戻り値: 購入履歴情報のリスト

final class PurchaseHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  /// 購入履歴を取得するProvider
  ///
  /// [user_id]: 購入履歴を取得するユーザーのID
  ///
  /// 戻り値: 購入履歴情報のリスト
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

String _$purchaseHistoryHash() => r'68732e9edbfafa3942978ac4a529761518539e7c';

/// 購入履歴を取得するProvider
///
/// [user_id]: 購入履歴を取得するユーザーのID
///
/// 戻り値: 購入履歴情報のリスト

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

  /// 購入履歴を取得するProvider
  ///
  /// [user_id]: 購入履歴を取得するユーザーのID
  ///
  /// 戻り値: 購入履歴情報のリスト

  PurchaseHistoryProvider call(int user_id) =>
      PurchaseHistoryProvider._(argument: user_id, from: this);

  @override
  String toString() => r'purchaseHistoryProvider';
}

/// ユーザー情報を更新するProvider
///
/// [id]: 更新するユーザーのID
/// [name]: ユーザー名
/// [email]: メールアドレス
/// [hashed_password]: ハッシュ化されたパスワード
/// [tel]: 電話番号
/// [prefecture_id]: 都道府県ID
/// [address]: 住所
///
/// 戻り値: 更新処理の結果

@ProviderFor(updateUser)
const updateUserProvider = UpdateUserFamily._();

/// ユーザー情報を更新するProvider
///
/// [id]: 更新するユーザーのID
/// [name]: ユーザー名
/// [email]: メールアドレス
/// [hashed_password]: ハッシュ化されたパスワード
/// [tel]: 電話番号
/// [prefecture_id]: 都道府県ID
/// [address]: 住所
///
/// 戻り値: 更新処理の結果

final class UpdateUserProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  /// ユーザー情報を更新するProvider
  ///
  /// [id]: 更新するユーザーのID
  /// [name]: ユーザー名
  /// [email]: メールアドレス
  /// [hashed_password]: ハッシュ化されたパスワード
  /// [tel]: 電話番号
  /// [prefecture_id]: 都道府県ID
  /// [address]: 住所
  ///
  /// 戻り値: 更新処理の結果
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

String _$updateUserHash() => r'834443eec23a3f2d3d0745ea996c6a4fec6c704c';

/// ユーザー情報を更新するProvider
///
/// [id]: 更新するユーザーのID
/// [name]: ユーザー名
/// [email]: メールアドレス
/// [hashed_password]: ハッシュ化されたパスワード
/// [tel]: 電話番号
/// [prefecture_id]: 都道府県ID
/// [address]: 住所
///
/// 戻り値: 更新処理の結果

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

  /// ユーザー情報を更新するProvider
  ///
  /// [id]: 更新するユーザーのID
  /// [name]: ユーザー名
  /// [email]: メールアドレス
  /// [hashed_password]: ハッシュ化されたパスワード
  /// [tel]: 電話番号
  /// [prefecture_id]: 都道府県ID
  /// [address]: 住所
  ///
  /// 戻り値: 更新処理の結果

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

/// パスワードを変更するProvider
///
/// [id]: パスワードを変更するユーザーのID
/// [newPassword]: 新しいパスワード（ハッシュ化済み）
///
/// 戻り値: 変更処理の結果メッセージ

@ProviderFor(changePassword)
const changePasswordProvider = ChangePasswordFamily._();

/// パスワードを変更するProvider
///
/// [id]: パスワードを変更するユーザーのID
/// [newPassword]: 新しいパスワード（ハッシュ化済み）
///
/// 戻り値: 変更処理の結果メッセージ

final class ChangePasswordProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// パスワードを変更するProvider
  ///
  /// [id]: パスワードを変更するユーザーのID
  /// [newPassword]: 新しいパスワード（ハッシュ化済み）
  ///
  /// 戻り値: 変更処理の結果メッセージ
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

String _$changePasswordHash() => r'742a55dbde4b93d314f1a83e1b337d8c528ea7f5';

/// パスワードを変更するProvider
///
/// [id]: パスワードを変更するユーザーのID
/// [newPassword]: 新しいパスワード（ハッシュ化済み）
///
/// 戻り値: 変更処理の結果メッセージ

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

  /// パスワードを変更するProvider
  ///
  /// [id]: パスワードを変更するユーザーのID
  /// [newPassword]: 新しいパスワード（ハッシュ化済み）
  ///
  /// 戻り値: 変更処理の結果メッセージ

  ChangePasswordProvider call({required int id, required String newPassword}) =>
      ChangePasswordProvider._(
        argument: (id: id, newPassword: newPassword),
        from: this,
      );

  @override
  String toString() => r'changePasswordProvider';
}

/// 都道府県一覧を取得するProvider
///
/// 戻り値: 都道府県情報のリスト

@ProviderFor(prefectures)
const prefecturesProvider = PrefecturesProvider._();

/// 都道府県一覧を取得するProvider
///
/// 戻り値: 都道府県情報のリスト

final class PrefecturesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  /// 都道府県一覧を取得するProvider
  ///
  /// 戻り値: 都道府県情報のリスト
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

String _$prefecturesHash() => r'77946fdad91ab4e3db699a09d3c0ab25e3fc063f';
