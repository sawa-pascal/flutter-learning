
import 'package:flutter/material.dart';
import 'login.dart';
import 'cart.dart';
import 'models/userModel/userModel.dart';

AppBar buildAppBar(BuildContext context, String title, UserModel? userModel) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(fontSize: 30, color: Colors.green),
    ),
    centerTitle: true,
    leading: const Icon(Icons.home),
    actions: [
      const Icon(Icons.search),
      userModel == null
          ? TextButton(
              onPressed: () => Navigator.of(
                context,
                rootNavigator: true,
              ).push(MaterialPageRoute(builder: (context) => const Login())),
              child: const Text('ログイン'),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  userModel.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
      IconButton(
        icon: const Icon(Icons.shopping_cart),
        onPressed: () => Navigator.of(
          context,
          rootNavigator: true,
        ).push(MaterialPageRoute(builder: (context) => const Cart())),
        tooltip: 'Cartページへ',
      ),
    ],
    elevation: 10,
    backgroundColor: Colors.red,
    flexibleSpace: Image.network(
      'http://3.26.29.114/images/%E3%83%8E%E3%83%BC%E3%83%88/1129031014690ad52f20b671.42419074.png',
      fit: BoxFit.contain,
    ),
  );
}

