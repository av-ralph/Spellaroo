import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/profile.dart';
import '../models/word.dart';
import '../models/level.dart';
import '../models/category.dart';
import '../models/shop_item.dart';
import '../models/inventory_entry.dart';
import '../models/level_progress.dart';
import '../models/missed_word.dart';

class StorageService {
  static late Box _profileBox;
  static late Box _inventoryBox;
  static late Box _progressBox;
  static late Box _missedWordsBox;

  static List<Word> _allWords = [];
  static List<Level> _allLevels = [];
  static List<GameCategory> _allCategories = [];
  static List<ShopItem> _allShopItems = [];

  static Future<void> init() async {
    _profileBox = await Hive.openBox('profile');
    _inventoryBox = await Hive.openBox('inventory');
    _progressBox = await Hive.openBox('progress');
    _missedWordsBox = await Hive.openBox('missedWords');
    await _loadBundledData();
    final inventory = getInventory();
    for (final item in _allShopItems.where((item) => item.isStarter)) {
      if (!inventory.any((entry) => entry.itemId == item.id)) {
        inventory.add(InventoryEntry(itemId: item.id));
      }
    }
    await saveInventory(inventory);
  }

  static Future<void> _loadBundledData() async {
    final wordsJson = await rootBundle.loadString('assets/data/words.json');
    _allWords = (json.decode(wordsJson) as List)
        .map((e) => Word.fromJson(e))
        .toList();

    final levelsJson = await rootBundle.loadString('assets/data/levels.json');
    _allLevels = (json.decode(levelsJson) as List)
        .map((e) => Level.fromJson(e))
        .toList();

    final categoriesJson = await rootBundle.loadString(
      'assets/data/categories.json',
    );
    _allCategories = (json.decode(categoriesJson) as List)
        .map((e) => GameCategory.fromJson(e))
        .toList();

    final shopJson = await rootBundle.loadString(
      'assets/data/shop_catalog.json',
    );
    _allShopItems = (json.decode(shopJson) as List)
        .map((e) => ShopItem.fromJson(e))
        .toList();
  }

  static List<Word> get allWords => _allWords;
  static List<Level> get allLevels => _allLevels;
  static List<GameCategory> get allCategories => _allCategories;
  static List<ShopItem> get allShopItems => _allShopItems;

  static List<Word> getWordsForDifficulty(String difficulty) {
    return _allWords.where((w) => w.difficulty == difficulty).toList();
  }

  static List<Word> getWordsForCategory(String category) {
    return _allWords.where((w) => w.category == category).toList();
  }

  static List<Word> getWordsForLevel(int levelId) {
    final level = _allLevels.firstWhere(
      (l) => l.id == levelId,
      orElse: () => _allLevels.first,
    );
    final categoryWords = _allWords
        .where((w) => w.difficulty == level.difficulty)
        .toList();
    if (categoryWords.isEmpty) return [];

    // Real app: 30 levels per category, each with 25 words cycling the 100-word pool
    // with a rotating offset per level so consecutive levels don't start on the same word.
    // Level number within category (1-30):
    final levelsInCategory =
        _allLevels.where((l) => l.difficulty == level.difficulty).toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    final levelNumber = levelsInCategory.indexWhere((l) => l.id == levelId) + 1;

    final cnt = categoryWords.length;
    final result = <Word>[];
    for (var n = 1; n <= 25; n++) {
      // Real SQL: ((level_number - 1) * 7 + n - 1) % cnt
      final idx = ((levelNumber - 1) * 7 + n - 1) % cnt;
      result.add(categoryWords[idx]);
    }
    return result;
  }

  static Word? getRandomWord(String difficulty) {
    final words = getWordsForDifficulty(difficulty);
    if (words.isEmpty) return null;
    final rng = Random();
    return words[rng.nextInt(words.length)];
  }

