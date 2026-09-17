import '../config/constants.dart';
import '../services/storage_service.dart';

class CoinUtils {
  static int coinsForAttempt(String difficulty, int attempt) {
    return AppConstants.coinsForAttempt(difficulty, attempt);
  }

  static int totalCoinsEarned() {
    return StorageService.getProfile()?.coins ?? 0;
  }

  static bool canAfford(int price) {
    final coins = StorageService.getProfile()?.coins ?? 0;
    return coins >= price;
  }
}
