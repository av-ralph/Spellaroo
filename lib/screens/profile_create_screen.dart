import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../widgets/character_portrait.dart';

class ProfileCreateScreen extends ConsumerStatefulWidget {
  const ProfileCreateScreen({super.key});
  @override
  ConsumerState<ProfileCreateScreen> createState() =>
      _ProfileCreateScreenState();
}

class _ProfileCreateScreenState extends ConsumerState<ProfileCreateScreen> {
  final _name = TextEditingController();
  int _grade = 5;
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_saving) return;
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your nickname.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(appProvider.notifier)
          .createProfile(_name.text.trim(), _grade);
      if (mounted) context.go('/character/select');
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save your profile. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFF8E1),
    appBar: AppBar(title: const Text('CREATE PROFILE')),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 140,
                  child: CharacterPortrait(characterKey: 'kangaroo'),
                ),
                const Text(
                  'Welcome to Spellaroo!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'Baloo2',
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF553522),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Let\'s meet our next spelling champ.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF553522)),
                ),
                const SizedBox(height: 24),
                Card(
                  color: const Color(0xFFFFFDF3),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _name,
                          maxLength: 24,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Nickname',
                            errorText: _error,
                          ),
                          onSubmitted: (_) => _create(),
                        ),
                        const SizedBox(height: 16),
                        const Text('Grade level'),
                        const SizedBox(height: 8),
                        GridView.count(
                          crossAxisCount: 3,
                          childAspectRatio: 1.8,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: List.generate(
                            6,
                            (i) => ChoiceChip(
                              selectedColor: const Color(0xFFFFD447),
                              label: Text('${i + 1}'),
                              selected: _grade == i + 1,
                              onSelected: _saving
                                  ? null
                                  : (_) => setState(() => _grade = i + 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _create,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF388E3C),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 52),
                    ),
                    child: Text(_saving ? 'Saving...' : 'Let\'s Go!'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

