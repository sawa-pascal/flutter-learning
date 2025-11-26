// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'msApiProvider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

@ProviderFor(createCategories)
const createCategoriesProvider = CreateCategoriesFamily._();

final class CreateCategoriesProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  const CreateCategoriesProvider._({
    required CreateCategoriesFamily super.from,
    required ({String name, String display_order}) super.argument,
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
    final argument = this.argument as ({String name, String display_order});
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

String _$createCategoriesHash() => r'53200ac1bbc8055b6f648cb1220225e636702d92';

final class CreateCategoriesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<dynamic>,
          ({String name, String display_order})
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
    required String display_order,
  }) => CreateCategoriesProvider._(
    argument: (name: name, display_order: display_order),
    from: this,
  );

  @override
  String toString() => r'createCategoriesProvider';
}
