import 'dart:math';
import '../models/word.dart';
import '../services/storage_service.dart';

class LetterNode {
  final String id;
  final String letter;
  final int wordIndex;
  final double x;
  final double y;

  LetterNode({
    required this.id,
    required this.letter,
    required this.wordIndex,
    required this.x,
    required this.y,
  });
}

class GameService {
  static List<LetterNode> buildLetterNodes(String word, {double radius = 155}) {
    final shuffled = _shuffle(
      word.toUpperCase().split('').asMap().entries.toList(),
    );
    final count = shuffled.length;
    final nodes = <LetterNode>[];

    for (var i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi - pi / 2;
      final originalIndex = shuffled[i].key;
      nodes.add(
        LetterNode(
          id: '$originalIndex-${shuffled[i].value}',
          letter: shuffled[i].value,
          wordIndex: originalIndex,
          x: radius * cos(angle),
          y: radius * sin(angle),
        ),
      );
    }

    return nodes;
  }

  static List<T> _shuffle<T>(List<T> items) {
    final rng = Random();
    final list = List<T>.from(items);
    for (var i = list.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
    return list;
  }

  static bool validateSpelling(List<int> selectedIndices, String targetWord) {
    if (selectedIndices.length != targetWord.length) return false;
    for (var i = 0; i < selectedIndices.length; i++) {
      if (String.fromCharCode(selectedIndices[i]) !=
          targetWord[i].toUpperCase()) {
        return false;
      }
    }
    return true;
  }

  static String normalizeSpelling(String input) {
    return input.trim().toLowerCase();
  }

  static Word? pickRandomWord(String difficulty) {
    return StorageService.getRandomWord(difficulty);
  }
}
