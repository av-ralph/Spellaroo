import '../services/game_service.dart';

class LetterPositions {
  static List<LetterNode> calculate(String word, {double radius = 155}) {
    return GameService.buildLetterNodes(word, radius: radius);
  }
}
