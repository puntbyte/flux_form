import 'package:example/features/booking/booking_page.dart';
import 'package:example/features/inventory/inventory_page.dart';
import 'package:example/features/localized_register/register_page.dart';
import 'package:example/features/login/login_page.dart';
import 'package:example/features/products/product_page.dart';
import 'package:example/features/profile/profile_page.dart';
import 'package:example/features/search/search_page.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('FluxForm Examples', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),

          ListTile(
            title: const Text('Login Form'),
            subtitle: const Text('GenericInput • String Errors'),
            leading: const Icon(Icons.login),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
          ),

          ListTile(
            title: const Text('Inventory List'),
            subtitle: const Text('ListInput • Dynamic Items'),
            leading: const Icon(Icons.list),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const InventoryPage()),
            ),
          ),

          ListTile(
            title: const Text('Profile Form'),
            subtitle: const Text('StringField • BoolField • Conditional Logic'),
            leading: const Icon(Icons.person),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),

          ListTile(
            title: const Text('Booking Form'),
            subtitle: const Text('Cross-Field Validation'),
            leading: const Icon(Icons.calendar_today),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const BookingPage()),
            ),
          ),

          ListTile(
            title: const Text('Register Form'),
            subtitle: const Text('Enum Errors • Localized'),
            leading: const Icon(Icons.lock),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            ),
          ),

          ListTile(
            title: const Text('Product List'),
            subtitle: const Text('FilterInput • Dynamic Items'),
            leading: const Icon(Icons.abc),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProductPage()),
            ),
          ),

          ListTile(
            title: const Text('Search Form'),
            subtitle: const Text('StringField • Debounce • Async'),
            leading: const Icon(Icons.search),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
          ),
        ],
      ),
    );
  }
}
