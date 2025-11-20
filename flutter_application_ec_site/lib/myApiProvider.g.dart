// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myApiProvider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$itemsHash() => r'346f7a06e09dbc837b6d6c443b3a802cd65f9eea';

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

String _$loginHash() => r'e974fac5b617f1d0c186802a8b67c50d7233f21f';

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
