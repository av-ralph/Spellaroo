import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../services/audio_service.dart';
import '../widgets/character_portrait.dart';

class ProfileCreateScreen extends ConsumerStatefulWidget {
  const ProfileCreateScreen({super.key});
  @override
  ConsumerState<ProfileCreateScreen> createState() =>
      _ProfileCreateScreenState();
}

class _ProfileCreateScreenState extends ConsumerState<ProfileCreateScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();
  int _grade = 5;
  bool _saving = false;
  String? _error;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _gradeLabels = [
    (grade: 1, label: '1st', icon: Icons.looks_one_rounded),
    (grade: 2, label: '2nd', icon: Icons.looks_two_rounded),
    (grade: 3, label: '3rd', icon: Icons.looks_3_rounded),
    (grade: 4, label: '4th', icon: Icons.looks_4_rounded),
    (grade: 5, label: '5th', icon: Icons.looks_5_rounded),
    (grade: 6, label: '6th', icon: Icons.looks_6_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_saving) return;
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your nickname.');
      _nameFocus.requestFocus();
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(appProvider.notifier)
          .createProfile(_nameController.text.trim(), _grade);
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFFFF8E1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        AudioService.playClick();
                        context.go('/');
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: const Color(0xFF553522),
                    ),
                    const Expanded(
                      child: Text(
                        'CREATE PROFILE',
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
              // Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          // Character preview
                          Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2196F3).withValues(alpha: 0.15),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const CharacterPortrait(
                              characterKey: 'kangaroo',
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Title
                          const Text(
                            'Welcome to Spellaroo!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontFamily: 'Baloo2',
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF553522),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Let\'s meet our next spelling champ.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: const Color(0xFF8D6E63).withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Name input
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _error != null
                                    ? const Color(0xFFEF5350)
                                    : const Color(0xFFE7CD86),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _nameController,
                              focusNode: _nameFocus,
                              maxLength: 24,
                              textInputAction: TextInputAction.done,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: 'Enter your nickname',
                                hintStyle: TextStyle(
                                  color: const Color(0xFFBDB09A).withValues(alpha: 0.8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.person_rounded,
                                  color: Color(0xFF2196F3),
                                  size: 22,
                                ),
                                suffixIcon: _nameController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _nameController.clear();
                                          setState(() => _error = null);
                                        },
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 20,
                                          color: Color(0xFFBDB09A),
                                        ),
                                      )
                                    : null,
                                counterText: '',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) => _create(),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 16,
                                  color: Color(0xFFEF5350),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _error!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFEF5350),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 28),
                          // Grade level
                          Row(
                            children: [
                              const Icon(
                                Icons.school_rounded,
                                size: 20,
                                color: Color(0xFF553522),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Grade Level',
                                style: TextStyle(
                                  fontFamily: 'Baloo2',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xFF553522),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD54F).withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _gradeLabels[_grade - 1].label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: Color(0xFF553522),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Grade grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1.6,
                            ),
                            itemCount: _gradeLabels.length,
                            itemBuilder: (context, index) {
                              final g = _gradeLabels[index];
                              final selected = _grade == g.grade;

                              return GestureDetector(
                                onTap: _saving
                                    ? null
                                    : () => setState(() => _grade = g.grade),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFFFFD54F)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? const Color(0xFFF9A825)
                                          : const Color(0xFFE7CD86),
                                      width: selected ? 2 : 1.5,
                                    ),
                                    boxShadow: [
                                      if (selected)
                                        BoxShadow(
                                          color: const Color(0xFFF9A825)
                                              .withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        g.icon,
                                        size: 18,
                                        color: selected
                                            ? const Color(0xFF553522)
                                            : const Color(0xFF8D6E63),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        g.label,
                                        style: TextStyle(
                                          fontFamily: 'Baloo2',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: selected
                                              ? const Color(0xFF553522)
                                              : const Color(0xFF6D4C2E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          // Create button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: _saving ? null : _create,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF388E3C),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(0xFFE4DAC0),
                                disabledForegroundColor: const Color(0xFF776A54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF28682B),
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
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Get Started',
                                          style: TextStyle(
                                            fontFamily: 'Baloo2',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 22,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
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
