import 'package:flutter/material.dart';
import '../../common/basewidget/app_button.dart';
import '../../common/basewidget/app_dots_indicator.dart';
import '../../common/basewidget/app_logo.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../widgets/onboarding_slide.dart';

/// Carrousel d'onboarding (3 slides). La navigation vers l'écran suivant
/// (accueil / auth) est déléguée via [onFinish] — ce widget ne connaît
/// pas les routes de l'application.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  List<Map<String, String>> get _slides => [
        {
          'title': AppLocalizations.t('onboarding_1_title'),
          'desc': AppLocalizations.t('onboarding_1_desc'),
        },
        {
          'title': AppLocalizations.t('onboarding_2_title'),
          'desc': AppLocalizations.t('onboarding_2_desc'),
        },
        {
          'title': AppLocalizations.t('onboarding_3_title'),
          'desc': AppLocalizations.t('onboarding_3_desc'),
        },
      ];

  bool get _isLast => _index == _slides.length - 1;

  void _next() {
    if (_isLast) {
      widget.onFinish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppScale.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(visible: !_isLast, onSkip: widget.onFinish),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => OnboardingSlide(
                  title: _slides[i]['title']!,
                  description: _slides[i]['desc']!,
                ),
              ),
            ),
            AppDotsIndicator(count: _slides.length, activeIndex: _index),
            SizedBox(height: AppDimensions.spaceLg.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH.w),
              child: AppButton(
                label: _isLast
                    ? AppLocalizations.t('onboarding_start')
                    : AppLocalizations.t('onboarding_next'),
                icon: Icons.arrow_forward,
                onPressed: _next,
              ),
            ),
            SizedBox(height: AppDimensions.spaceMd.h),
            const AppLogo(size: AppLogoSize.small),
            SizedBox(height: AppDimensions.spaceMd.h),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.visible, required this.onSkip});

  final bool visible;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH.w,
        vertical: AppDimensions.spaceSm.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (visible)
            TextButton(
              onPressed: onSkip,
              child: Text(
                AppLocalizations.t('onboarding_skip'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}