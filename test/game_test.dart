import 'package:flutter_test/flutter_test.dart';
import 'package:spellaroo/models/word.dart';
import 'package:spellaroo/providers/game_provider.dart';
import 'package:spellaroo/services/game_service.dart';

class FixtureGame extends GameNotifier {
  FixtureGame() {
    state = GameState(
      status: GameStatus.intro,
      words: [
        Word(id: 1, word: 'APPLE', category: 'easy', difficulty: 'easy'),
        Word(id: 2, word: 'BOOK', category: 'easy', difficulty: 'easy'),
      ],
    );
  }
}

void main() {
  test('Duplicate letters have unique, stable identities across shuffles', () {
    final first = GameService.buildLetterNodes('APPLE');
    final second = GameService.buildLetterNodes('APPLE');
    expect(first.map((n) => n.id).toSet().length, 5);
    expect(
      {for (final n in first) n.id: n.letter},
      {for (final n in second) n.id: n.letter},
    );
  });
  test('Correct answers score once and next word clears feedback', () {
    final game = FixtureGame();
    addTearDown(game.dispose);
    game.beginPlaying();
    final nodes = GameService.buildLetterNodes('APPLE')
      ..sort((a, b) => a.wordIndex.compareTo(b.wordIndex));
    for (final node in nodes) {
      game.selectLetter(node.id);
    }
    final entries = nodes.map((n) => MapEntry(n.id, n.letter)).toList();
    game.checkSpelling(entries);
    game.checkSpelling(entries);
    expect(game.state.correctCount, 1);
    expect(game.state.totalCoins, 3);
    game.nextWord();
    expect(game.state.currentWord!.word, 'BOOK');
    expect(game.state.selectedIds, isEmpty);
    expect(game.state.feedbackMessage, isNull);
  });
  test('Three wrong attempts reveal answer and allow progression', () {
    final game = FixtureGame();
    addTearDown(game.dispose);
    game.beginPlaying();
    final nodes = GameService.buildLetterNodes('APPLE')
      ..sort((a, b) => b.wordIndex.compareTo(a.wordIndex));
    for (var attempt = 1; attempt <= 3; attempt++) {
      for (final node in nodes) {
        game.selectLetter(node.id);
      }
      game.checkSpelling(nodes.map((n) => MapEntry(n.id, n.letter)).toList());
      expect(
        game.state.status,
        attempt == 3 ? GameStatus.revealed : GameStatus.wrong,
      );
      if (attempt < 3) game.beginPlaying();
    }
    game.nextWord();
    expect(game.state.status, GameStatus.playing);
    expect(game.state.wordIndex, 1);
    expect(game.state.totalCoins, 0);
  });
}
