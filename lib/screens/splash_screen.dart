import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;
  bool _ready = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _ready = true;
      _continueReturningPlayer(ref.read(appProvider));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _continueReturningPlayer(AppState state) {
    if (!mounted ||
        !_ready ||
        _navigating ||
        state.loading ||
        state.profile == null) {
      return;
    }
    _navigating = true;
    final profile = state.profile!;
    context.go(
      profile.characterKey == null
          ? '/character/select'
          : profile.tutorialCompleted
          ? '/home'
          : '/tutorial',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    ref.listen<AppState>(
      appProvider,
      (_, next) => _continueReturningPlayer(next),
    );
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Splash.png',
            fit: BoxFit.cover,
            semanticLabel:
                'Spellaroo World Champ, with Roo at the spelling carnival',
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Spell It. Learn It. Master It!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (state.loading || state.profile != null)
                    const SizedBox(
                      height: 52,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => context.go('/profile/create'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF388E3C),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 56),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          child: const Text('START'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