  static ShopItem? getShopItem(int id) {
    try {
      return _allShopItems.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  // Profile
  static Profile? getProfile() {
    final data = _profileBox.get('current');
    if (data == null) return null;
    return Profile.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<void> saveProfile(Profile profile) async {
    await _profileBox.put('current', profile.toJson());
  }

  static Future<void> deleteProfile() async {
    await _profileBox.delete('current');
  }

  // Inventory
  static List<InventoryEntry> getInventory() {
    final data = _inventoryBox.get('items');
    if (data == null) return [];
    return (data as List)
        .map((e) => InventoryEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> saveInventory(List<InventoryEntry> inventory) async {
    await _inventoryBox.put('items', inventory.map((e) => e.toJson()).toList());
  }

  static Future<void> purchaseItem(int itemId) async {
    final inventory = getInventory();
    if (!inventory.any((e) => e.itemId == itemId)) {
      inventory.add(InventoryEntry(itemId: itemId));
      await saveInventory(inventory);
    }
  }

  static Future<void> equipItem(int itemId, String category) async {
    final inventory = getInventory();
    final requested = getShopItem(itemId);
    if (requested == null ||
        requested.category != category ||
        !inventory.any((entry) => entry.itemId == itemId)) {
      return;
    }
    for (var index = 0; index < inventory.length; index++) {
      final entry = inventory[index];
      final item = getShopItem(entry.itemId);
      if (item != null && item.category == category) {
        if (entry.itemId == itemId) {
          inventory[index] = entry.copyWith(equipped: true);
        } else {
          inventory[index] = entry.copyWith(equipped: false);
        }
      }
    }
    await saveInventory(inventory);
  }

  static Future<void> unequipCategory(String category) async {
    await saveInventory(
      getInventory()
          .map(
            (entry) => getShopItem(entry.itemId)?.category == category
                ? entry.copyWith(equipped: false)
                : entry,
          )
          .toList(),
    );
  }

  // Level Progress
  static List<LevelProgress> getLevelProgressList() {
    final data = _progressBox.get('levels');
    if (data == null) return [];
    return (data as List)
        .map((e) => LevelProgress.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static LevelProgress? getLevelProgress(int levelId) {
    final list = getLevelProgressList();
    try {
      return list.firstWhere((p) => p.levelId == levelId);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveLevelProgress(LevelProgress progress) async {
    final list = getLevelProgressList();
    final idx = list.indexWhere((p) => p.levelId == progress.levelId);
    if (idx >= 0) {
      list[idx] = progress;
    } else {
      list.add(progress);
    }
    await _progressBox.put('levels', list.map((e) => e.toJson()).toList());
  }

  // Missed Words
  static List<MissedWord> getMissedWords() {
    final data = _missedWordsBox.get('words');
    if (data == null) return [];
    return (data as List)
        .map((e) => MissedWord.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> recordMissedWord(int wordId) async {
    await recordMissedWords([wordId]);
  }

  static Future<void> recordMissedWords(List<int> wordIds) async {
    if (wordIds.isEmpty) return;
    final list = getMissedWords();
    for (final wordId in wordIds) {
      final idx = list.indexWhere((w) => w.wordId == wordId);
      if (idx >= 0) {
        list[idx] = list[idx].copyWith(missCount: list[idx].missCount + 1);
      } else {
        list.add(MissedWord(wordId: wordId));
      }
    }
    await _missedWordsBox.put('words', list.map((e) => e.toJson()).toList());
  }

  // Stats
  static int get totalWordsCompleted {
    return getLevelProgressList().fold(
      0,
      (sum, p) => sum + (p.completed ? 1 : 0),
    );
  }

  static int get totalStars {
    return getLevelProgressList().fold(0, (sum, p) => sum + p.stars);
  }

  static int get totalMissedWords => getMissedWords().length;

  // Reset
  static Future<void> resetProgress() async {
    await _progressBox.clear();
    await _missedWordsBox.clear();
    final profile = getProfile();
    if (profile != null) await saveProfile(profile.copyWith(coins: 0));
  }
}
