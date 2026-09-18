import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import '../models/inventory_entry.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../widgets/character_painter.dart';

class AppState {
  final Profile? profile;
  final List<InventoryEntry> inventory;
  final bool loading;

  AppState({this.profile, this.inventory = const [], this.loading = true});

  AppState copyWith({
    Profile? profile,
    List<InventoryEntry>? inventory,
    bool? loading,
  }) {
    return AppState(
      profile: profile ?? this.profile,
      inventory: inventory ?? this.inventory,
      loading: loading ?? this.loading,
    );
  }

  Map<String, Equipment> get equippedByCategory {
    final map = <String, Equipment>{};
    for (final entry in inventory) {
      if (entry.equipped) {
        final item = StorageService.getShopItem(entry.itemId);
        if (item != null) {
          map[item.category] = Equipment(
            name: item.name,
            colorName: item.colorName,
          );
        }
      }
    }
    return map;
  }
}

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(AppState()) {
    init();
  }

  Future<void> init() async {
    final profile = StorageService.getProfile();
    final inventory = StorageService.getInventory();
    AudioService.configure(
      soundOn: profile?.soundOn ?? true,
      musicOn: profile?.musicOn ?? true,
      effectsOn: profile?.effectsOn ?? true,
    );
    state = AppState(profile: profile, inventory: inventory, loading: false);
  }

  Future<void> createProfile(String nickname, int gradeLevel) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final profile = Profile(id: id, nickname: nickname, gradeLevel: gradeLevel);
    await StorageService.saveProfile(profile);
    state = state.copyWith(profile: profile);
  }

  Future<void> selectCharacter(String characterKey) async {
    if (state.profile == null) return;
    final updated = state.profile!.copyWith(characterKey: characterKey);
    await StorageService.saveProfile(updated);
    state = state.copyWith(profile: updated);
  }

  Future<void> completeTutorial() async {
    if (state.profile == null) return;
    final updated = state.profile!.copyWith(tutorialCompleted: true);
    await StorageService.saveProfile(updated);
    state = state.copyWith(profile: updated);
  }

  Future<void> refreshProfile() async {
    final profile = StorageService.getProfile();
    final inventory = StorageService.getInventory();
    state = state.copyWith(profile: profile, inventory: inventory);
  }

  Future<void> addCoins(int amount) async {
    if (state.profile == null) {
      debugPrint('addCoins: profile is null, aborting');
      return;
    }
    debugPrint('addCoins: current coins=${state.profile!.coins}, adding=$amount');
    final updated = state.profile!.copyWith(
      coins: state.profile!.coins + amount,
    );
    await StorageService.saveProfile(updated);
    state = state.copyWith(profile: updated);
    debugPrint('addCoins: saved and updated, new coins=${state.profile!.coins}');
  }

  Future<void> spendCoins(int amount) async {
    if (state.profile == null) return;
    if (state.profile!.coins < amount) return;
    final updated = state.profile!.copyWith(
      coins: state.profile!.coins - amount,
    );
    await StorageService.saveProfile(updated);
    state = state.copyWith(profile: updated);
  }

  Future<void> toggleSetting(String setting) async {
    if (state.profile == null) return;
    Profile updated;
    switch (setting) {
      case 'sound':
        updated = state.profile!.copyWith(soundOn: !state.profile!.soundOn);
        break;
      case 'music':
        updated = state.profile!.copyWith(musicOn: !state.profile!.musicOn);
        break;
      case 'effects':
        updated = state.profile!.copyWith(effectsOn: !state.profile!.effectsOn);
        break;
      default:
        return;
    }
    await StorageService.saveProfile(updated);
    AudioService.configure(
      soundOn: updated.soundOn,
      musicOn: updated.musicOn,
      effectsOn: updated.effectsOn,
    );
    state = state.copyWith(profile: updated);
  }

  Future<void> setParentPin(String pinHash) async {
    if (state.profile == null) return;
    final updated = state.profile!.copyWith(parentPinHash: pinHash);
    await StorageService.saveProfile(updated);
    state = state.copyWith(profile: updated);
  }

  Future<void> resetAllProgress() async {
    await StorageService.resetProgress();
    await refreshProfile();
  }
}

final appProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  return AppNotifier();
});
