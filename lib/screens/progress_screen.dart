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
    return Scaffold(
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
            const CarnivalPennants(),
            const CarnivalRibbon('Look how far you have come!'),
            const Icon(
              Icons.emoji_events_rounded,
              color: AppTheme.orange,
              size: 72,
            ),
            Text(
              attempted == 0
                  ? 'Your adventure starts here'
                  : 'Every practice counts!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 18),
            ...[
              (
                label: 'Accuracy',
                value:
                    '${attempted == 0 ? 0 : (correct / attempted * 100).round()}%',
                icon: Icons.track_changes,
                color: AppTheme.green,
              ),
              (
                label: 'Levels completed',
                value: '$completed / ${StorageService.allLevels.length}',
                icon: Icons.flag,
                color: AppTheme.blue,
              ),
              (
                label: 'Words practiced',
                value: '$attempted',
                icon: Icons.menu_book,
                color: AppTheme.purple,
              ),
              (
                label: 'Correct words',
                value: '$correct',
                icon: Icons.check_circle,
                color: AppTheme.orange,
              ),
            ].map(
              (stat) => Card(
                child: ListTile(
                  leading: Icon(stat.icon, color: stat.color, size: 30),
                  title: Text(stat.label),
                  trailing: Text(
                    stat.value,
                    style: TextStyle(
                      fontFamily: 'Baloo2',
                      fontSize: 24,
                      color: stat.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
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
