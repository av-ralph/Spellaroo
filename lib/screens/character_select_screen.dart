import '../widgets/adventure_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../services/audio_service.dart';
import '../widgets/character_portrait.dart';

class CharacterSelectScreen extends ConsumerStatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  ConsumerState<CharacterSelectScreen> createState() =>
      _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends ConsumerState<CharacterSelectScreen>
    with SingleTickerProviderStateMixin {
  String? _previewKey;
  bool _saving = false;
  late AnimationController _previewAnimController;
  late Animation<double> _previewScale;

  static const _characters = [
    (key: 'kangaroo', name: 'Roo', desc: 'Bouncy and energetic', emoji: '🦘'),
    (key: 'cat', name: 'Whiskers', desc: 'Curious and playful', emoji: '🐱'),
    (key: 'bunny', name: 'Hops', desc: 'Quick and adorable', emoji: '🐰'),
    (key: 'bear', name: 'Barnaby', desc: 'Strong and cuddly', emoji: '🐻'),
    (key: 'panda', name: 'Mochi', desc: 'Gentle and wise', emoji: '🐼'),
    (key: 'fox', name: 'Foxy', desc: 'Clever and swift', emoji: '🦊'),
  ];

  static const _cardGradients = [
    [Color(0xFFFFCC80), Color(0xFFFF9800)],
    [Color(0xFFB39DDB), Color(0xFF7E57C2)],
    [Color(0xFF80DEEA), Color(0xFF00ACC1)],
    [Color(0xFFA5D6A7), Color(0xFF43A047)],
    [Color(0xFFF48FB1), Color(0xFFE91E63)],
    [Color(0xFFFFAB91), Color(0xFFE64A19)],
  ];

  @override
  void initState() {
    super.initState();
    _previewAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _previewScale = CurvedAnimation(
      parent: _previewAnimController,
      curve: Curves.easeOutBack,
    );
    _previewAnimController.forward();
  }

  @override
  void dispose() {
    _previewAnimController.dispose();
    super.dispose();
  }

  void _selectCharacter(String key) {
    AudioService.playClick();
    if (_previewKey == key) return;
    _previewAnimController.reset();
    setState(() => _previewKey = key);
    _previewAnimController.forward();
  }

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
    final selected = _previewKey == null
        ? null
        : _characters.firstWhere((c) => c.key == _previewKey);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 400;

    return AdventureScaffold(
      body: SizedBox(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        AudioService.playClick();
                        context.go('/home');
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: const Color(0xFF553522),
                    ),
                    const Expanded(
                      child: Text(
                        'CHOOSE YOUR BUDDY',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Baloo2',
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Color(0xFF553522),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Preview area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Character preview
                      ScaleTransition(
                        scale: _previewScale,
                        child: Container(
                          height: 200,
                          width: 240,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: _previewKey != null
                                  ? _cardGradients[_characters.indexWhere(
                                      (c) => c.key == _previewKey,
                                    )][1]
                                  : const Color(0xFFE7CD86),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (_previewKey != null
                                            ? _cardGradients[_characters
                                                  .indexWhere(
                                                    (c) => c.key == _previewKey,
                                                  )][1]
                                            : const Color(0xFFE7CD86))
                                        .withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: CharacterPortrait(
                              characterKey: _previewKey ?? 'kangaroo',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Name + personality tag
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Column(
                          key: ValueKey(_previewKey),
                          children: [
                            Text(
                              selected?.name ?? 'Who will it be?',
                              style: TextStyle(
                                fontFamily: 'Baloo2',
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                                color: _previewKey != null
                                    ? const Color(0xFF553522)
                                    : const Color(0xFF8D6E63),
                              ),
                            ),
                            if (selected != null) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _cardGradients[_characters.indexWhere(
                                            (c) => c.key == _previewKey,
                                          )][0]
                                          .withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${selected.emoji}  ${selected.desc}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color:
                                        _cardGradients[_characters.indexWhere(
                                          (c) => c.key == _previewKey,
                                        )][1],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Character grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isCompact ? 3 : 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: _characters.length,
                        itemBuilder: (context, index) {
                          final c = _characters[index];
                          final isSelected = _previewKey == c.key;
                          final gradient = _cardGradients[index];

                          return GestureDetector(
                            onTap: () => _selectCharacter(c.key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? gradient[0].withValues(alpha: 0.15)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? gradient[1]
                                      : const Color(0xFFE7CD86),
                                  width: isSelected ? 2.5 : 1.5,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: gradient[1].withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        6,
                                        6,
                                        6,
                                        0,
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CharacterPortrait(
                                            characterKey: c.key,
                                          ),
                                          if (isSelected)
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: gradient[1],
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: gradient[1]
                                                          .withValues(
                                                            alpha: 0.4,
                                                          ),
                                                      blurRadius: 6,
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        c.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: isCompact ? 12 : 13,
                                          color: isSelected
                                              ? const Color(0xFF553522)
                                              : const Color(0xFF6D4C2E),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // Confirm button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _previewKey == null || _saving
                        ? null
                        : () {
                            AudioService.playButton();
                            _confirm();
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF109E69),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE4DAC0),
                      disabledForegroundColor: const Color(0xFF776A54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      side: const BorderSide(
                        color: Color(0xFF00825A),
                        width: 2,
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            selected == null
                                ? 'Choose a buddy'
                                : 'Play with ${selected.name}',
                            style: const TextStyle(
                              fontFamily: 'Baloo2',
                              fontSize: 18,
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
