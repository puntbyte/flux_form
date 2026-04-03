// lib/widgets/app_drawer.dart

import 'package:example/features/booking/booking_page.dart';
import 'package:example/features/edit_profile/edit_profile_page.dart';
import 'package:example/features/inventory/inventory_page.dart';
import 'package:example/features/login/login_page.dart';
import 'package:example/features/search/search_page.dart';
import 'package:example/features/wizard/wizard_page.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Flux Form', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Feature Showcase', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          _tile(context,
            icon: Icons.login,
            title: 'Login',
            subtitle: 'FormSchema · FormSubmitter · detailedErrors',
            page: const LoginPage(),
          ),
          _tile(context,
            icon: Icons.how_to_reg,
            title: 'Registration Wizard',
            subtitle: 'MultiStepSchema · builder API · Validator.compose',
            page: const WizardPage(),
          ),
          _tile(context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'populateFrom · changedValues · nestedSchemas · blur',
            page: const EditProfilePage(),
          ),
          _tile(context,
            icon: Icons.calendar_month,
            title: 'Booking',
            subtitle: 'DateTimeInput · SchemaValidator · blur mode',
            page: const BookingPage(),
          ),
          _tile(context,
            icon: Icons.search,
            title: 'Search',
            subtitle: 'Debouncer · runAsync · validateAsyncParallel',
            page: const SearchPage(),
          ),
          _tile(context,
            icon: Icons.shopping_cart_outlined,
            title: 'Inventory',
            subtitle: 'ListInput · MapInput · Validator.compose · namedErrors',
            page: const InventoryPage(),
          ),
        ],
      ),
    );
  }

  Widget _tile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Widget page,
      }) {
    final isCurrent = ModalRoute.of(context)?.settings.name == title;
    return ListTile(
      leading: Icon(icon, color: isCurrent ? Colors.indigo : null),
      title: Text(title, style: isCurrent ? const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold) : null),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(settings: RouteSettings(name: title), builder: (_) => page),
        );
      },
    );
  }
}