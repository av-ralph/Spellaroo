import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';
import '../utils/hash_utils.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
  final _pinController = TextEditingController();
  bool _authenticated = false;
  String _error = '';

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verifyPin() {
    final pin = _pinController.text;
    final profile = ref.read(appProvider).profile;
    if (profile?.parentPinHash == null) {
      setState(() => _authenticated = true);
      return;
    }
    final hash = HashUtils.hashPin(pin);
    if (hash == profile!.parentPinHash) {
      setState(() {
        _authenticated = true;
        _error = '';
      });
    } else {
      setState(() => _error = 'Incorrect PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);
    final profile = appState.profile;

    if (!_authenticated) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          title: const Text('Parent Dashboard'),
          backgroundColor: const Color(0xFF187EB2),
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF8E1), Color(0xFFFFF8E1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 24),
                  const Text(
                    'Enter Parent PIN',
                    style: TextStyle(
                      fontFamily: 'Baloo2',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 12,
                    ),
                    decoration: InputDecoration(
                      hintText: '••••',
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFFF8C00),
                          width: 2,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _verifyPin(),
                  ),
                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error,
                      style: const TextStyle(color: Color(0xFFFF5252)),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _verifyPin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Unlock',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
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

    final progress = StorageService.getLevelProgressList();
    final missedWords = StorageService.getMissedWords();
    final completedCount = progress.where((p) => p.completed).length;
    final totalWordsAttempted = progress.fold(
      0,
      (sum, p) => sum + p.wordsAttempted,
    );
    final totalWordsCorrect = progress.fold(
      0,
      (sum, p) => sum + p.wordsCorrect,
    );
    final overallAccuracy = totalWordsAttempted > 0
        ? totalWordsCorrect / totalWordsAttempted
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Parent Dashboard',
          style: TextStyle(fontFamily: 'Baloo2', fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFF187EB2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8E1), Color(0xFFFFF8E1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(
                      0xFFFF8C00,
                    ).withValues(alpha: 0.1),
                    child: Text(
                      profile?.nickname.isNotEmpty == true
                          ? profile!.nickname[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontFamily: 'Baloo2',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF8C00),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile?.nickname ?? 'Unknown',
                    style: const TextStyle(
                      fontFamily: 'Baloo2',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Grade ${profile?.gradeLevel ?? '-'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats
            _StatsCard(
              stats: [
                _Stat('Coins', '${profile?.coins ?? 0}'),
                _Stat('Levels Completed', '$completedCount'),
                _Stat('Words Missed', '${missedWords.length}'),
                _Stat(
                  'Overall Accuracy',
                  '${(overallAccuracy * 100).round()}%',
                ),
                _Stat('Words Practiced', '$totalWordsAttempted'),
              ],
            ),
            const SizedBox(height: 16),
            // Top missed words
            if (missedWords.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Most Missed Words',
                      style: TextStyle(
                        fontFamily: 'Baloo2',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...missedWords
                        .take(10)
                        .map(
                          (w) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  StorageService.allWords
                                          .where((word) => word.id == w.wordId)
                                          .firstOrNull
                                          ?.word ??
                                      'Word ${w.wordId}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFF5252,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${w.missCount}x missed',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFFF5252),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.refresh,
                      color: Color(0xFFFF8C00),
                    ),
                    title: const Text('Reset All Progress'),
                    subtitle: const Text(
                      'Clear levels, coins, and missed words',
                    ),
                    onTap: () => _showResetDialog(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will clear all level progress, coins, and missed words. Character and items will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(appProvider.notifier).resetAllProgress();
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Color(0xFFFF5252)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final List<_Stat> stats;
  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: stats
            .map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.label, style: const TextStyle(fontSize: 14)),
                    Text(
                      s.value,
                      style: const TextStyle(
                        fontFamily: 'Baloo2',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF8C00),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Stat {
  final String label;
  final String value;
  const _Stat(this.label, this.value);
}
