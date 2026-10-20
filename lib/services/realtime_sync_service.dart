import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../models/offer_model.dart';

class RealTimeSyncService extends ChangeNotifier {
  static final RealTimeSyncService _instance = RealTimeSyncService._internal();
  static RealTimeSyncService get instance => _instance;

  RealTimeSyncService._internal();

  final Set<String> _savedOfferIds = {};
  Map<String, dynamic> _stats = {
    "saved_offers_count": 0,
    "used_deals_count": 0,
    "total_savings_kd": 0.0,
  };
  List<OfferModel> _allOffers = [];
  bool _isInitialized = false;
  Timer? _pollingTimer;

  Set<String> get savedOfferIds => Set.unmodifiable(_savedOfferIds);
  Map<String, dynamic> get stats => Map.unmodifiable(_stats);
  List<OfferModel> get allOffers => List.unmodifiable(_allOffers);
  int get savedCount => _savedOfferIds.length;
  int get usedDealsCount => (_stats["used_deals_count"] as num?)?.toInt() ?? 0;
  double get totalSavingsKd => (_stats["total_savings_kd"] as num?)?.toDouble() ?? 0.0;

  bool isOfferSaved(String offerId) => _savedOfferIds.contains(offerId);

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await syncAll();

    // Start background live polling every 4 seconds for real-time updates
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      syncAll();
    });
  }

  Future<void> syncAll() async {
    try {
      final offers = await ApiClient.instance.getOffers();
      _allOffers = offers;
      _savedOfferIds.clear();
      for (final o in offers) {
        if (o.isSaved) {
          _savedOfferIds.add(o.id);
        }
      }

      final statsData = await ApiClient.instance.getUserSavingsStats();
      if (statsData != null) {
        _stats = Map<String, dynamic>.from(statsData);
        _stats["saved_offers_count"] = _savedOfferIds.length;
      }

      notifyListeners();
    } catch (_) {}
  }

  /// Optimistic toggle save offer across all screens immediately
  Future<bool> toggleSave(String offerId) async {
    final willSave = !_savedOfferIds.contains(offerId);
    if (willSave) {
      _savedOfferIds.add(offerId);
    } else {
      _savedOfferIds.remove(offerId);
    }
    _stats["saved_offers_count"] = _savedOfferIds.length;
    notifyListeners();

    // Call backend API in background
    final serverStatus = await ApiClient.instance.toggleSaveOffer(offerId);
    if (serverStatus != null && serverStatus != willSave) {
      if (serverStatus) {
        _savedOfferIds.add(offerId);
      } else {
        _savedOfferIds.remove(offerId);
      }
      _stats["saved_offers_count"] = _savedOfferIds.length;
      notifyListeners();
    }
    return willSave;
  }

  /// Called in real-time as soon as the partner shop approves customer discount
  void onRedemptionApproved(Map<String, dynamic> redemptionData) {
    final savedKd = (redemptionData["amount_saved_kd"] as num?)?.toDouble() ?? 0.0;
    final currentSavings = (_stats["total_savings_kd"] as num?)?.toDouble() ?? 0.0;
    final currentDeals = (_stats["used_deals_count"] as num?)?.toInt() ?? 0;

    final newSavings = (redemptionData["user_total_savings_kd"] as num?)?.toDouble() ?? (currentSavings + savedKd);

    _stats["total_savings_kd"] = newSavings;
    _stats["used_deals_count"] = currentDeals + 1;

    notifyListeners();
  }

  Future<void> refreshStats() async {
    final statsData = await ApiClient.instance.getUserSavingsStats();
    if (statsData != null) {
      _stats = Map<String, dynamic>.from(statsData);
      notifyListeners();
    }
  }
}
