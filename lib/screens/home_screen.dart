import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';
import '../widgets/coin_badge.dart';
import '../widgets/character_portrait.dart';
import '../widgets/carnival.dart';
import '../config/theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(appProvider).profile;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final completed = StorageService.getLevelProgressList()
        .where((p) => p.completed)
        .length;
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('SPELLAROO'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CoinBadge(coins: profile.coins),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            const CarnivalPennants(),
            const CarnivalRibbon('Spell it. Learn it. Master it!'),
            Text(
              'Welcome, ${profile.nickname}!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 185,
              child: CharacterPortrait(
                characterKey: profile.characterKey ?? 'kangaroo',
                equippedByCategory: ref.watch(appProvider).equippedByCategory,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '★ $completed levels completed',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.brown,
                ),
              ),
            ),
            const SizedBox(height: 18),
            CarnivalButton(
              label: "Let's play",
              icon: Icons.play_arrow_rounded,
              onPressed: () => context.go('/play'),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    [
                      (
                        label: 'Shop',
                        path: '/shop',
                        icon: Icons.shopping_bag,
                        color: AppTheme.orange,
                      ),
                      (
                        label: 'Character',
                        path: '/character/customize',
                        icon: Icons.pets,
                        color: AppTheme.coral,
                      ),
                      (
                        label: 'Progress',
                        path: '/progress',
                        icon: Icons.bar_chart,
                        color: AppTheme.green,
                      ),
                      (
                        label: 'Parent',
                        path: '/parent',
                        icon: Icons.family_restroom,
                        color: AppTheme.purple,
                      ),
                    ].asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isCharacter = item.label == 'Character';

                      final container = isCharacter
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: item.color.withValues(alpha: 0.38),
                                    blurRadius: 18,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: CarnivalButton(
                                  label: item.label,
                                  icon: item.icon,
                                  color: item.color,
                                  onPressed: () => context.push(item.path),
                                ),
                              ),
                            )
                          : CarnivalButton(
                              label: item.label,
                              icon: item.icon,
                              color: item.color,
                              onPressed: () => context.push(item.path),
                            );

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 260 + (index * 90)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 10),
                            child: Transform.scale(
                              scale: 0.96 + (value * 0.04),
                              child: child,
                            ),
                          ),
                        ),
                        child: SizedBox(
                          width: constraints.maxWidth < 340
                              ? constraints.maxWidth
                              : (constraints.maxWidth - 12) / 2,
                          child: container,
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Every word is a little win.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.brown),
            ),
          ],
        ),
      ),
    );
  }
}

class CategorySelectScreen extends StatelessWidget {
  const CategorySelectScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('CHOOSE A CATEGORY'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/home'),
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          const CarnivalPennants(),
          const CarnivalRibbon('Pick your challenge'),
          const SizedBox(height: 16),
          ...[
            (
              key: 'easy',
              label: 'Easy',
              subtitle: 'Build your confidence',
              color: AppTheme.green,
              icon: Icons.eco,
            ),
            (
              key: 'medium',
              label: 'Medium',
              subtitle: 'Grow your word power',
              color: AppTheme.orange,
              icon: Icons.bolt,
            ),
            (
              key: 'hard',
              label: 'Hard',
              subtitle: 'Take on a challenge',
              color: AppTheme.red,
              icon: Icons.local_fire_department,
            ),
            (
              key: 'random',
              label: 'Random',
              subtitle: 'A surprise mix of words',
              color: AppTheme.purple,
              icon: Icons.shuffle,
            ),
          ].map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  CarnivalButton(
                    label: c.label,
                    color: c.color,
                    icon: c.icon,
                    onPressed: () => context.go('/play/${c.key}'),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    c.subtitle,
                    style: const TextStyle(color: AppTheme.brown),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 130,
            child: CharacterPortrait(characterKey: 'kangaroo'),
          ),
        ],
      ),
    ),
  );
}
