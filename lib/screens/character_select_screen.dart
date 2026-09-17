import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../widgets/character_portrait.dart';

class CharacterSelectScreen extends ConsumerStatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  ConsumerState<CharacterSelectScreen> createState() =>
      _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends ConsumerState<CharacterSelectScreen> {
  String? _previewKey;
  bool _saving = false;
  static const _characters = [
    (key: 'kangaroo', name: 'Roo'),
    (key: 'cat', name: 'Whiskers'),
    (key: 'bunny', name: 'Hops'),
    (key: 'bear', name: 'Barnaby'),
    (key: 'panda', name: 'Mochi'),
    (key: 'fox', name: 'Foxy'),
  ];

  Future<void> _confirm() async {
    if (_previewKey == null || _saving) return;
    if (ref.read(appProvider).profile == null) {
      context.go('/profile/create');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(appProvider.notifier).selectCharacter(_previewKey!);
      if (mounted) {
        context.go(
          ref.read(appProvider).profile!.tutorialCompleted
              ? '/home'
              : '/tutorial',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your choice. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _previewKey == null
        ? null
        : _characters.firstWhere((c) => c.key == _previewKey).name;
    return Scaffold(
      appBar: AppBar(title: const Text('CHOOSE CHARACTER')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8E1), Color(0xFFFFF8E1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        child: Column(
                          children: [
                            const Text(
                              'Choose Your Character',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontFamily: 'Baloo2',
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF553522),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Who will be your spelling buddy?',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF8D6E63)),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 220,
                              width: 280,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFDF3),
                                border: Border.all(
                                  color: const Color(0xFFE7CD86),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: CharacterPortrait(
                                  characterKey: _previewKey ?? 'kangaroo',
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              name ?? 'Meet your spelling team',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF553522),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 180,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.78,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final character = _characters[index];
                          final selected = _previewKey == character.key;
                          return Semantics(
                            selected: selected,
                            button: true,
                            label: character.name,
                            child: Material(
                              color: selected
                                  ? const Color(0xFFFFEDAF)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: _saving
                                    ? null
                                    : () => setState(
                                        () => _previewKey = character.key,
                                      ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: CharacterPortrait(
                                          characterKey: character.key,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        4,
                                        0,
                                        4,
                                        10,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (selected)
                                            const Icon(
                                              Icons.check_circle,
                                              size: 16,
                                              color: Color(0xFF0956A8),
                                            ),
                                          Flexible(
                                            child: Text(
                                              character.name,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }, childCount: _characters.length),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _previewKey == null || _saving ? null : _confirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF388E3C),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE4DAC0),
                      disabledForegroundColor: const Color(0xFF776A54),
                      minimumSize: const Size(0, 52),
                    ),
                    child: Text(
                      _saving
                          ? 'Saving...'
                          : name == null
                          ? 'Choose a buddy'
                          : 'Choose $name',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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

