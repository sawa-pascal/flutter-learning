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
