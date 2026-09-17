import 'package:flutter/material.dart';

class FeedbackOverlay extends StatelessWidget {
  final bool isCorrect;
  final bool isRevealed;
  final String word;
  final int coinsEarned;
  final VoidCallback onDismiss;

  const FeedbackOverlay({
    super.key,
    required this.isCorrect,
    required this.isRevealed,
    required this.word,
    required this.coinsEarned,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(40),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCorrect
                        ? Icons.celebration
                        : (isRevealed ? Icons.lightbulb : Icons.refresh),
                    size: 64,
                    color: isCorrect
                        ? const Color(0xFF22C55E)
                        : (isRevealed
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFF97316)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isCorrect
                        ? 'Correct!'
                        : (isRevealed ? 'The word is:' : 'Almost!'),
                    style: const TextStyle(
                      fontFamily: 'Baloo2',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF404040),
                    ),
                  ),
                  if (!isCorrect) ...[
                    const SizedBox(height: 8),
                    Text(
                      word.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Baloo2',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF97316),
                      ),
                    ),
                  ],
                  if (isCorrect && coinsEarned > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '+$coinsEarned coins',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Tap anywhere to continue',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
