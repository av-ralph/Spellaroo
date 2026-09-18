import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';

class ResultScreen extends ConsumerWidget {
  final bool won;
  final String word;
  final int coinsEarned;
  final int attempts;
  final String difficulty;

  const ResultScreen({
    super.key,
    required this.won,
    required this.word,
    required this.coinsEarned,
    required this.attempts,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF8C00), Color(0xFFFFD54F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                size: 100,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 24),
              const Text(
                'Level Complete!',
                style: TextStyle(
                  fontFamily: 'Baloo2',
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 8),
                    Text(
                      '$coinsEarned',
                      style: const TextStyle(
                        fontFamily: 'Baloo2',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    AudioService.playClick();
                    ref.read(gameProvider.notifier).resetGame();
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF8C00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontFamily: 'Baloo2',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  AudioService.playClick();
                  ref.read(gameProvider.notifier).resetGame();
                  context.go('/play/$difficulty');
                },
                child: const Text(
                  'Play Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
