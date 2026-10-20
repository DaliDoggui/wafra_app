import 'package:flutter/material.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/order_model.dart';
import '../../../services/realtime_sync_service.dart';
import '../../../main.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

enum _OrderFilter { all, thisMonth, thisYear }

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  _OrderFilter _activeFilter = _OrderFilter.all;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  List<OrderModel> _liveOrders = List.from(dummyOrdersList);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    RealTimeSyncService.instance.addListener(_loadLiveOrders);
    _loadLiveOrders();
  }

  Future<void> _loadLiveOrders() async {
    final list = await ApiClient.instance.getMyRedemptions();
    final List<OrderModel> orders = [];
    for (final item in list) {
      final dateStr = item["redeemed_at"] ?? item["created_at"];
      final parsedDate = dateStr != null ? (DateTime.tryParse(dateStr) ?? DateTime.now()) : DateTime.now();
      final savedKd = (item["amount_saved_kd"] as num?)?.toDouble() ?? 0.0;
      final rawOrig = (item["original_amount"] as num?)?.toDouble();
      final tag = item["discount_tag"]?.toString() ?? "20% OFF";
      final pct = double.tryParse(RegExp(r'\d+').firstMatch(tag)?.group(0) ?? '20') ?? 20.0;
      final orig = (rawOrig != null && rawOrig > 0) ? rawOrig : (pct > 0 ? (savedKd / (pct / 100)) : 10.0);
      final finalPrice = (orig - savedKd) > 0 ? (orig - savedKd) : 0.0;
      final rawId = item["id"]?.toString() ?? "";
      final shortCode = rawId.length > 8 ? "WFR-${rawId.substring(0, 8).toUpperCase()}" : "WFR-$rawId";

      orders.add(
        OrderModel(
          id: item["id"]?.toString() ?? "ord",
          brandName: item["brand_name"]?.toString() ?? "Partner Brand",
          brandLogoEmoji: "🏪",
          categoryName: "Partner Discount",
          branchName: item["branch_name"]?.toString() ?? "Kuwait Branch",
          redeemedAt: parsedDate,
          originalPrice: orig,
          discountPercent: pct,
          savedAmount: savedKd,
          finalPrice: finalPrice,
          receiptCode: shortCode,
        ),
      );
    }
    if (mounted) {
      setState(() {
        _liveOrders = orders;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    RealTimeSyncService.instance.removeListener(_loadLiveOrders);
    _fadeController.dispose();
    super.dispose();
  }

  // ─── Filter logic ──────────────────────────────────────────────
  List<OrderModel> get _filteredOrders {
    final now = DateTime.now();
    return _liveOrders.where((o) {
      switch (_activeFilter) {
        case _OrderFilter.thisMonth:
          return o.redeemedAt.year == now.year &&
              o.redeemedAt.month == now.month;
        case _OrderFilter.thisYear:
          return o.redeemedAt.year == now.year;
        case _OrderFilter.all:
          return true;
      }
    }).toList();
  }

  // ─── Computed stats ────────────────────────────────────────────
  int get _totalOrders => _filteredOrders.length;

  double get _totalSaved =>
      _filteredOrders.fold(0.0, (sum, o) => sum + o.savedAmount);

  @override
  Widget build(BuildContext context) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.background;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textPrimary;
    final textMutedCol = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;

    final orders = _filteredOrders;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(cardBg, textCol, borderColor),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: orders.isEmpty
                  ? _buildEmptyState(textCol, textMutedCol)
                  : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                      child: Column(
                        children: [
                          _buildSummaryCard(),
                          const SizedBox(height: 20),
                          _buildFilterChips(cardBg, borderColor, textMutedCol),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildOrderCard(orders[index], cardBg, borderColor, textCol, textMutedCol, isDark),
                        childCount: orders.length,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(Color cardBg, Color textCol, Color borderColor) {
    return AppBar(
      backgroundColor: cardBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: textCol),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(
        isArabic ? "طلباتي" : "My Orders",
        style: TextStyle(
          color: textCol,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: textCol),
          onPressed: () {
            setState(() => _isLoading = true);
            _loadLiveOrders();
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: borderColor),
      ),
    );
  }

  // ─── Summary Card ──────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0052CC), Color(0xFF0066FF), Color(0xFF338BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                isArabic ? "ملخص التوفير" : "Savings Summary",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Big total saved
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _totalSaved.toStringAsFixed(3),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isArabic ? "د.ك موفّرة" : "KD Saved",
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 26),
          // Stats row
          Row(
            children: [
              _buildStat(
                icon: Icons.check_circle_outline_rounded,
                label: isArabic ? "الطلبات المكتملة" : "Completed Orders",
                value: "$_totalOrders",
              ),
              _buildVerticalDivider(),
              _buildStat(
                icon: Icons.local_offer_outlined,
                label: isArabic ? "متوسط الخصم" : "Avg. Discount",
                value: _totalOrders > 0
                    ? "${(_filteredOrders.fold<double>(0, (s, o) => s + o.discountPercent) / _totalOrders).toStringAsFixed(0)}%"
                    : "—",
              ),
              _buildVerticalDivider(),
              _buildStat(
                icon: Icons.storefront_outlined,
                label: isArabic ? "المتاجر المستخدمة" : "Brands Used",
                value: "${_filteredOrders.map((o) => o.brandName).toSet().length}",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white54, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 44,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // ─── Filter Chips ──────────────────────────────────────────────
  Widget _buildFilterChips(Color cardBg, Color borderColor, Color textMutedCol) {
    return Row(
      children: [
        _chip(isArabic ? "الكل" : "All", _OrderFilter.all, cardBg, borderColor, textMutedCol),
        const SizedBox(width: 8),
        _chip(isArabic ? "هذا الشهر" : "This Month", _OrderFilter.thisMonth, cardBg, borderColor, textMutedCol),
        const SizedBox(width: 8),
        _chip(isArabic ? "هذه السنة" : "This Year", _OrderFilter.thisYear, cardBg, borderColor, textMutedCol),
      ],
    );
  }

  Widget _chip(String label, _OrderFilter filter, Color cardBg, Color borderColor, Color textMutedCol) {
    final isSelected = _activeFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = filter;
          _fadeController.reset();
          _fadeController.forward();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : cardBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : borderColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textMutedCol,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ─── Order Card ────────────────────────────────────────────────
  Widget _buildOrderCard(OrderModel order, Color cardBg, Color borderColor, Color textCol, Color textMutedCol, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        children: [
          // ── Top row: brand + status ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                // Brand logo
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.07),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(order.brandLogoEmoji,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 12),
                // Brand info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.brandName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textCol,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        order.branchName,
                        style: TextStyle(
                          fontSize: 12,
                          color: textMutedCol,
                        ),
                      ),
                    ],
                  ),
                ),
                // Discount tag inline
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.discountYellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.discountTagText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: borderColor),

          // ── Middle row: amounts ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _buildAmountInfo(
                  label: isArabic ? "السعر الأصلي" : "Original Price",
                  value: "${order.originalPrice.toStringAsFixed(3)} ${isArabic ? 'د.ك' : 'KD'}",
                  valueColor: textCol,
                  labelColor: textMutedCol,
                ),
                _buildDot(borderColor),
                _buildAmountInfo(
                  label: isArabic ? "المدفوع" : "You Paid",
                  value: isArabic ? order.finalPriceText.replaceAll("KD", "د.ك") : order.finalPriceText,
                  valueColor: AppColors.primaryBlue,
                  labelColor: textMutedCol,
                ),
                _buildDot(borderColor),
                _buildAmountInfo(
                  label: isArabic ? "وفرت" : "You Saved",
                  value: isArabic ? order.savedText.replaceAll("KD", "د.ك") : order.savedText,
                  valueColor: AppColors.greenSuccess,
                  labelColor: textMutedCol,
                  isBold: true,
                ),
              ],
            ),
          ),

          // ── Discount badge strip ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.5) : AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                // Discount tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.discountYellow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.discountTagText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.categoryName,
                    style: TextStyle(
                      fontSize: 11,
                      color: textMutedCol,
                    ),
                  ),
                ),
                // Date + receipt
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(order.redeemedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: textMutedCol,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      order.receiptCode,
                      style: TextStyle(
                        fontSize: 9,
                        color: textMutedCol,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInfo({
    required String label,
    required String value,
    required Color valueColor,
    required Color labelColor,
    bool isBold = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: labelColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color borderColor) {
    return Container(
      width: 1,
      height: 30,
      color: borderColor,
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  // ─── Empty State ───────────────────────────────────────────────
  Widget _buildEmptyState(Color textCol, Color textMutedCol) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined,
                size: 60, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 20),
          Text(
            isArabic ? "لا توجد طلبات بعد" : "No Orders Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textCol,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? "استكشف المتاجر الشريكة واستخدم كود وفرة\nللحصول على خصومات حصرية!"
                : "Explore partner brands and use your\nWafra QR code to unlock discounts!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: textMutedCol),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.explore_outlined, size: 18),
            label: Text(isArabic ? "استكشف العروض" : "Explore Deals"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────
  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 1) {
      return isArabic ? "منذ ${diff.inMinutes} دقيقة" : "${diff.inMinutes}m ago";
    }
    if (diff.inDays == 0) {
      return isArabic ? "اليوم ${_time(dt)}" : "Today ${_time(dt)}";
    }
    if (diff.inDays == 1) {
      return isArabic ? "أمس ${_time(dt)}" : "Yesterday ${_time(dt)}";
    }
    const monthsEn = [
      "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];
    const monthsAr = [
      "يناير","فبراير","مارس","أبريل","مايو","يونيو",
      "يوليو","أغسطس","سبتمبر","أكتوبر","نوفمبر","ديسمبر"
    ];
    final mName = isArabic ? monthsAr[dt.month - 1] : monthsEn[dt.month - 1];
    return "${dt.day} $mName ${_time(dt)}";
  }

  String _time(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = isArabic
        ? (dt.hour >= 12 ? 'م' : 'ص')
        : (dt.hour >= 12 ? 'PM' : 'AM');
    return "$h:$m $ampm";
  }
}
