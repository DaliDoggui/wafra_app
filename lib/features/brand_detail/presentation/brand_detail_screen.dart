import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/wafra_image_widget.dart';
import '../../../core/widgets/discount_badge.dart';
import '../../../models/offer_model.dart';
import '../../../services/location_service.dart';
import '../../../services/realtime_sync_service.dart';
import '../../../core/localization/app_locale.dart';
import '../../../main.dart';
import '../../redemption/presentation/dynamic_qr_screen.dart';

class BrandDetailScreen extends StatelessWidget {
  final OfferModel offer;

  const BrandDetailScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18, color: textCol),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          offer.brandName,
          style: TextStyle(
            color: textCol,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          ListenableBuilder(
            listenable: RealTimeSyncService.instance,
            builder: (context, _) {
              final isSaved = RealTimeSyncService.instance.isOfferSaved(offer.id);
              return IconButton(
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? AppColors.discountYellow : textCol,
                ),
                onPressed: () {
                  RealTimeSyncService.instance.toggleSave(offer.id);
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Brand Banner Image with Yellow Discount Tag
              Stack(
                children: [
                  WafraImageWidget(
                    imageUrl: offer.bannerImageUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    fallbackEmoji: offer.brandLogoEmoji,
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: DiscountBadge(offer: offer, fontSize: 16),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Avatar, Title & Subtitle
                    Row(
                      children: [
                        WafraImageWidget(
                          imageUrl: offer.brandLogoUrl,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(14),
                          fallbackEmoji: offer.brandLogoEmoji,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer.brandName,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textCol,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                offer.subtitleText,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (offer.isSpecialActive && (offer.specialDiscountTitle?.isNotEmpty ?? false)) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFF59E0B)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('🔥 ', style: TextStyle(fontSize: 12)),
                                      Flexible(
                                        child: Text(
                                          offer.specialDiscountTitle!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFB45309),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Info Badges Row matching Screenshot 2
                    Row(
                      children: [
                        _buildInfoChip(Icons.calendar_today, offer.expiresText),
                        const SizedBox(width: 8),
                        _buildInfoChip(Icons.store, offer.locationBranch.isNotEmpty ? offer.locationBranch : tr("available_branches")),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons (Get Directions & Get Discount)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _showMapDirectionsModal(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              tr("get_directions"),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DynamicQrScreen(
                                    brandName: offer.brandName,
                                    offerId: offer.id,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              tr("get_discount"),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Description & Terms
                    Text(
                      tr("about_offer"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textCol,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      offer.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                        height: 1.5,
                      ),
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showMapDirectionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RealMapDirectionsModal(offer: offer),
    );
  }
}

class RealMapDirectionsModal extends StatefulWidget {
  final OfferModel offer;

  const RealMapDirectionsModal({super.key, required this.offer});

  @override
  State<RealMapDirectionsModal> createState() => _RealMapDirectionsModalState();
}

class _RealMapDirectionsModalState extends State<RealMapDirectionsModal> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  bool _isLoadingGps = false;
  double _currentZoom = 15.0;
  String? _calculatedDistanceText;

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    setState(() => _isLoadingGps = true);
    try {
      final pos = await LocationService().getCurrentLocation();
      if (pos != null && mounted) {
        final uLoc = LatLng(pos.latitude, pos.longitude);
        final distMeters = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          widget.offer.latitude,
          widget.offer.longitude,
        );

        String distStr;
        if (distMeters < 1000) {
          distStr = isArabic ? 'على بعد ${distMeters.round()} م' : '${distMeters.round()} m away';
        } else {
          distStr = isArabic ? 'على بعد ${(distMeters / 1000).toStringAsFixed(1)} كم' : '${(distMeters / 1000).toStringAsFixed(1)} km away';
        }

        setState(() {
          _userLocation = uLoc;
          _calculatedDistanceText = distStr;
          _isLoadingGps = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingGps = false);
    }
  }

  void _zoomIn() {
    _currentZoom = (_currentZoom + 1).clamp(4.0, 18.0);
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  void _zoomOut() {
    _currentZoom = (_currentZoom - 1).clamp(4.0, 18.0);
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  void _centerOnStore() {
    _mapController.move(LatLng(widget.offer.latitude, widget.offer.longitude), 15.5);
  }

  void _centerOnUser() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 15.5);
    } else {
      _fetchUserLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeLocation = LatLng(widget.offer.latitude, widget.offer.longitude);

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.offer.brandName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      isArabic ? 'خريطة تفاعلية ومسار المتجر' : 'Live Interactive Map & Route Preview',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isArabic ? 'مباشر GPS' : 'GPS Live',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Interactive Map Container
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: storeLocation,
                        initialZoom: 15.0,
                        minZoom: 3.0,
                        maxZoom: 18.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.wafra.app',
                        ),
                        if (_userLocation != null)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [_userLocation!, storeLocation],
                                strokeWidth: 3.5,
                                color: AppColors.primaryBlue.withOpacity(0.8),
                                strokeCap: StrokeCap.round,
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: [
                            // Store Location Marker
                            Marker(
                              point: storeLocation,
                              width: 140,
                              height: 80,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(widget.offer.brandLogoEmoji, style: const TextStyle(fontSize: 12)),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            widget.offer.brandName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.location_on_rounded,
                                    color: Color(0xFFE11D48),
                                    size: 38,
                                  ),
                                ],
                              ),
                            ),
                            // User Current Location Marker
                            if (_userLocation != null)
                              Marker(
                                point: _userLocation!,
                                width: 50,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF0284C7).withOpacity(0.25),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF0284C7),
                                        border: Border.all(color: Colors.white, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    // Floating Interactive Map Controls
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Column(
                        children: [
                          _mapButton(icon: Icons.add, tooltip: isArabic ? 'تكبير' : 'Zoom In', onTap: _zoomIn),
                          const SizedBox(height: 6),
                          _mapButton(icon: Icons.remove, tooltip: isArabic ? 'تصغير' : 'Zoom Out', onTap: _zoomOut),
                          const SizedBox(height: 6),
                          _mapButton(
                            icon: Icons.store_mall_directory_rounded,
                            tooltip: isArabic ? 'موقع المتجر' : 'Center Store',
                            onTap: _centerOnStore,
                            color: const Color(0xFFE11D48),
                          ),
                          const SizedBox(height: 6),
                          _mapButton(
                            icon: _isLoadingGps ? Icons.hourglass_top_rounded : Icons.my_location_rounded,
                            tooltip: isArabic ? 'موقعي' : 'My Location',
                            onTap: _centerOnUser,
                            color: AppColors.primaryBlue,
                          ),
                        ],
                      ),
                    ),

                    // Attribution Watermark
                    Positioned(
                      bottom: 4,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '© OpenStreetMap contributors',
                          style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Details & Actions
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.near_me_rounded, size: 16, color: AppColors.primaryBlue),
                          const SizedBox(width: 6),
                          Text(
                            _calculatedDistanceText ?? widget.offer.distanceText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "📍 ${widget.offer.latitude.toStringAsFixed(4)}° N, ${widget.offer.longitude.toStringAsFixed(4)}° E • ${widget.offer.locationBranch}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse(
                      "https://www.google.com/maps/search/?api=1&query=${widget.offer.latitude},${widget.offer.longitude}",
                    );
                    try {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } catch (_) {
                      await launchUrl(url);
                    }
                  },
                  icon: const Icon(Icons.directions_outlined, size: 20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  label: Text(
                    isArabic ? "فتح في خرائط Google (الملاحة)" : "Open in Google Maps (Turn-by-Turn)",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = const Color(0xFF334155),
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}
