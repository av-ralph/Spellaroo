import '../widgets/adventure_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/carnival.dart';
import '../config/theme.dart';

class CategoryLevelsScreen extends StatelessWidget {
  final String category;
  const CategoryLevelsScreen({super.key, required this.category});
  @override
  Widget build(BuildContext context) {
    final levels =
        StorageService.allLevels.where((l) => l.category == category).toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    final progress = {
      for (final p in StorageService.getLevelProgressList()) p.levelId: p,
    };
    return AdventureScaffold(
      appBar: AppBar(
        title: Text('${category.toUpperCase()} LEVELS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AudioService.playClick();
            context.go('/play');
          },
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  CarnivalPennants(),
                  CarnivalRibbon('Your next little victory'),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 145,
                  mainAxisExtent: 130,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final level = levels[index];
                  final saved = progress[level.id];
                  final unlocked = index == 0 || (saved?.unlocked ?? false);
                  return Material(
                    color: !unlocked
                        ? const Color(0xFFE4ECE9)
                        : saved?.completed == true
                        ? AppTheme.paleGold
                        : const Color(0xFFD9F5EA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                      side: BorderSide(
                        color: unlocked
                            ? const Color(0xFF3EB58E)
                            : const Color(0xFFB8C3BF),
                        width: 2,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: ValueKey('level-${level.id}'),
                      onTap: unlocked
                          ? () {
                              AudioService.playClick();
                              context.go('/play/$category/${level.id}');
                            }
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!unlocked)
                            const Icon(
                              Icons.lock_rounded,
                              color: AppTheme.brown,
                            )
                          else
                            Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontFamily: 'Baloo2',
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.ink,
                              ),
                            ),
                          if (saved?.completed == true) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                (i) => Icon(
                                  i < saved!.stars
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 17,
                                  color: const Color(0xFFB87900),
                                ),
                              ),
                            ),
                            Text(
                              '${(saved!.accuracy * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ] else
                            Text(
                              unlocked ? 'Play' : 'Locked',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.brown,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }, childCount: levels.length),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '${levels.length} levels • 25 words per level\nScore 80% to unlock the next level.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.brown),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
