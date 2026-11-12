import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import 'product_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      tabs: [
        PersistentTabConfig(
          screen: ProductScreen(),
          item: ItemConfig(
            icon: Icon(Icons.storefront),
            title: "Products",
            // activeForegroundColor: Theme.of(
            //   context,
            // ).colorScheme.onSecondaryContainer,
            // inactiveForegroundColor: Theme.of(context).colorScheme.onPrimary,
            activeForegroundColor: Theme.of(context).colorScheme.primary,
            inactiveForegroundColor: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant,
          ),
        ),

        // PersistentTabConfig(
        //   screen: ProductScreen(),
        //   item: ItemConfig(
        //     icon: Icon(Icons.home),
        //     title: "Home",
        //     activeForegroundColor: Theme.of(
        //       context,
        //     ).colorScheme.onSecondaryContainer,
        //     inactiveForegroundColor: Theme.of(context).colorScheme.onPrimary,
        //   ),
        // ),
        PersistentTabConfig(
          screen: SettingsScreen(),
          item: ItemConfig(
            icon: Icon(Icons.settings),
            title: "Settings",
            // activeForegroundColor: Theme.of(
            //   context,
            // ).colorScheme.onSecondaryContainer,
            // inactiveForegroundColor: Theme.of(context).colorScheme.onPrimary,
            activeForegroundColor: Theme.of(context).colorScheme.primary,
            inactiveForegroundColor: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
      navBarBuilder: (navBarConfig) => Style9BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
      ),
    );
  }
}
