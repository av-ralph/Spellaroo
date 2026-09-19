import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/character_portrait.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../services/audio_service.dart';

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
    final loading = state.loading || state.profile != null;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF063E43),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/splash_adventure.png',
              key: const ValueKey('splash-background'),
              fit: BoxFit.cover,
              alignment: const Alignment(0, .2),
              excludeFromSemantics: true,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x18012543),
                    Colors.transparent,
                    Color(0x22053335),
                    Color(0xF2053035),
                  ],
                  stops: [0, .4, .66, 1],
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final landscape =
                      constraints.maxWidth > constraints.maxHeight * 1.15;
                  final compact = constraints.maxHeight < 650;
                  final mascot = Semantics(
                    label: 'Your Spellaroo adventure buddy',
                    image: true,
                    child: CharacterPortrait(
                      characterKey: state.profile?.characterKey ?? 'kangaroo',
                      equippedByCategory: state.equippedByCategory,
                    ),
                  );
                  final controls = _SplashWelcome(
                    loading: loading,
                    returning: state.profile != null,
                    compact: compact,
                    onStart: () {
                      AudioService.playClick();
                      context.go('/profile/create');
                    },
                  );
                  final content = landscape
                      ? Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  18,
                                  8,
                                  18,
                                ),
                                child: mascot,
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  16,
                                  24,
                                  16,
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 90,
                                      child: _SplashBrand(),
                                    ),
                                    const SizedBox(height: 12),
                                    controls,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            compact ? 12 : 30,
                            24,
                            20,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: compact ? 112 : 155,
                                child: const _SplashBrand(),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                  ),
                                  child: mascot,
                                ),
                              ),
                              const SizedBox(height: 14),
                              controls,
                            ],
                          ),
                        );
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: MediaQuery.disableAnimationsOf(context)
                              ? 1
                              : 0,
                          end: 1,
                        ),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 12 * (1 - value)),
                            child: child,
                          ),
                        ),
                        child: content,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashBrand extends StatelessWidget {
  const _SplashBrand();
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Spellaroo. Spell it. Learn it. Master it.',
    child: ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFFFD953),
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'A WORLD OF WORDS AWAITS',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 3,
                      fontSize: 13,
                      shadows: [
                        Shadow(color: Color(0xFF075478), blurRadius: 8),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFFFD953),
                    size: 22,
                  ),
                ],
              ),
              Stack(
                children: [
                  Text(
                    'Spellaroo',
                    maxLines: 1,
                    softWrap: false,
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(
                      fontFamily: 'Baloo2',
                      fontSize: 94,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 10
                        ..color = const Color(0xFF06345D),
                      shadows: const [
                        Shadow(
                          color: Color(0x99002B42),
                          blurRadius: 1,
                          offset: Offset(0, 7),
                        ),
                      ],
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Color(0xFFFFEF8D),
                        Color(0xFFFFBB27),
                      ],
                      stops: [0, .5, 1],
                    ).createShader(bounds),
                    child: const Text(
                      'Spellaroo',
                      maxLines: 1,
                      softWrap: false,
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        fontFamily: 'Baloo2',
                        fontSize: 94,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xDD086488),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0x887ADEEA)),
                ),
                child: const Text(
                  'SPELL IT.  LEARN IT.  MASTER IT!',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SplashWelcome extends StatelessWidget {
  const _SplashWelcome({
    required this.loading,
    required this.returning,
    required this.compact,
    required this.onStart,
  });
  final bool loading, returning, compact;
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 420),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xE6084148),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x447BE6C7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33002125),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            returning
                ? 'Your adventure continues'
                : 'Big adventures. Little words.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Baloo2',
              fontWeight: FontWeight.w800,
              fontSize: compact ? 23 : 26,
              height: 1.1,
              color: const Color(0xFFFFF4CF),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            returning
                ? 'Getting your buddy ready…'
                : 'Listen, spell, and grow with your buddy.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFC5E8DE),
              height: 1.4,
            ),
          ),
          SizedBox(height: compact ? 14 : 19),
          if (loading)
            Semantics(
              liveRegion: true,
              label: 'Loading your adventure',
              child: SizedBox(
                height: 56,
                child: Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      color: Color(0xFFFFDB63),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFE575), Color(0xFFFFBA28)],
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFB57F15), offset: Offset(0, 4)),
                  ],
                ),
                child: FilledButton(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: const Color(0xFF3F3918),
                    minimumSize: const Size(0, 56),
                    side: const BorderSide(color: Color(0xFFFFEEA5), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 29),
                      SizedBox(width: 8),
                      Text(
                        'START',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
            ),
          if (!compact) ...[
            const SizedBox(height: 14),
            const Text(
              'EVERY WORD IS A LITTLE WIN',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.7,
                color: Color(0xFFADCEC4),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
