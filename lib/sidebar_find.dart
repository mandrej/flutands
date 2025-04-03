import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

class SidebarFind extends StatelessWidget {
  const SidebarFind({super.key});

  @override
  Widget build(BuildContext context) {
    return SideBar(
      backgroundColor: Colors.white,
      items: const [
        AdminMenuItem(title: 'Home', route: '/', icon: Icons.home),
        AdminMenuItem(title: 'Add', route: '/add', icon: Icons.add),
        AdminMenuItem(title: 'Admin', route: '/admin', icon: Icons.settings),
      ],
      selectedRoute: '/',
      onSelected: (item) {
        if (item.route != null) {
          Navigator.of(context).pushNamed(item.route!);
        }
      },
      // header: Container(
      //   height: 50,
      //   width: double.infinity,
      //   color: const Color(0xff444444),
      //   child: const Center(
      //     child: Text('header', style: TextStyle(color: Colors.white)),
      //   ),
      // ),
      header: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text('Search'),
            TextField(decoration: InputDecoration(labelText: 'search by text')),
            TextField(decoration: InputDecoration(labelText: 'search by tags')),
          ],
        ),
      ),
      footer: Container(
        height: 50,
        width: double.infinity,
        color: const Color(0xff444444),
        child: const Center(
          child: Text('footer', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
