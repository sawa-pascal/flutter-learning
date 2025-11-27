// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myApiProvider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categories)
const categoriesProvider = CategoriesFamily._();

final class CategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<dynamic>>,
          List<dynamic>,
          FutureOr<List<dynamic>>
        >
    with $FutureModifier<List<dynamic>>, $FutureProvider<List<dynamic>> {
  const CategoriesProvider._({
    required CategoriesFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'categoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @override
  String toString() {
    return r'categoriesProvider'
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
    final argument = this.argument as int?;
    return categories(ref, id: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoriesHash() => r'e717c42f532106fb474dc994c6078cc098094e5f';

final class CategoriesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<dynamic>>, int?> {
  const CategoriesFamily._()
    : super(
        retry: null,
        name: r'categoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoriesProvider call({int? id}) =>
      CategoriesProvider._(argument: id, from: this);

  @override
  String toString() => r'categoriesProvider';
}

@ProviderFor(createCategories)
const createCategoriesProvider = CreateCategoriesFamily._();

final class CreateCategoriesProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  const CreateCategoriesProvider._({
    required CreateCategoriesFamily super.from,
    required ({String name, int display_order}) super.argument,
  }) : super(
         retry: null,
         name: r'createCategoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$createCategoriesHash();

  @override
  String toString() {
    return r'createCategoriesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<dynamic> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<dynamic> create(Ref ref) {
    final argument = this.argument as ({String name, int display_order});
    return createCategories(
      ref,
      name: argument.name,
      display_order: argument.display_order,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CreateCategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$createCategoriesHash() => r'b98b1e7f5064fe1377e8a8147ca481bd9f5c4185';

final class CreateCategoriesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<dynamic>,
          ({String name, int display_order})
        > {
  const CreateCategoriesFamily._()
    : super(
        retry: null,
        name: r'createCategoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreateCategoriesProvider call({
    required String name,
    required int display_order,
  }) => CreateCategoriesProvider._(
    argument: (name: name, display_order: display_order),
    from: this,
  );

  @override
  String toString() => r'createCategoriesProvider';
}

@ProviderFor(updateCategories)
const updateCategoriesProvider = UpdateCategoriesFamily._();

final class UpdateCategoriesProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  const UpdateCategoriesProvider._({
    required UpdateCategoriesFamily super.from,
    required ({int id, String name, int display_order}) super.argument,
  }) : super(
         retry: null,
         name: r'updateCategoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$updateCategoriesHash();

  @override
  String toString() {
    return r'updateCategoriesProvider'
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
        this.argument as ({int id, String name, int display_order});
    return updateCategories(
      ref,
      id: argument.id,
      name: argument.name,
      display_order: argument.display_order,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateCategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateCategoriesHash() => r'acbdfb9b2cc32e8804397b7e9de79c5663acb397';

final class UpdateCategoriesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<dynamic>,
          ({int id, String name, int display_order})
        > {
  const UpdateCategoriesFamily._()
    : super(
        retry: null,
        name: r'updateCategoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UpdateCategoriesProvider call({
    required int id,
    required String name,
    required int display_order,
  }) => UpdateCategoriesProvider._(
    argument: (id: id, name: name, display_order: display_order),
    from: this,
  );

  @override
  String toString() => r'updateCategoriesProvider';
}

@ProviderFor(deleteCategories)
const deleteCategoriesProvider = DeleteCategoriesFamily._();

final class DeleteCategoriesProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  const DeleteCategoriesProvider._({
    required DeleteCategoriesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'deleteCategoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteCategoriesHash();

  @override
  String toString() {
    return r'deleteCategoriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<dynamic> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<dynamic> create(Ref ref) {
    final argument = this.argument as int;
    return deleteCategories(ref, id: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteCategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteCategoriesHash() => r'92e7333ac32ce7aedcef1c93f37bc5b0be17db71';

final class DeleteCategoriesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<dynamic>, int> {
  const DeleteCategoriesFamily._()
    : super(
        retry: null,
        name: r'deleteCategoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeleteCategoriesProvider call({required int id}) =>
      DeleteCategoriesProvider._(argument: id, from: this);

  @override
  String toString() => r'deleteCategoriesProvider';
}

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

String _$itemsHash() => r'064e1f33fc6cace5bd5411948e2521c372577fb3';

@ProviderFor(createItems)
const createItemsProvider = CreateItemsFamily._();

final class CreateItemsProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  const CreateItemsProvider._({
    required CreateItemsFamily super.from,
    required ({
      String name,
      int category_id,
      int price,
      int stock,
      String description,
      String image_url,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'createItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$createItemsHash();

  @override
  String toString() {
    return r'createItemsProvider'
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
              String name,
              int category_id,
              int price,
              int stock,
              String description,
              String image_url,
            });
    return createItems(
      ref,
      name: argument.name,
      category_id: argument.category_id,
      price: argument.price,
      stock: argument.stock,
      description: argument.description,
      image_url: argument.image_url,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CreateItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$createItemsHash() => r'1060e764ab9c47220edbdd878f89793543b13cc8';

final class CreateItemsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<dynamic>,
          ({
            String name,
            int category_id,
            int price,
            int stock,
            String description,
            String image_url,
          })
        > {
  const CreateItemsFamily._()
    : super(
        retry: null,
        name: r'createItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreateItemsProvider call({
    required String name,
    required int category_id,
    required int price,
    required int stock,
    required String description,
    required String image_url,
  }) => CreateItemsProvider._(
    argument: (
      name: name,
      category_id: category_id,
      price: price,
      stock: stock,
      description: description,
      image_url: image_url,
    ),
    from: this,
  );

  @override
  String toString() => r'createItemsProvider';
}

@ProviderFor(updateItems)
const updateItemsProvider = UpdateItemsFamily._();

final class UpdateItemsProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  const UpdateItemsProvider._({
    required UpdateItemsFamily super.from,
    required ({
      int id,
      String name,
      int category_id,
      int price,
      int stock,
      String description,
      String image_url,
      String? origin_image_url,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'updateItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$updateItemsHash();

  @override
  String toString() {
    return r'updateItemsProvider'
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
              int category_id,
              int price,
              int stock,
              String description,
              String image_url,
              String? origin_image_url,
            });
    return updateItems(
      ref,
      id: argument.id,
      name: argument.name,
      category_id: argument.category_id,
      price: argument.price,
      stock: argument.stock,
      description: argument.description,
      image_url: argument.image_url,
      origin_image_url: argument.origin_image_url,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateItemsHash() => r'5a0373a6721e4a6bd2a783732281ddda4b4dc650';

final class UpdateItemsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<dynamic>,
          ({
            int id,
            String name,
            int category_id,
            int price,
            int stock,
            String description,
            String image_url,
            String? origin_image_url,
          })
        > {
  const UpdateItemsFamily._()
    : super(
        retry: null,
        name: r'updateItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UpdateItemsProvider call({
    required int id,
    required String name,
    required int category_id,
    required int price,
    required int stock,
    required String description,
    required String image_url,
    String? origin_image_url,
  }) => UpdateItemsProvider._(
    argument: (
      id: id,
      name: name,
      category_id: category_id,
      price: price,
      stock: stock,
      description: description,
      image_url: image_url,
      origin_image_url: origin_image_url,
    ),
    from: this,
  );

  @override
  String toString() => r'updateItemsProvider';
}

@ProviderFor(deleteItems)
const deleteItemsProvider = DeleteItemsFamily._();

final class DeleteItemsProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  const DeleteItemsProvider._({
    required DeleteItemsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'deleteItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteItemsHash();

  @override
  String toString() {
    return r'deleteItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<dynamic> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<dynamic> create(Ref ref) {
    final argument = this.argument as int;
    return deleteItems(ref, id: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteItemsHash() => r'14106de9c21b4b1a55d404b75b575dfcfcfaf1e8';

final class DeleteItemsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<dynamic>, int> {
  const DeleteItemsFamily._()
    : super(
        retry: null,
        name: r'deleteItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeleteItemsProvider call({required int id}) =>
      DeleteItemsProvider._(argument: id, from: this);

  @override
  String toString() => r'deleteItemsProvider';
}

@ProviderFor(uploadItemImage)
const uploadItemImageProvider = UploadItemImageFamily._();

final class UploadItemImageProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  const UploadItemImageProvider._({
    required UploadItemImageFamily super.from,
    required ({String categoryName, String? imageUrl, List<int> imageBytes})
    super.argument,
  }) : super(
         retry: null,
         name: r'uploadItemImageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$uploadItemImageHash();

  @override
  String toString() {
    return r'uploadItemImageProvider'
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
            as ({String categoryName, String? imageUrl, List<int> imageBytes});
    return uploadItemImage(
      ref,
      categoryName: argument.categoryName,
      imageUrl: argument.imageUrl,
      imageBytes: argument.imageBytes,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UploadItemImageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$uploadItemImageHash() => r'36a08d460b556cf7fbff612306e841571efa45ac';

final class UploadItemImageFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<dynamic>,
          ({String categoryName, String? imageUrl, List<int> imageBytes})
        > {
  const UploadItemImageFamily._()
    : super(
        retry: null,
        name: r'uploadItemImageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UploadItemImageProvider call({
    required String categoryName,
    String? imageUrl,
    required List<int> imageBytes,
  }) => UploadItemImageProvider._(
    argument: (
      categoryName: categoryName,
      imageUrl: imageUrl,
      imageBytes: imageBytes,
    ),
    from: this,
  );

  @override
  String toString() => r'uploadItemImageProvider';
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

String _$purchaseHash() => r'04fc9669e96049cb50bfaf4214f98662d090beb5';

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

String _$paymentsHash() => r'2f9007f8ffc40cdd29a90c390d44f887b2c028a8';

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

String _$purchaseHistoryHash() => r'68732e9edbfafa3942978ac4a529761518539e7c';

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

@ProviderFor(usersList)
const usersListProvider = UsersListFamily._();

final class UsersListProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  const UsersListProvider._({
    required UsersListFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'usersListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$usersListHash();

  @override
  String toString() {
    return r'usersListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    final argument = this.argument as int?;
    return usersList(ref, id: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UsersListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$usersListHash() => r'2663cf1bb9e551f041d5ab76149476450c046444';

final class UsersListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, dynamic>>, int?> {
  const UsersListFamily._()
    : super(
        retry: null,
        name: r'usersListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UsersListProvider call({int? id}) =>
      UsersListProvider._(argument: id, from: this);

  @override
  String toString() => r'usersListProvider';
}

@ProviderFor(createUsers)
const createUsersProvider = CreateUsersFamily._();

final class CreateUsersProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  const CreateUsersProvider._({
    required CreateUsersFamily super.from,
    required ({
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
         name: r'createUsersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$createUsersHash();

  @override
  String toString() {
    return r'createUsersProvider'
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
              String name,
              String email,
              String hashed_password,
              String tel,
              int prefecture_id,
              String address,
            });
    return createUsers(
      ref,
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
    return other is CreateUsersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$createUsersHash() => r'14f20a488b120fd614dc847f98a9ee3f0478bb85';

final class CreateUsersFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<dynamic>,
          ({
            String name,
            String email,
            String hashed_password,
            String tel,
            int prefecture_id,
            String address,
          })
        > {
  const CreateUsersFamily._()
    : super(
        retry: null,
        name: r'createUsersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreateUsersProvider call({
    required String name,
    required String email,
    required String hashed_password,
    required String tel,
    required int prefecture_id,
    required String address,
  }) => CreateUsersProvider._(
    argument: (
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
  String toString() => r'createUsersProvider';
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

String _$updateUserHash() => r'834443eec23a3f2d3d0745ea996c6a4fec6c704c';

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

@ProviderFor(deleteUser)
const deleteUserProvider = DeleteUserFamily._();

final class DeleteUserProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  const DeleteUserProvider._({
    required DeleteUserFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'deleteUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteUserHash();

  @override
  String toString() {
    return r'deleteUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<dynamic> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<dynamic> create(Ref ref) {
    final argument = this.argument as int;
    return deleteUser(ref, id: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteUserHash() => r'edc1cb6e9a60fa0831fb95475c342717691071ff';

final class DeleteUserFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<dynamic>, int> {
  const DeleteUserFamily._()
    : super(
        retry: null,
        name: r'deleteUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeleteUserProvider call({required int id}) =>
      DeleteUserProvider._(argument: id, from: this);

  @override
  String toString() => r'deleteUserProvider';
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

String _$changePasswordHash() => r'742a55dbde4b93d314f1a83e1b337d8c528ea7f5';

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

@ProviderFor(managementSignin)
const managementSigninProvider = ManagementSigninFamily._();

final class ManagementSigninProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  const ManagementSigninProvider._({
    required ManagementSigninFamily super.from,
    required ({String name, String hashed_password}) super.argument,
  }) : super(
         retry: null,
         name: r'managementSigninProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$managementSigninHash();

  @override
  String toString() {
    return r'managementSigninProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<dynamic> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<dynamic> create(Ref ref) {
    final argument = this.argument as ({String name, String hashed_password});
    return managementSignin(
      ref,
      name: argument.name,
      hashed_password: argument.hashed_password,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ManagementSigninProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$managementSigninHash() => r'c2e6667d70e855ef9dc027b916bac49758149da3';

final class ManagementSigninFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<dynamic>,
          ({String name, String hashed_password})
        > {
  const ManagementSigninFamily._()
    : super(
        retry: null,
        name: r'managementSigninProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ManagementSigninProvider call({
    required String name,
    required String hashed_password,
  }) => ManagementSigninProvider._(
    argument: (name: name, hashed_password: hashed_password),
    from: this,
  );

  @override
  String toString() => r'managementSigninProvider';
}

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

String _$loginHash() => r'be4c4c8bf5c2bcddc2966683f386ea870f9e8e21';

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

String _$prefecturesHash() => r'77946fdad91ab4e3db699a09d3c0ab25e3fc063f';
