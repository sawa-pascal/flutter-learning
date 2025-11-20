
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/userModel/userModel.dart';

class UserInfoSection extends ConsumerWidget {
  final UserModel? userModel;

  const UserInfoSection({Key? key, required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userModel == null) {
      return const SizedBox(height: 20); // ログインしていない場合は空スペース
    }
    return Card(
      color: Colors.green.shade50,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            const Icon(Icons.account_circle, size: 36, color: Colors.green),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userModel?.name ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userModel?.email ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  if (userModel?.tel != null)
                    Text(
                      'TEL: ${userModel?.tel}',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  if (userModel?.address != null && (userModel!.address ?? '').trim().isNotEmpty)
                    Text(
                      '住所: ${userModel?.address}',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                      label: const Text('ログアウト', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(80, 36),
                      ),
                      onPressed: () {
                        ref.read(userModelProvider.notifier).state = null;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ログアウトしました')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

