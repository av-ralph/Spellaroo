import '../widgets/adventure_scaffold.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';
import '../providers/app_provider.dart';
import '../services/audio_service.dart';
import '../services/game_service.dart';
import '../services/storage_service.dart';
import '../models/level_progress.dart';
import '../widgets/game_canvas.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String category;
  final int levelId;
  const GameScreen({super.key, required this.category, this.levelId = 0});
  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Future<void>? _saving;
  final Set<int> _missed = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _start();
    });
  }

  void _start() {
    AudioService.playBgm('assets/sounds/bgm/gameplay.mp3');
    _saving = null;
    _missed.clear();
    ref.read(gameProvider.notifier).startGame(widget.category, widget.levelId);
  }

  void _leave() {
    final state = ref.read(gameProvider);
    final inProgress =
        state.status == GameStatus.playing || state.status == GameStatus.wrong;
    if (inProgress) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Leave game?'),
          content: const Text(
            'Your progress and coins in this session will be lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                AudioService.stopBgm();
                context.go(
                  widget.category == 'random'
                      ? '/home'
                      : '/play/${widget.category}',
                );
              },
              child: const Text('Leave', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      AudioService.stopBgm();
      context.go(
        widget.category == 'random' ? '/home' : '/play/${widget.category}',
      );
    }
  }

  Future<void> _save(GameState state) async {
    final appNotifier = ref.read(appProvider.notifier);
    final missedToSave = _missed.toList();
    try {
      await StorageService.recordMissedWords(missedToSave);
      _missed.clear();
    } catch (e) {
      debugPrint('Failed to record missed words: $e');
    }
    if (widget.category != 'random') {
      try {
        final old = StorageService.getLevelProgress(widget.levelId);
        final passed = state.accuracy >= 0.8;
        final stars = passed
            ? (state.accuracy >= 0.95
                  ? 3
                  : state.accuracy >= 0.85
                  ? 2
                  : 1)
            : 0;
        final best = max(old?.accuracy ?? 0.0, state.accuracy);
        await StorageService.saveLevelProgress(
          LevelProgress(
            levelId: widget.levelId,
            completed: passed || (old?.completed ?? false),
            unlocked: true,
            stars: max(old?.stars ?? 0, stars),
            accuracy: best,
            wordsAttempted: state.words.length,
            wordsCorrect: max(old?.wordsCorrect ?? 0, state.correctCount),
          ),
        );
        if (passed) {
          final levels =
              StorageService.allLevels
                  .where((l) => l.category == widget.category)
                  .toList()
                ..sort((a, b) => a.id.compareTo(b.id));
          final index = levels.indexWhere((l) => l.id == widget.levelId);
          if (index >= 0 && index + 1 < levels.length) {
            final nextId = levels[index + 1].id;
            final next =
                StorageService.getLevelProgress(nextId) ??
                LevelProgress(levelId: nextId);
            await StorageService.saveLevelProgress(
              next.copyWith(unlocked: true),
            );
          }
        }
      } catch (e) {
        debugPrint('Failed to save level progress: $e');
      }
    }
    if (state.totalCoins > 0) {
      debugPrint('_save: adding ${state.totalCoins} coins');
      await appNotifier.addCoins(state.totalCoins);
      debugPrint('_save: coins added successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    ref.listen<GameState>(gameProvider, (previous, next) {
      if (previous?.status == next.status) return;
      if (next.status == GameStatus.correct) {
        AudioService.playCorrect();
        _missed.remove(next.currentWord!.id);
      }
      if (next.status == GameStatus.wrong ||
          next.status == GameStatus.revealed) {
        AudioService.playWrong();
        _missed.add(next.currentWord!.id);
      }
      if (next.status == GameStatus.complete) {
        AudioService.stopBgm();
        _saving = _save(next);
      }
    });
    if (state.status == GameStatus.loading) {
      return const AdventureScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.words.isEmpty) {
      return AdventureScaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No words are available for this level.'),
                TextButton(onPressed: _leave, child: const Text('Back')),
              ],
            ),
          ),
        ),
      );
    }
    if (state.status == GameStatus.intro) return _intro(state);
    if (state.status == GameStatus.complete) return _results(state);
    return _playing(state);
  }

  Widget _intro(GameState state) => AdventureScaffold(
    backgroundColor: const Color(0xFFFFF8E1),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 72,
                color: Color(0xFFFFB800),
              ),
              const SizedBox(height: 20),
              Text(
                widget.category == 'random'
                    ? 'Random Challenge'
                    : '${widget.category.toUpperCase()} Challenge',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontFamily: 'Baloo2',
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text('${state.words.length} words • 3 tries per word'),
              const SizedBox(height: 12),
              const Text(
                'Listen to the word. Tap each letter in order, then check your spelling.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () {
                  AudioService.playButton();
                  ref.read(gameProvider.notifier).beginPlaying();
                },
                child: const Text('Start'),
              ),
              TextButton(
                onPressed: () {
                  AudioService.playClick();
                  _leave();
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _playing(GameState state) {
    final word = state.currentWord!;
    final nodes = GameService.buildLetterNodes(word.word);
    final letters = {for (final node in nodes) node.id: node.letter};
    final answer = state.selectedIds.map((id) => letters[id] ?? '').join();
    final active = state.status == GameStatus.playing;
    final retry = state.status == GameStatus.wrong;
    return AdventureScaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            AudioService.playClick();
            _leave();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text('Word ${state.wordIndex + 1} of ${state.words.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('Try ${state.attemptNumber}/3')),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final canvasSize = min(
              max(constraints.maxWidth - 32, 240.0),
              360.0,
            );
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: state.wordIndex / state.words.length,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    word.definition ?? 'Listen, then spell the word.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFCDE4DC),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      answer.isEmpty ? '${word.word.length} letters' : answer,
                      key: const ValueKey('spelling-answer'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontFamily: 'Baloo2',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: canvasSize,
                    height: canvasSize,
                    child: GameCanvas(
                      key: ValueKey(state.wordIndex),
                      word: word.word,
                      selectedIds: state.selectedIds,
                      enabled: active,
                      onLetterTap: (id) {
                        AudioService.playClick();
                        ref.read(gameProvider.notifier).selectLetter(id);
                      },
                    ),
                  ),
                  if (state.feedbackMessage != null)
                    Text(
                      state.feedbackMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: state.status == GameStatus.correct
                            ? const Color(0xFF147D45)
                            : const Color(0xFF955000),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Undo last letter',
                        onPressed: active
                            ? () => ref
                                  .read(gameProvider.notifier)
                                  .removeLastLetter()
                            : null,
                        icon: const Icon(Icons.backspace_outlined),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: 'Listen to the word',
                        onPressed: () => AudioService.speak(word.word),
                        icon: const Icon(Icons.volume_up),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            AudioService.playButton();
                            final game = ref.read(gameProvider.notifier);
                            if (retry) {
                              game.beginPlaying();
                            } else if (active) {
                              game.checkSpelling(
                                nodes
                                    .map((n) => MapEntry(n.id, n.letter))
                                    .toList(),
                              );
                            } else {
                              game.nextWord();
                            }
                          },
                          child: Text(
                            retry
                                ? 'Try again'
                                : active
                                ? 'Check'
                                : state.wordIndex + 1 == state.words.length
                                ? 'See results'
                                : 'Next word',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _results(GameState state) => AdventureScaffold(
    backgroundColor: const Color(0xFFFFF8E1),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 88,
                color: Color(0xFFFFB800),
              ),
              Text(
                state.accuracy >= 0.8
                    ? 'Challenge Complete!'
                    : 'Keep Practicing!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontFamily: 'Baloo2',
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${(state.accuracy * 100).round()}% accuracy',
                style: const TextStyle(fontSize: 24),
              ),
              Text('${state.correctCount} of ${state.words.length} correct'),
              const SizedBox(height: 12),
              Text(
                '+${state.totalCoins} coins',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              FutureBuilder<void>(
                future: _saving,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Column(
                      children: [
                        const Text(
                          'Your progress could not be saved. Please try again.',
                        ),
                        FilledButton(
                          onPressed: () =>
                              setState(() => _saving = _save(state)),
                          child: const Text('Retry saving'),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      FilledButton(
                        onPressed: _leave,
                        child: Text(
                          widget.category == 'random'
                              ? 'Back home'
                              : 'Back to levels',
                        ),
                      ),
                      TextButton(
                        onPressed: _start,
                        child: const Text('Play again'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
