import '../widgets/adventure_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../services/audio_service.dart';

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen>
    with SingleTickerProviderStateMixin {
  final _controller = PageController();
  int _currentPage = 0;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  static const _pages = [
    _TutorialPage(
      icon: Icons.volume_up_rounded,
      iconGradient: [Color(0xFF42A5F5), Color(0xFF1565C0)],
      title: 'Listen',
      description: 'Tap the speaker button to hear the word out loud.',
    ),
    _TutorialPage(
      icon: Icons.link_rounded,
      iconGradient: [Color(0xFFFFA726), Color(0xFFEF6C00)],
      title: 'Connect Letters',
      description:
          'Drag through the letters in the right order to spell the word.',
    ),
    _TutorialPage(
      icon: Icons.refresh_rounded,
      iconGradient: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
      title: '3 Tries',
      description:
          'You get up to 3 attempts per word. Fewer tries = more coins!',
    ),
    _TutorialPage(
      icon: Icons.savings_rounded,
      iconGradient: [Color(0xFFFFD54F), Color(0xFFF9A825)],
      title: 'Earn Coins',
      description: 'Complete words correctly to earn coins for the shop.',
    ),
    _TutorialPage(
      icon: Icons.storefront_rounded,
      iconGradient: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
      title: 'Shop',
      description: 'Spend coins on cool items to customize your character.',
    ),
    _TutorialPage(
      icon: Icons.insights_rounded,
      iconGradient: [Color(0xFF26C6DA), Color(0xFF00838F)],
      title: 'Track Progress',
      description: 'Check your accuracy and review missed words.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextPage() {
    AudioService.playButton();
    if (_currentPage < _pages.length - 1) {
      _animController.reset();
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      _animController.forward();
    } else {
      ref.read(appProvider.notifier).completeTutorial();
      context.go('/home');
    }
  }

  void _skip() {
    AudioService.playClick();
    ref.read(appProvider.notifier).completeTutorial();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final isLast = _currentPage == _pages.length - 1;

    return AdventureScaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),

        child: SafeArea(
          child: Column(
            children: [
              // Top bar: step badge + skip
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: page.iconGradient[0].withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentPage + 1} / ${_pages.length}',
                        style: TextStyle(
                          fontFamily: 'Baloo2',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: page.iconGradient[1],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: const Color(0xFF8D6E63).withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final p = _pages[index];
                    return LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 20,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: (constraints.maxHeight - 40).clamp(
                              0,
                              double.infinity,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon with gradient background + shadow
                              ScaleTransition(
                                scale: _scaleAnim,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: p.iconGradient,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: p.iconGradient[1].withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    p.icon,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              // Title
                              Text(
                                p.title,
                                style: const TextStyle(
                                  fontFamily: 'Baloo2',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF553522),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              // Description in a soft card
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFE7CD86,
                                    ).withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  p.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF6D4C2E),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom: dots + next button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Animated dots
                    Row(
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: i == _currentPage ? 28 : 10,
                          height: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            gradient: i == _currentPage
                                ? LinearGradient(colors: page.iconGradient)
                                : null,
                            color: i == _currentPage
                                ? null
                                : const Color(0xFFE7CD86),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    // Next / Done button
                    GestureDetector(
                      onTap: _nextPage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isLast
                                ? [
                                    const Color(0xFF66BB6A),
                                    const Color(0xFF2E7D32),
                                  ]
                                : [page.iconGradient[0], page.iconGradient[1]],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isLast
                                          ? const Color(0xFF2E7D32)
                                          : page.iconGradient[1])
                                      .withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          isLast
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 28,
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
  }
}

class _TutorialPage {
  final IconData icon;
  final List<Color> iconGradient;
  final String title;
  final String description;

  const _TutorialPage({
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.description,
  });
}
