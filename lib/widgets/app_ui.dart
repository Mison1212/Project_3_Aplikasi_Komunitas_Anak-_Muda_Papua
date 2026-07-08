import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const darkTeal = Color(0xFF0B4F4A);
  static const primaryTeal = Color(0xFF0B9E8E);
  static const accentTeal = Color(0xFF06C2AE);
  static const background = Color(0xFFFFF3C4);
  static const cardSurface = Color(0xFFFFFDF5);
  static const cardBorder = Color(0xFFE8D996);
  static const mutedText = Color(0xFF6B8581);
  static const titleText = Color(0xFF0D2B2B);
  static const inputFill = Color(0xFFEAF8F7);
}

class AppGradients {
  const AppGradients._();

  static const teal = LinearGradient(
    colors: [AppColors.darkTeal, AppColors.primaryTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppBrandIcon extends StatelessWidget {
  const AppBrandIcon({
    super.key,
    this.size = 48,
    this.borderRadius = 16,
  });

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        'assets/icon/papua_youth_career_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 24),
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: const BoxDecoration(gradient: AppGradients.teal),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ] else if (icon != null) ...[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFC6F4EF),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.only(bottom: 12),
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkTeal.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFFE5B72D).withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class IconBubble extends StatelessWidget {
  const IconBubble({
    super.key,
    required this.icon,
    this.color = AppColors.primaryTeal,
    this.background = const Color(0xFFE0F5F3),
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final data = switch (normalized) {
      'accepted' => (
          'Diterima',
          const Color(0xFFE2F8EE),
          const Color(0xFF059669),
        ),
      'rejected' => (
          'Ditolak',
          const Color(0xFFFFECEC),
          const Color(0xFFE53935),
        ),
      _ => (
          'Menunggu',
          const Color(0xFFFFF5DD),
          const Color(0xFFD97706),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: data.$2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: data.$3.withOpacity(0.26)),
        boxShadow: [
          BoxShadow(
            color: data.$3.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: data.$3, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            data.$1,
            style: TextStyle(
              color: data.$3,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
