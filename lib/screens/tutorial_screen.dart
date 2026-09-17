import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _TutorialPage(
      emoji: '🔊',
      title: 'Listen',
      description: 'Tap the speaker button to hear the word out loud.',
    ),
    _TutorialPage(
      emoji: '🔤',
      title: 'Connect Letters',
      description: 'Tap the letters in the right order to spell the word.',
    ),
    _TutorialPage(
      emoji: '🔄',
      title: '3 Tries',
      description:
          'You get up to 3 attempts per word. Fewer tries = more coins!',
    ),
    _TutorialPage(
      emoji: '🪙',
      title: 'Earn Coins',
      description: 'Complete words correctly to earn coins for the shop.',
    ),
    _TutorialPage(
      emoji: '🛍️',
      title: 'Shop',
      description: 'Spend coins on cool items to customize your character.',
    ),
    _TutorialPage(
      emoji: '📊',
      title: 'Track Progress',
      description: 'Check your accuracy and review missed words.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      ref.read(appProvider.notifier).completeTutorial();
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HOW TO PLAY')),
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
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    ref.read(appProvider.notifier).completeTutorial();
                    context.go('/home');
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Color(0xFF8D6E63)),
                  ),
                ),
              ),
              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFE07A),
                            ),
                            child: Center(
                              child: Text(
                                page.emoji,
                                style: const TextStyle(fontSize: 48),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            page.title,
                            style: const TextStyle(
                              fontFamily: 'Baloo2',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF553522),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color(0xFF8D6E63),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Dots + button
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dots
                    Row(
                      children: List.generate(
                        _pages.length,
                        (i) => Container(
                          width: i == _currentPage ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? const Color(0xFFFF8C00)
                                : const Color(0xFFE7CD86),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    // Next / Done button
                    GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF553522),
                        ),
                        child: Icon(
                          _currentPage == _pages.length - 1
                              ? Icons.check
                              : Icons.arrow_forward,
                          color: const Color(0xFFFF8C00),
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
  final String emoji;
  final String title;
  final String description;

  const _TutorialPage({
    required this.emoji,
    required this.title,
    required this.description,
  });
}

