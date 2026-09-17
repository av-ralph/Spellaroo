import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../providers/shop_provider.dart';
import '../services/storage_service.dart';

import '../widgets/character_painter.dart';
import '../widgets/coin_badge.dart';
import '../widgets/carnival.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String _selectedCategory = 'headwear';

  IconData _categoryIcon(String category) => switch (category) {
    'headwear' => Icons.school,
    'tops' => Icons.checkroom,
    'bottoms' => Icons.dry_cleaning,
    'shoes' => Icons.ice_skating,
    'glasses' => Icons.visibility,
    'bags' => Icons.backpack,
    'effects' => Icons.auto_awesome,
    'hair' => Icons.face_retouching_natural,
    _ => Icons.stars,
  };

  static const _categories = [
    'headbands',
    'hair',
    'headwear',
    'tops',
    'bottoms',
    'shoes',
    'glasses',
    'accessories',
    'bags',
    'effects',
    'special',
  ];

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'rare':
        return const Color(0xFF38BDF8);
      case 'epic':
        return const Color(0xFFA855F7);
      case 'legendary':
        return const Color(0xFFFFD54F);
      default:
        return const Color(0xFFA3A3A3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);
    final items = StorageService.allShopItems
        .where((i) => i.category == _selectedCategory)
        .toList();

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('SHOP'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CoinBadge(coins: appState.profile?.coins ?? 0),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8E1), Color(0xFFFFF8E1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const CarnivalRibbon('Pick a reward'),
            // Category tabs
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF8C00)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          cat[0].toUpperCase() + cat.substring(1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF737373),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Items grid
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        'No items in this category yet!',
                        style: TextStyle(color: Color(0xFFA3A3A3)),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            mainAxisExtent: 220,
                          ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isOwned = ref
                            .read(shopProvider.notifier)
                            .isOwned(item.id);
                        final isEquipped = ref
                            .read(shopProvider.notifier)
                            .isEquipped(item.id);
                        final canAfford =
                            (appState.profile?.coins ?? 0) >= item.price;

                        return GestureDetector(
                          onTap: () async {
                            if (!isOwned) {
                              final success = await ref
                                  .read(shopProvider.notifier)
                                  .buyItem(item.id);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Bought ${item.name}!'),
                                    backgroundColor: const Color(0xFF4CAF50),
                                  ),
                                );
                              }
                            } else {
                              await ref
                                  .read(shopProvider.notifier)
                                  .equipItem(item.id, item.category);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isEquipped
                                    ? const Color(0xFFFF8C00)
                                    : _rarityColor(
                                        item.rarity,
                                      ).withValues(alpha: 0.3),
                                width: isEquipped ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (item.icon != null)
                                  Text(
                                    item.icon!,
                                    style: const TextStyle(fontSize: 32),
                                  )
                                else
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(
                                        CharacterPainter.resolveColor(
                                          item.colorName,
                                        ),
                                      ).withValues(alpha: 0.12),
                                    ),
                                    child: Icon(_categoryIcon(item.category), size: 48,
                                      color: Color(CharacterPainter.resolveColor(item.colorName))),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.rarity[0].toUpperCase() +
                                      item.rarity.substring(1),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _rarityColor(item.rarity),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (isEquipped)
                                  const Text(
                                    'Equipped',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFFF8C00),
                                    ),
                                  )
                                else if (isOwned)
                                  const Text(
                                    'Owned',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  )
                                else
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '🪙',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${item.price}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: canAfford
                                              ? const Color(0xFF854D0E)
                                              : const Color(0xFFFF5252),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
