import 'package:flutter/material.dart';
import 'package:flutter_application_ec_site/managementSystemWidget/categories/categoriesList.dart';
import 'package:flutter_application_ec_site/managementSystemWidget/items/itemsList.dart';
import 'package:flutter_application_ec_site/managementSystemWidget/sales/salesList.dart';
import 'package:flutter_application_ec_site/managementSystemWidget/users/usersList.dart';
import 'package:flutter_application_ec_site/myHomePage.dart';

/// 共通Drawer（管理画面用）
class ManagementSystemDrawer extends StatelessWidget {
  const ManagementSystemDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.redAccent),
              child: Center(
                child: Text(
                  '管理システムメニュー',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('カテゴリー登録'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CategoriesListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('在庫管理'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ItemsListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('ユーザー情報'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UsersListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('売上管理'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SalesListPage()),
                );
              },
            ),

            Divider(),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('ホームへ'),
              onTap: () {
                Navigator.of(context).pop(); // Drawer を閉じる
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(title: 'S.A.アプリ'),
                  ),
                );
              },
            ),
            // 必要なら他の管理メニュー追加
          ],
        ),
      ),
    );
  }
}

/// 共通のヘッダー画面として利用するAppBar（管理画面用）
///
/// ※ このAppBarをScaffoldに設置し、Scaffold.drawerに[ManagementSystemDrawer]をセットして利用すること。
PreferredSizeWidget managementSystemAppBar(
  BuildContext context, {
  String title = 'カテゴリー一覧',
}) {
  return AppBar(
    title: Text(title),
    centerTitle: true,
    automaticallyImplyLeading: false,
    leading: Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: 'メニュー',
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MyHomePage(title: 'S.A.アプリ'),
              ),
            );
          },
          icon: const Icon(Icons.home),
          tooltip: 'ホーム',
        ),
      ],
    ),
    leadingWidth: 100,
  );
}
