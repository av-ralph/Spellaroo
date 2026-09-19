import '../config/wardrobe_categories.dart';
import '../widgets/adventure_scaffold.dart';
import 'dart:math' as math;
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
import '../config/theme.dart';

class CharacterCustomizeScreen extends ConsumerStatefulWidget {
  const CharacterCustomizeScreen({super.key});
  @override
  ConsumerState<CharacterCustomizeScreen> createState() =>
      _CharacterCustomizeScreenState();
}

class _CharacterCustomizeScreenState
    extends ConsumerState<CharacterCustomizeScreen> {
  String _category = 'tops';
  bool _saving = false;
  static const _categories = wardrobeCategories;
  Future<void> _wear(int? id) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final shop = ref.read(shopProvider.notifier);
      if (id == null) {
        await shop.unequipCategory(_category);
      } else {
        await shop.equipItem(id, _category);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your outfit. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final character = state.profile?.characterKey ?? 'kangaroo';
    final equipment = state.equippedByCategory;
    final ownedIds = state.inventory.map((e) => e.itemId).toSet();
    final items = StorageService.allShopItems
        .where(
          (item) => item.category == _category && ownedIds.contains(item.id),
        )
        .toList();
    final selected = state.inventory
        .where((entry) => entry.equipped)
        .map((e) => e.itemId)
        .toSet();
    return AdventureScaffold(
      appBar: AppBar(
        title: const Text('MY WARDROBE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AudioService.playClick();
            context.go('/home');
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CoinBadge(coins: state.profile?.coins ?? 0),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    const AdventureIntro(
                      title: 'Ready for your next adventure?',
                      subtitle:
                          'Pick a favorite outfit. Your buddy wears it back home, too.',
                      icon: Icons.checkroom_rounded,
                      color: Color(0xFF8651CC),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [Colors.white, Color(0xFFFFE7A0)],
                          radius: .85,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppTheme.gold, width: 2),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                18,
                                12,
                                12,
                              ),
                              child: SizedBox(
                                height: math.min(
                                  MediaQuery.sizeOf(context).height * .31,
                                  260,
                                ),
                                child: CharacterPortrait(
                                  key: const ValueKey('wardrobe-preview'),
                                  characterKey: character,
                                  equippedByCategory: equipment,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: IconButton(
                              tooltip: 'Choose another buddy',
                              onPressed: () => context.go('/character/select'),
                              icon: const Icon(Icons.swap_horiz),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            bottom: 12,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _saving
                                          ? Icons.hourglass_top
                                          : Icons.check_circle,
                                      color: AppTheme.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _saving ? 'Saving...' : 'Outfit saved',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Make it yours!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Text(
                      'Tap a piece to wear it. Your outfit saves automatically.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppTheme.ink),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.entries
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  key: ValueKey('wardrobe-tab-${entry.key}'),
                                  label: Text(entry.value),
                                  selected: _category == entry.key,
                                  onSelected: _saving
                                      ? null
                                      : (_) => setState(
                                          () => _category = entry.key,
                                        ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'My ${_categories[_category]!.toLowerCase()}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => context.go('/shop'),
                          icon: const Icon(Icons.add_shopping_cart, size: 17),
                          label: const Text('Get more'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = index == 0 ? null : items[index - 1];
                  final active = item == null
                      ? !equipment.containsKey(_category)
                      : selected.contains(item.id);
                  final preview = <String, Equipment>{...equipment}
                    ..remove(_category);
                  if (item != null) {
                    preview[_category] = Equipment(
                      name: item.name,
                      colorName: item.colorName,
                    );
                  }
                  return Semantics(
                    button: true,
                    selected: active,
                    label: item?.name ?? 'Original outfit',
                    child: Material(
                      color: active ? const Color(0xFFFFEDB1) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        key: ValueKey('wear-${item?.id ?? _category}'),
                        borderRadius: BorderRadius.circular(18),
                        onTap: _saving ? null : () => _wear(item?.id),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: active
                                  ? AppTheme.orange
                                  : const Color(0xFFEADDBA),
                              width: active ? 2 : 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(9),
                          child: Column(
                            children: [
                              Expanded(
                                child: CharacterPortrait(
                                  characterKey: character,
                                  equippedByCategory: preview,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item?.name ?? 'Original',
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (active)
                                    const Icon(
                                      Icons.check_circle,
                                      size: 13,
                                      color: AppTheme.green,
                                    ),
                                  if (active) const SizedBox(width: 4),
                                  Text(
                                    active
                                        ? 'Wearing'
                                        : item?.isStarter == true
                                        ? 'Free starter'
                                        : 'Tap to wear',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: active
                                          ? const Color(0xFF26732C)
                                          : AppTheme.brown,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: items.length + 1),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 165,
                  mainAxisExtent: 174,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
