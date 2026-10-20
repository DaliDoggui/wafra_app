import 'dart:ui';
import 'package:flutter/material.dart';
import '../localization/app_locale.dart';

/// In-app push notification banner styled exactly like the high-end
/// lockscreen / homescreen mockups for Wafra geofencing alerts.
class WafraPushNotificationBanner extends StatefulWidget {
  final String title;
  final String body;
  final String? timeAgo;
  final String? brandName;
  final String? discountTag;
  final String? distanceText;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration autoDismissDuration;

  const WafraPushNotificationBanner({
    super.key,
    required this.title,
    required this.body,
    this.timeAgo = 'Just now',
    this.brandName,
    this.discountTag,
    this.distanceText,
    this.onTap,
    this.onDismiss,
    this.autoDismissDuration = const Duration(seconds: 7),
  });

  /// Static helper to pop down the notification anywhere in the app
  static OverlayEntry? show(
    BuildContext context, {
    required String title,
    required String body,
    String? timeAgo = 'Just now',
    String? brandName,
    String? discountTag,
    String? distanceText,
    VoidCallback? onTap,
    Duration autoDismissDuration = const Duration(seconds: 7),
  }) {
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return null;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 8,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: WafraPushNotificationBanner(
            title: title,
            body: body,
            timeAgo: timeAgo,
            brandName: brandName,
            discountTag: discountTag,
            distanceText: distanceText,
            autoDismissDuration: autoDismissDuration,
            onTap: () {
              entry.remove();
              onTap?.call();
            },
            onDismiss: () {
              entry.remove();
            },
          ),
        ),
      ),
    );

    overlayState.insert(entry);
    return entry;
  }

  @override
  State<WafraPushNotificationBanner> createState() =>
      _WafraPushNotificationBannerState();
}

class _WafraPushNotificationBannerState
    extends State<WafraPushNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();

    // Auto dismiss timer
    Future.delayed(widget.autoDismissDuration, () {
      if (mounted && !_dismissed) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! < -100) {
              _dismiss();
            }
          },
          onTap: () {
            _dismissed = true;
            widget.onTap?.call();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: const Color(0xFF0052CC).withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                  decoration: BoxDecoration(
                    color: const Color(0xF0131B2E), // Deep glass slate
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Official Wafra App Icon Container
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Image.asset(
                          'assets/images/wafra_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 13),

                      // Notification Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header Row: App Name & Timestamp & Close
                            Row(
                              children: [
                                Text(
                                  isArabic ? "وفرة" : "WAFRA",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "• ${widget.timeAgo ?? (isArabic ? 'الآن' : 'Just now')}",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.45),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _dismiss,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Notification Title
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 3),

                            // Notification Body
                            Text(
                              widget.body,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12.5,
                                height: 1.25,
                              ),
                            ),

                            // Footer hint pill
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981), // Emerald pulse
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isArabic ? "اضغط لفتح القسيمة بالرقم الوظيفي" : "Tap to unlock voucher with Worker ID",
                                  style: TextStyle(
                                    color: Colors.blue.shade300,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
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
            ),
          ),
        ),
      ),
    );
  }
}
