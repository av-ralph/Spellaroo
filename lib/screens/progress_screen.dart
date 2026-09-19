import '../widgets/adventure_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/carnival.dart';
import '../config/theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final progress = StorageService.getLevelProgressList();
    final missed = StorageService.getMissedWords()
      ..sort((a, b) => b.missCount.compareTo(a.missCount));
    final attempted = progress.fold(0, (sum, p) => sum + p.wordsAttempted);
    final correct = progress.fold(0, (sum, p) => sum + p.wordsCorrect);
    final completed = progress.where((p) => p.completed).length;
    final words = {
      for (final word in StorageService.allWords) word.id: word.word,
    };
    return AdventureScaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('YOUR PROGRESS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AudioService.playClick();
            context.go('/home');
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            AdventureIntro(
              title: attempted == 0
                  ? 'Your story starts here'
                  : 'Look how far you have come!',
              subtitle:
                  'Every word is a little win. Keep your adventure growing.',
              icon: Icons.emoji_events_rounded,
              color: const Color(0xFF109E84),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final stats = [
                  (
                    'Accuracy',
                    '${attempted == 0 ? 0 : (correct / attempted * 100).round()}%',
                    Icons.track_changes,
                    AppTheme.green,
                  ),
                  (
                    'Levels completed',
                    '$completed / ${StorageService.allLevels.length}',
                    Icons.flag_rounded,
                    AppTheme.blue,
                  ),
                  (
                    'Words practiced',
                    '$attempted',
                    Icons.menu_book_rounded,
                    AppTheme.purple,
                  ),
                  (
                    'Correct words',
                    '$correct',
                    Icons.check_circle_rounded,
                    AppTheme.orange,
                  ),
                ];
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: stats
                      .map(
                        (stat) => SizedBox(
                          width: constraints.maxWidth < 260
                              ? constraints.maxWidth
                              : constraints.maxWidth > 600
                                  ? (constraints.maxWidth - 36) / 4
                                  : (constraints.maxWidth - 12) / 2,
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: stat.$4.withValues(alpha: .2),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(stat.$3, color: stat.$4, size: 29),
                                const SizedBox(height: 10),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    stat.$2,
                                    style: TextStyle(
                                      fontFamily: 'Baloo2',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 30,
                                      height: 1.1,
                                      color: stat.$4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  stat.$1,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const CarnivalRibbon('Words to practice'),
            if (missed.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Text(
                    attempted == 0
                        ? 'Play a level to start collecting your progress.'
                        : 'Great work! No missed words to review.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...missed.map(
                (word) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.auto_stories,
                      color: AppTheme.coral,
                    ),
                    title: Text(
                      words[word.wordId] ?? 'Word ${word.wordId}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    trailing: Text(
                      '${word.missCount}×',
                      style: const TextStyle(color: AppTheme.brown),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            CarnivalButton(
              label: 'Keep practicing',
              icon: Icons.play_arrow,
              onPressed: () => context.go('/play'),
            ),
          ],
        ),
      ),
    );
  }
}
