import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'auth_assets.dart';

/// Shared layout for Login / Register / OTP:
/// blue gradient header (back button + logo + optional hero image)
/// with a rounded white card holding the form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.hero,
    this.showBack = true,
    this.onBack,
  });

  /// Content inside the white card.
  final Widget child;

  /// Illustration under the logo (use [AuthHeroImage]).
  final Widget? hero;

  final bool showBack;
  final VoidCallback? onBack;

  static const LinearGradient _background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppPalette.headerGradientStart,
      AppPalette.headerGradientMid,
      AppPalette.pageGradientStart,
      AppPalette.pageGradientEnd,
    ],
    stops: [0, 0.3, 0.65, 1],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.pageGradientEnd,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: _background),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _AuthHeader(
                    hero: hero,
                    showBack: showBack,
                    onBack: onBack,
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _AuthCard(child: child),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({this.hero, required this.showBack, this.onBack});

  final Widget? hero;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const AuthLogo(),
              if (showBack)
                Positioned(
                  left: 0,
                  top: 0,
                  child: Material(
                    color: AppPalette.overlayWhite20,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onBack ?? () => Navigator.of(context).maybePop(),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: AppPalette.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (hero != null) hero!,
        ],
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 20, 14, 14),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: AppPalette.buttonShadowColor.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// "Game Edu" logo. Uses [AuthAssets.logo] if present, otherwise a
/// simple built-in fallback.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, this.height = 90});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Image.asset(
        AuthAssets.logo,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const _FallbackLogo(),
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.school_rounded, size: 40, color: AppPalette.white),
        SizedBox(height: 2),
        Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            children: [
              TextSpan(
                text: 'Game ',
                style: TextStyle(color: AppPalette.white),
              ),
              TextSpan(
                text: 'Edu',
                style: TextStyle(color: AppPalette.accentCyan),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Illustration shown in the header. Falls back to an icon bubble if the
/// asset is missing.
class AuthHeroImage extends StatelessWidget {
  const AuthHeroImage({
    super.key,
    required this.asset,
    required this.fallbackIcon,
    this.height = 200,
  });

  final String asset;
  final IconData fallbackIcon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        height: height,
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.overlayWhite20,
              ),
              child: Icon(fallbackIcon, color: AppPalette.white, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}
