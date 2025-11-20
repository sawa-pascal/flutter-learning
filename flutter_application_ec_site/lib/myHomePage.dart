import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'myApiProvider.dart';
import 'models/userModel/userModel.dart';
import 'appBar.dart';
import 'userInfoSection.dart';
import 'item.dart';
import 'errorView.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);
    final userModel = ref.watch(userModelProvider);

    return Scaffold(
      appBar: buildAppBar(context, title, userModel),
      body: Column(
        children: [
          UserInfoSection(userModel: userModel),
          Expanded(
            child: itemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => ErrorView(
                error: error,
                onRetry: () => ref.refresh(itemsProvider.future),
              ),
              data: (items) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(itemsProvider);
                  // Wait for refresh effect
                  await ref.read(itemsProvider.future);
                },
                child: ItemList(items: items),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
