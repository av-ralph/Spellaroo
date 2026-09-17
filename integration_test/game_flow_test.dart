import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:spellaroo/app.dart';
import 'package:spellaroo/providers/app_provider.dart';
import 'package:spellaroo/providers/game_provider.dart';
import 'package:spellaroo/services/storage_service.dart';
import 'package:spellaroo/services/audio_service.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('First launch through complete level and random challenge', (
    tester,
  ) async {
    // Isolated storage protects the real player's profile and progress.
    final directory = await Directory.systemTemp.createTemp('spellaroo-flow-');
    Hive.init(directory.path);
    await StorageService.init();
    await tester.pumpWidget(const ProviderScope(child: SpellarooApp()));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      final bytes = await binding.takeScreenshot(name);
      final file = File('${directory.path}/$name.png');
      await file.writeAsBytes(bytes);
      debugPrint('SCREENSHOT ${file.path}');
    }

    Future<void> tap(Finder finder) async {
      await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    await capture('01-splash');
    await tap(find.text('START'));
    await capture('02-profile');
    await tester.enterText(find.byType(TextField), 'Spelling Champ');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tap(find.text("Let's Go!"));
    await capture('03-characters');
    await tap(find.text('Whiskers'));
    await capture('04-cat-preview');
    await tap(find.text('Choose Whiskers'));
    await tap(find.text('Skip'));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SpellarooApp)),
    );
    expect(container.read(appProvider).profile!.characterKey, 'cat');
    expect(container.read(appProvider).profile!.tutorialCompleted, isTrue);
    // Keep this automated playthrough quiet; audio is tested separately on device.
    AudioService.configure(soundOn: false, musicOn: false, effectsOn: false);
    await capture('05-home');
    final router = container.read(goRouterProvider);
    for (final page in [
      'shop',
      'character/customize',
      'progress',
      'settings',
      'parent',
    ]) {
      router.go('/$page');
      await tester.pumpAndSettle();
      await capture('screen-${page.replaceAll('/', '-')}');
      if (page == 'parent') {
        await tap(find.text('Unlock'));
        await capture('screen-parent-dashboard');
      }
      expect(tester.takeException(), isNull);
    }
    router.go('/home');
    await tester.pumpAndSettle();
    await tap(find.text("Let's play"));
    await capture('06-categories');
    await tap(find.text('Easy'));
    await capture('06-levels');
    await tap(find.text('1'));
    await tap(find.text('Start'));
    await capture('06-game');
    for (var index = 0; index < 25; index++) {
      final word = container.read(gameProvider).currentWord!.word.toUpperCase();
      if (index == 0) {
        final wrongOrder = List.generate(
          word.length,
          (i) => (i + 1) % word.length,
        );
        for (var attempt = 0; attempt < 3; attempt++) {
          for (final i in wrongOrder) {
            await tap(find.byKey(ValueKey('letter-$i-${word[i]}')));
          }
          await tap(find.text('Check'));
          expect(
            container.read(gameProvider).status,
            attempt < 2 ? GameStatus.wrong : GameStatus.revealed,
          );
          if (attempt < 2) await tap(find.text('Try again'));
        }
      } else {
        for (var i = 0; i < word.length; i++) {
          await tap(find.byKey(ValueKey('letter-$i-${word[i]}')));
        }
        await tap(find.text('Check'));
        expect(container.read(gameProvider).status, GameStatus.correct);
      }
      await tap(find.text(index == 24 ? 'See results' : 'Next word'));
    }
    await capture('07-results');
    expect(find.text('96% accuracy'), findsOneWidget);
    expect(StorageService.getLevelProgress(1)!.completed, isTrue);
    expect(StorageService.getLevelProgress(2)!.unlocked, isTrue);
    expect(StorageService.getProfile()!.coins, 72);
    expect(StorageService.getMissedWords(), isNotEmpty);
    await tap(find.text('Play again'));
    expect(find.text('Start'), findsOneWidget);
    await tap(find.text('Back'));
    await tap(find.byIcon(Icons.arrow_back));
    await tap(find.byIcon(Icons.arrow_back));
    await tap(find.text("Let's play"));
    await tester.scrollUntilVisible(
      find.text('Random'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tap(find.text('Random'));
    expect(find.text('Random Challenge'), findsOneWidget);
    await tap(find.text('Start'));
    expect(container.read(gameProvider).words.length, 25);
    expect(container.read(gameProvider).status, GameStatus.playing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await Hive.close();
  });
}
