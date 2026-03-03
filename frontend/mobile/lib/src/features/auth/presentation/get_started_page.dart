import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'signup_page.dart';

/// Get Started screen — first screen after splash.
/// Visual design matches the Figma spec: hero illustration on top half,
/// orange rounded card on the bottom with Log In / Create Account buttons.
class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  // Brand colours (matching AppColors in app_theme.dart but kept local
  // to avoid coupling to theme for pixel accuracy)
  static const _cardBg = Color(0xFFEFA07A);
  static const _textDark = Color(0xFF333333);
  static const _textMid = Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8DE), // warm tan behind illustration
      body: Stack(
        children: [
          // ── Hero illustration fills the top 55 % of the screen ──────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: Image.asset(
              'assets/get_started_hero.png',
              fit: BoxFit.cover,
            ),
          ),

          // ── PocketRoom logo overlaid on the illustration ─────────────────
          Positioned(
            top: size.height * 0.17,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo text row: "Pocket" (dark) + "Room" (orange) + AR icon
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   'Pocket',
                          //   style: GoogleFonts.fredoka(
                          //     fontSize: 48,
                          //     fontWeight: FontWeight.bold,
                          //     color: _textDark,
                          //     height: 1.0,
                          //   ),
                          // ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Text(
                              //   'Room',
                              //   style: GoogleFonts.fredoka(
                              //     fontSize: 48,
                              //     fontWeight: FontWeight.bold,
                              //     color: const Color(0xFFFF8A3D),
                              //     height: 1.0,
                              //   ),
                              // ),
                              // const SizedBox(width: 6),
                              // AR/3D box icon
                              Image.asset(
                                'assets/logo.png',
                                width: 250,
                                height: 250,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -50), // negative y moves up
                    child: Text(
                      'A CS-120 project',
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        color: _textMid,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom card ──────────────────────────────────────────────────
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              // Slightly overlaps the illustration (wave-like illusion via border radius)
              margin: const EdgeInsets.only(bottom: 32, left: 20, right: 20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 212, 184, 1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Card title
                  Text(
                    "Let's get started",
                    style: GoogleFonts.fredoka(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Log In button
                  _CardButton(
                    label: 'Log in',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Create Account button
                  _CardButton(
                    label: 'Create account',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // "Get started as seller" underlined link
                  GestureDetector(
                    onTap: () {
                      // TODO: wire seller onboarding when available
                    },
                    child: Text(
                      'Get started as seller',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        color: _textDark,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable button inside the orange card on the Get Started screen.
class _CardButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CardButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFF5C9A8),
          foregroundColor: const Color(0xFF333333),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(label, style: GoogleFonts.fredoka(fontSize: 18)),
      ),
    );
  }
}
