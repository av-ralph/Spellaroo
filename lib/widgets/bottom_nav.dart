import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  static const _paths = [
    '/home',
    '/shop',
    '/character/customize',
    '/progress',
    '/settings',
  ];

  static const _items = [
    _NavItemData(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    _NavItemData(
      label: 'Shop',
      icon: Icons.shopping_bag_outlined,
      selectedIcon: Icons.shopping_bag,
    ),
    _NavItemData(
      label: 'Character',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
    _NavItemData(
      label: 'Progress',
      icon: Icons.trending_up_outlined,
      selectedIcon: Icons.trending_up,
    ),
    _NavItemData(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  static int _selectedIndex(String location) {
    for (var i = 0; i < _paths.length; i++) {
      final path = _paths[i];
      if (location == path || location.startsWith('$path/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selected = _selectedIndex(location);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFFFD580).withValues(alpha: 0.7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isSelected = selected == index;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.go(_paths[index]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFE8B0)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedScale(
                            scale: isSelected ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            child: Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected
                                  ? const Color(0xFF5A3216)
                                  : const Color(0xFF7A6D63),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            style: TextStyle(
                              fontSize: isSelected ? 11 : 10,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                              color: isSelected
                                  ? const Color(0xFF5A3216)
                                  : const Color(0xFF7A6D63),
                              letterSpacing: 0.15,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
