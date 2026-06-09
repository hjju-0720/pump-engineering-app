import 'package:flutter/material.dart';

import '../app_menu.dart';

class SideMenu extends StatelessWidget {
  final AppMenu selectedMenu;
  final ValueChanged<AppMenu> onMenuSelected;

  const SideMenu({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      color: const Color(0xFF05080C),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final menu in AppMenu.values)
            InkWell(
              onTap: () => onMenuSelected(menu),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: menu == selectedMenu
                      ? Colors.blue.withOpacity(0.25)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: menu == selectedMenu
                        ? Colors.lightBlueAccent.withOpacity(0.35)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  menu.label,
                  style: TextStyle(
                    color: menu == selectedMenu
                        ? Colors.lightBlueAccent
                        : Colors.white70,
                    fontWeight: menu == selectedMenu
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          const Spacer(),
          const Text('v0.1.0'),
        ],
      ),
    );
  }
}