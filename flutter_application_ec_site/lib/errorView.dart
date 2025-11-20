import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({required this.error, required this.onRetry, Key? key})
    : super(key: key);

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 40),
          const SizedBox(height: 16),
          Text(error.toString().isNotEmpty ? error.toString() : 'エラーが発生しました'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('再試行')),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
