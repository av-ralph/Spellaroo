import '../config/wardrobe_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../providers/shop_provider.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/character_portrait.dart';
import '../widgets/character_painter.dart';
import '../widgets/coin_badge.dart';
import '../widgets/adventure_scaffold.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});
  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String _selectedCategory = 'headwear';
  int? _busyItem;
  static const _categories = wardrobeCategories;
  IconData _icon(String category) => switch (category) {
    'headwear' => Icons.school_rounded,
    'tops' => Icons.checkroom_rounded,
    'bottoms' => Icons.dry_cleaning_rounded,
    'headbands' => Icons.workspace_premium_rounded,
    'glasses' => Icons.visibility_rounded,
    'hair' => Icons.face_retouching_natural,
    'shoes' => Icons.ice_skating_rounded,
    'bags' => Icons.backpack_rounded,
    _ => Icons.auto_awesome_rounded,
  };
  Color _rarity(String value) => switch (value) {
    'rare' => const Color(0xFF168DB4),
    'epic' => const Color(0xFF8651CC),
    'legendary' => const Color(0xFFB87909),
    _ => const Color(0xFF647982),
  };
  Future<void> _choose(int id, String category, String name, bool owned) async {
    if (_busyItem != null) return;
    setState(() => _busyItem = id);
    AudioService.playClick();
    try {
      final shop = ref.read(shopProvider.notifier);
      if (owned) {
        await shop.equipItem(id, category);
      } else {
        final bought = await shop.buyItem(id);
        if (mounted && bought) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name is yours! Your buddy is wearing it now.'),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busyItem = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final coins = state.profile?.coins ?? 0;
    final items = StorageService.allShopItems
        .where((item) => item.category == _selectedCategory)
        .toList();
    return AdventureScaffold(
      appBar: AppBar(
        title: const Text('Treasure shop'),
        leading: IconButton(
          tooltip: 'Back home',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: CoinBadge(coins: coins),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  const AdventureIntro(
                    title: 'A little reward, a lot of you.',
                    subtitle:
                        'Earn coins by spelling. Find a new favorite for your buddy.',
                    icon: Icons.shopping_bag_rounded,
                    color: Color(0xFFBE7709),
                  ),
                  Container(
                    height: 180,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [Colors.white, Color(0xFFFFF0C0)],
                        radius: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFFFD141),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: CharacterPortrait(
                              key: const ValueKey('shop-preview'),
                              characterKey:
                                  state.profile?.characterKey ?? 'kangaroo',
                              equippedByCategory: state.equippedByCategory,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: TextButton.icon(
                            onPressed: () => context.go('/character/customize'),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.8,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.checkroom, size: 18),
                            label: const Text(
                              'My Wardrobe',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: _categories.entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(entry.value),
                          avatar: Icon(_icon(entry.key), size: 18),
                          selected: _selectedCategory == entry.key,
                          showCheckmark: false,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = entry.key),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          if (items.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'New treasures are on their way. Try another category.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) => SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (constraints.crossAxisExtent / 170)
                      .floor()
                      .clamp(1, 4),
                  mainAxisExtent:
                      254 *
                      MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  final entry = state.inventory
                      .where((entry) => entry.itemId == item.id)
                      .firstOrNull;
                  final owned = entry != null;
                  final equipped = entry?.equipped ?? false;
                  final affordable = coins >= item.price;
                  final color = Color(
                    CharacterPainter.resolveColor(item.colorName),
                  );
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFEF8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: equipped
                            ? const Color(0xFF20AB83)
                            : Colors.white,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x120B4553),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              gradient: LinearGradient(
                                colors: [
                                  color.withValues(alpha: .08),
                                  color.withValues(alpha: .2),
                                ],
                              ),
                            ),
                            child: CharacterPortrait(
                              characterKey:
                                  state.profile?.characterKey ?? 'kangaroo',
                              equippedByCategory: {
                                ...state.equippedByCategory,
                                item.category: Equipment(
                                  name: item.name,
                                  colorName: item.colorName,
                                ),
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.rarity.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                            color: _rarity(item.rarity),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 40),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            onPressed:
                                equipped ||
                                    _busyItem != null ||
                                    (!owned && !affordable)
                                ? null
                                : () => _choose(
                                    item.id,
                                    item.category,
                                    item.name,
                                    owned,
                                  ),
                            child: Text(
                              _busyItem == item.id
                                  ? 'Saving…'
                                  : equipped
                                  ? 'Wearing ✓'
                                  : owned
                                  ? 'Wear'
                                  : '${item.price} coins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }, childCount: items.length),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
