import '../widgets/adventure_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../services/audio_service.dart';
import '../utils/hash_utils.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _pinController = TextEditingController();
  String _feedback = '';
  bool _showResetConfirm = false;
  bool _resetting = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    final pin = _pinController.text;
    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      setState(() => _feedback = 'PIN must be exactly 4 digits');
      return;
    }
    final hash = HashUtils.hashPin(pin);
    await ref.read(appProvider.notifier).setParentPin(hash);
    _pinController.clear();
    setState(() => _feedback = 'PIN saved!');
  }

  Future<void> _resetProgress() async {
    setState(() => _resetting = true);
    await ref.read(appProvider.notifier).resetAllProgress();
    setState(() {
      _resetting = false;
      _showResetConfirm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(appProvider).profile;

    return AdventureScaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('SETTINGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SizedBox(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                children: [
                  const AdventureIntro(
                    title: 'Make yourself at home',
                    subtitle: 'Your sound, your profile, your adventure.',
                    icon: Icons.tune_rounded,
                  ),
                  // Sound settings
                  _Section(
                    children: [
                      _Toggle(
                        label: 'Sound',
                        value: profile?.soundOn ?? true,
                        onToggle: () => ref
                            .read(appProvider.notifier)
                            .toggleSetting('sound'),
                      ),
                      _Toggle(
                        label: 'Background Music',
                        value: profile?.musicOn ?? true,
                        onToggle: () => ref
                            .read(appProvider.notifier)
                            .toggleSetting('music'),
                      ),
                      _Toggle(
                        label: 'Effects',
                        value: profile?.effectsOn ?? true,
                        onToggle: () => ref
                            .read(appProvider.notifier)
                            .toggleSetting('effects'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Profile info
                  _Section(
                    children: [
                      _InfoRow(
                        label: 'Profile',
                        value:
                            '${profile?.nickname ?? ''} · Grade ${profile?.gradeLevel ?? '-'}',
                      ),
                      TextButton(
                        onPressed: () => context.go('/tutorial'),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Replay tutorial'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Parent access
                  _Section(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Parent Access',
                          style: TextStyle(
                            fontFamily: 'Baloo2',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF404040),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile?.parentPinHash != null
                            ? 'A parent PIN is set.'
                            : 'Set a 4-digit PIN to protect the parent dashboard.',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF647580),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _pinController,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              obscureText: true,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                              ),
                              decoration: InputDecoration(
                                hintText: '••••',
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFFED7AA),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFFF8C00),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _savePin,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              backgroundColor: const Color(0xFFFF8C00),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      if (_feedback.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _feedback,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFFF8C00),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go('/parent'),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Open parent dashboard'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Reset
                  _Section(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Reset Progress',
                          style: TextStyle(
                            fontFamily: 'Baloo2',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF5252),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This clears levels, coins, and missed words. Your character and items are kept.',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF647580),
                        ),
                      ),
                      if (_showResetConfirm) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _resetting ? null : _resetProgress,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5252),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _resetting ? 'Resetting...' : 'Yes, reset',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    setState(() => _showResetConfirm = false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                      ] else
                        TextButton(
                          onPressed: () =>
                              setState(() => _showResetConfirm = true),
                          child: const Text(
                            'Reset Progress',
                            style: TextStyle(color: Color(0xFFFF5252)),
                          ),
                        ),
                    ],
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

class _Section extends StatelessWidget {
  final List<Widget> children;
  const _Section({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onToggle;

  const _Toggle({
    required this.label,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF525252),
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF15A780),
            onChanged: (_) {
              AudioService.playClick();
              onToggle();
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF525252),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: Color(0xFF795548)),
            ),
          ),
        ],
      ),
    );
  }
}
