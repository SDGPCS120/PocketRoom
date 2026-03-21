import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A premium, customizable banner widget for featuring collections, 
/// promotions, or new features.
class FeatureBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? tagText;
  final Color? tagColor;
  final List<Color>? gradientColors;
  final Widget? foregroundWidget;
  final String? backgroundImagePath;
  final String? ctaText;
  final VoidCallback? onCtaTap;
  final VoidCallback? onTap;
  final double height;
  final EdgeInsetsGeometry margin;

  const FeatureBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.tagText,
    this.tagColor,
    this.gradientColors,
    this.foregroundWidget,
    this.backgroundImagePath,
    this.ctaText,
    this.onCtaTap,
    this.onTap,
    this.height = 200,
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradient = [
      const Color(0xFFCfb088),
      const Color(0xFF5A4A3A),
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors ?? defaultGradient,
          ),
          image: backgroundImagePath != null 
            ? DecorationImage(
                image: AssetImage(backgroundImagePath!),
                fit: BoxFit.cover,
                opacity: 0.2,
              )
            : null,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Foreground Graphic (e.g. Sofa image or Icon)
              if (foregroundWidget != null)
                Positioned(
                  right: -10,
                  top: 0,
                  bottom: 0,
                  child: foregroundWidget!,
                ),
              
              // Text Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (tagText != null) ...[
                      Text(
                        tagText!.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: tagColor ?? const Color(0xFFFF8A3D),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        height: 1.1,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 180,
                        child: Text(
                          subtitle!,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    if (ctaText != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: onCtaTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tagColor ?? const Color(0xFFFFD27A),
                            foregroundColor: const Color(0xFF183328),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            ctaText!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
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
