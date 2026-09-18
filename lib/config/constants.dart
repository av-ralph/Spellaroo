class AppConstants {
  AppConstants._();

  static const Map<String, List<int>> coinsPerAttempt = {
    'easy': [3, 2, 1],
    'medium': [5, 3, 2],
    'hard': [7, 5, 3],
    'random': [10, 8, 4],
  };

  static const Map<String, String> categoryColors = {
    'easy': 'from-lime-400 to-green-500',
    'medium': 'from-amber-400 to-orange-500',
    'hard': 'from-rose-400 to-red-500',
    'random': 'from-violet-400 to-fuchsia-500',
  };

  static const Map<String, String> categoryLabels = {
    'easy': 'Easy',
    'medium': 'Medium',
    'hard': 'Hard',
    'random': 'Random',
  };

  static const List<String> encouragements = [
    'Almost! Check the letters and try again.',
    'So close! Give it another go.',
    'Nice try! You\'ve got this.',
    'Keep going, speller!',
    'Not quite — try connecting the letters again.',
  ];

  static const int maxAttempts = 3;

  static int coinsForAttempt(String difficulty, int attempt) {
    final tiers = coinsPerAttempt[difficulty] ?? coinsPerAttempt['easy']!;
    if (attempt < 1 || attempt > 3) return 0;
    return tiers[attempt - 1];
  }

  static String randomEncouragement() {
    final idx = DateTime.now().microsecondsSinceEpoch % encouragements.length;
    return encouragements[idx];
  }
}
