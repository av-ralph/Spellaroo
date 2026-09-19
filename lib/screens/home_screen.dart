import '../widgets/adventure_scaffold.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../services/audio_service.dart';
import '../widgets/character_portrait.dart';
import '../widgets/carnival.dart';
import '../widgets/adventure_home.dart';
import '../config/theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AudioService.playBgm('assets/sounds/bgm/main_menu.mp3');
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit Spellaroo?'),
        content: const Text('Are you sure you want to exit the game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              SystemNavigator.pop();
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final profile = state.profile;
    debugPrint('HomeScreen build: coins=${profile?.coins}');
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmExit();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFF073E3D),
          body: LayoutBuilder(
            builder: (context, viewport) {
              final width = math.min(viewport.maxWidth, 600.0);
              // Keep the reference composition on phones; scroll on short displays.
              final height = math.max(viewport.maxHeight, width * 2.05);
              return Center(
                child: SizedBox(
                  width: width,
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: height,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/home_scenery.png',
                              fit: BoxFit.fill,
                              excludeFromSemantics: true,
                            ),
                          ),
                          // Use the wardrobe renderer so character changes and
                          // equipped items always follow the saved app state.
                          Positioned(
                            left: width * .27,
                            right: width * .27,
                            top: height * .291,
                            height: height * .239,
                            child: CharacterPortrait(
                              key: const ValueKey('home-character'),
                              characterKey: profile.characterKey ?? 'kangaroo',
                              equippedByCategory: state.equippedByCategory,
                            ),
                          ),
                          Positioned(
                            left: width * .12,
                            right: width * .12,
                            top: height * .208,
                            height: height * .081,
                            child: AdventureGreeting(profile.nickname),
                          ),
                          Positioned(
                            right: width * .035,
                            top: math.max(
                              MediaQuery.paddingOf(context).top,
                              height * .043,
                            ),
                            width: width * .16,
                            height: width * .077,
                            child: Semantics(
                              label: '${profile.coins} coins',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFFFEB39),
                                      Color(0xFFFFB900),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFFFFD83D),
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x55005871),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.pets,
                                      color: const Color(0xFFEAA014),
                                      size: width * .038,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${profile.coins}',
                                          style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF633919),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: width * .067,
                            right: width * .067,
                            top: height * .536,
                            height: height * .081,
                            child: AdventureButton(
                              label: 'Let’s play',
                              icon: Icons.play_arrow_rounded,
                              primary: true,
                              colors: const [
                                Color(0xFF69D75B),
                                Color(0xFF19AE54),
                                Color(0xFF00973F),
                              ],
                              onPressed: () => context.go('/play'),
                            ),
                          ),
                          ...[
                            (
                              'Shop',
                              '/shop',
                              Icons.shopping_bag_rounded,
                              [
                                const Color(0xFFFFD141),
                                const Color(0xFFFFA400),
                                const Color(0xFFFF8A00),
                              ],
                            ),
                            (
                              'Character',
                              '/character/customize',
                              Icons.pets,
                              [
                                const Color(0xFFFF91A0),
                                const Color(0xFFFF5871),
                                const Color(0xFFFF3957),
                              ],
                            ),
                            (
                              'Progress',
                              '/progress',
                              Icons.bar_chart_rounded,
                              [
                                const Color(0xFF45DAB5),
                                const Color(0xFF08BDA2),
                                const Color(0xFF009E91),
                              ],
                            ),
                            (
                              'Parent',
                              '/parent',
                              Icons.family_restroom_rounded,
                              [
                                const Color(0xFFB38AFF),
                                const Color(0xFF9361E7),
                                const Color(0xFF7144D2),
                              ],
                            ),
                          ].asMap().entries.map((entry) {
                            final item = entry.value;
                            return Positioned(
                              left: width * (entry.key.isEven ? .044 : .51),
                              width: width * .446,
                              top: height * (.634 + (entry.key ~/ 2) * .082),
                              height: height * .068,
                              child: AdventureButton(
                                label: item.$1,
                                icon: item.$3,
                                colors: item.$4,
                                onPressed: () => context.push(item.$2),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CategorySelectScreen extends StatelessWidget {
  const CategorySelectScreen({super.key});
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (didPop) return;
      context.go('/home');
    },
    child: AdventureScaffold(
      appBar: AppBar(
        title: const Text('CHOOSE A CATEGORY'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            const CarnivalPennants(),
            const CarnivalRibbon('Pick your challenge'),
            const SizedBox(height: 16),
            ...[
              (
                key: 'easy',
                label: 'Easy',
                subtitle: 'Build your confidence',
                color: AppTheme.green,
                icon: Icons.eco,
              ),
              (
                key: 'medium',
                label: 'Medium',
                subtitle: 'Grow your word power',
                color: AppTheme.orange,
                icon: Icons.bolt,
              ),
              (
                key: 'hard',
                label: 'Hard',
                subtitle: 'Take on a challenge',
                color: AppTheme.red,
                icon: Icons.local_fire_department,
              ),
              (
                key: 'random',
                label: 'Random',
                subtitle: 'A surprise mix of words',
                color: AppTheme.purple,
                icon: Icons.shuffle,
              ),
            ].map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    CarnivalButton(
                      label: c.label,
                      color: c.color,
                      icon: c.icon,
                      onPressed: () => context.go('/play/${c.key}'),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      c.subtitle,
                      style: const TextStyle(color: AppTheme.brown),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 130,
              child: CharacterPortrait(characterKey: 'kangaroo'),
            ),
          ],
        ),
      ),
    ),
  );
}
