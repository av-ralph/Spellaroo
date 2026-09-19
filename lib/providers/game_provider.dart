import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/word.dart';
import '../services/storage_service.dart';
import '../config/constants.dart';

enum GameStatus { loading, intro, playing, correct, wrong, revealed, complete }

class GameState {
  final List<Word> words;
  final String category;
  final int levelId;
  final int wordIndex;
  final int attemptNumber;
  final List<String> selectedIds;
  final GameStatus status;
  final int correctCount;
  final int totalCoins;
  final String? feedbackMessage;

  GameState({
    this.words = const [],
    this.category = 'easy',
    this.levelId = 0,
    this.wordIndex = 0,
    this.attemptNumber = 1,
    this.selectedIds = const [],
    this.status = GameStatus.loading,
    this.correctCount = 0,
    this.totalCoins = 0,
    this.feedbackMessage,
  });

  Word? get currentWord => wordIndex < words.length ? words[wordIndex] : null;

  bool get isGameComplete => wordIndex >= words.length;

  double get accuracy => words.isEmpty ? 0 : correctCount / words.length;

  GameState copyWith({
    List<Word>? words,
    String? category,
    int? levelId,
    int? wordIndex,
    int? attemptNumber,
    List<String>? selectedIds,
    GameStatus? status,
    int? correctCount,
    int? totalCoins,
    String? feedbackMessage,
    bool clearFeedback = false,
  }) {
    return GameState(
      words: words ?? this.words,
      category: category ?? this.category,
      levelId: levelId ?? this.levelId,
      wordIndex: wordIndex ?? this.wordIndex,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      selectedIds: selectedIds ?? this.selectedIds,
      status: status ?? this.status,
      correctCount: correctCount ?? this.correctCount,
      totalCoins: totalCoins ?? this.totalCoins,
      feedbackMessage: clearFeedback
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(GameState());

  void startGame(String category, int levelId) {
    List<Word> words;
    if (category == 'random') {
      final allWords = StorageService.allWords;
      final shuffled = List<Word>.from(allWords)..shuffle();
      words = shuffled.take(25).toList();
    } else {
      words = StorageService.getWordsForLevel(levelId);
    }
    state = GameState(
      words: words,
      category: category,
      levelId: levelId,
      status: GameStatus.intro,
    );
  }

  void beginPlaying() {
    if (state.status != GameStatus.intro && state.status != GameStatus.wrong) {
      return;
    }
    state = state.copyWith(status: GameStatus.playing);
  }

  void selectLetter(String nodeId) {
    if (state.status != GameStatus.playing) return;
    final newSelected = List<String>.from(state.selectedIds);
    if (newSelected.contains(nodeId)) {
      newSelected.remove(nodeId);
    } else {
      newSelected.add(nodeId);
    }
    state = state.copyWith(selectedIds: newSelected, clearFeedback: true);
  }

  void removeLastLetter() {
    if (state.status != GameStatus.playing) return;
    if (state.selectedIds.isEmpty) return;
    final newSelected = List<String>.from(state.selectedIds);
    newSelected.removeLast();
    state = state.copyWith(selectedIds: newSelected);
  }

  void checkSpelling(List<MapEntry<String, String>> nodes) {
    if (state.currentWord == null || state.status != GameStatus.playing) return;
    final targetWord = state.currentWord!.word.toUpperCase();

    // Build answer string from selected IDs by looking up letters in nodes
    final selectedNodeMap = {for (final n in nodes) n.key: n.value};
    final answer = state.selectedIds
        .map((id) => selectedNodeMap[id] ?? '')
        .join();

    if (answer.length != targetWord.length) {
      state = state.copyWith(
        feedbackMessage: 'Connect all ${targetWord.length} letters!',
      );
      return;
    }

    final correct = answer.toUpperCase() == targetWord;
    final newAttempts = state.attemptNumber;

    if (correct) {
      final coins = AppConstants.coinsForAttempt(state.category, newAttempts);
      debugPrint(
        'checkSpelling: CORRECT! category=${state.category} attempt=$newAttempts coins=$coins totalCoins=${state.totalCoins + coins}',
      );
      state = state.copyWith(
        status: GameStatus.correct,
        correctCount: state.correctCount + 1,
        totalCoins: state.totalCoins + coins,
        feedbackMessage: 'Correct! +$coins coins',
      );
    } else {
      if (newAttempts >= AppConstants.maxAttempts) {
        state = state.copyWith(
          status: GameStatus.revealed,
          feedbackMessage:
              'The word is ${state.currentWord!.word.toUpperCase()}',
        );
      } else {
        state = state.copyWith(
          status: GameStatus.wrong,
          attemptNumber: newAttempts + 1,
          selectedIds: [],
          feedbackMessage: AppConstants.randomEncouragement(),
        );
      }
    }
  }

  void nextWord() {
    if (state.status != GameStatus.correct &&
        state.status != GameStatus.revealed) {
      return;
    }
    final nextIndex = state.wordIndex + 1;
    if (nextIndex >= state.words.length) {
      state = state.copyWith(wordIndex: nextIndex, status: GameStatus.complete);
      return;
    }
    state = state.copyWith(
      wordIndex: nextIndex,
      attemptNumber: 1,
      selectedIds: [],
      status: GameStatus.playing,
      clearFeedback: true,
    );
  }

  void resetGame() {
    state = GameState();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});
