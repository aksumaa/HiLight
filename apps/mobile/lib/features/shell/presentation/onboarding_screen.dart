import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';
import '../../capture/presentation/language_chips.dart';
import '../../profile/application/settings_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  var _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final locale = ref.watch(settingsProvider.select((settings) => settings.localeCode));
    final slides = [
      (l10n.onboardingSlide1Title, l10n.onboardingSlide1Body),
      (l10n.onboardingSlide2Title, l10n.onboardingSlide2Body),
      (l10n.onboardingSlide3Title, l10n.onboardingSlide3Body),
    ];
    final last = _page == slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.appTitle, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              Text(
                l10n.onboardingLanguage,
                style: TextStyle(color: colors.secondary, fontFamily: HilightTheme.uiFont),
              ),
              const SizedBox(height: 8),
              LanguageChips(
                value: locale,
                onChanged: (code) => ref.read(settingsProvider.notifier).setLocale(code),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: (page) => setState(() => _page = page),
                  children: [
                    for (final slide in slides) _Slide(title: slide.$1, body: slide.$2),
                  ],
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < slides.length; i++)
                    Container(
                      width: i == _page ? 18 : 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: i == _page ? colors.primary : colors.hairline,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (!last) {
                    await _pages.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                    return;
                  }
                  await ref.read(settingsProvider.notifier).completeOnboarding();
                  if (context.mounted) context.go('/account');
                },
                child: Text(last ? l10n.onboardingStart : l10n.onboardingNext),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: HilightTheme.uiFont,
            fontSize: 32,
            height: 1.2,
            fontWeight: FontWeight.w500,
            color: colors.text,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          body,
          style: TextStyle(
            color: colors.secondary,
            fontFamily: HilightTheme.uiFont,
            fontSize: 16,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
