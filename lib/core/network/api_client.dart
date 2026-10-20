import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/offer_model.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  static const String _tokenPrefKey = "wafra_auth_token";
  static const String _userPrefKey = "wafra_current_user";

  static String get defaultBaseUrl {
    const customUrl = String.fromEnvironment('API_URL');
    if (customUrl.isNotEmpty) return customUrl;
    if (kIsWeb) {
      final uri = Uri.base;
      if (uri.queryParameters.containsKey('api') && uri.queryParameters['api']!.isNotEmpty) {
        return uri.queryParameters['api']!;
      }
      if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
        return "http://127.0.0.1:8000/api/v1";
      }
      if (uri.host.startsWith('192.168.') || uri.host.startsWith('10.') || uri.host.startsWith('172.')) {
        return "http://${uri.host}:8000/api/v1";
      }
      // Cloud HTTPS Tunnel Default
      return "https://wafra-backend.onrender.com/api/v1";
    }
    return "https://wafra-backend.onrender.com/api/v1";
  }

  late String baseUrl;
  final Dio _dio = Dio();
  String? authToken;
  Map<String, dynamic>? currentUser;

  bool get isLoggedIn => authToken != null && authToken!.isNotEmpty;

  ApiClient._internal() {
    baseUrl = defaultBaseUrl;
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 8);
    _dio.options.receiveTimeout = const Duration(seconds: 8);
  }

  static const String _baseUrlPrefKey = "wafra_custom_base_url";

  Future<void> updateBaseUrl(String newUrl) async {
    baseUrl = newUrl;
    _dio.options.baseUrl = newUrl;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_baseUrlPrefKey, newUrl);
    } catch (_) {}
  }

  void setToken(String token) {
    authToken = token;
    _dio.options.headers["Authorization"] = "Bearer $token";
  }

  /// Saves session token and user profile locally for persistent login
  Future<void> saveSession(String token, Map<String, dynamic> user) async {
    setToken(token);
    currentUser = user;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenPrefKey, token);
      await prefs.setString(_userPrefKey, jsonEncode(user));
    } catch (_) {}
  }

  /// Restores session and server URL from local storage on app start
  Future<bool> loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBaseUrl = prefs.getString(_baseUrlPrefKey);
      if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
        baseUrl = savedBaseUrl;
        _dio.options.baseUrl = savedBaseUrl;
      }

      final token = prefs.getString(_tokenPrefKey);
      final userStr = prefs.getString(_userPrefKey);

      if (token != null && token.isNotEmpty && userStr != null && userStr.isNotEmpty) {
        setToken(token);
        currentUser = jsonDecode(userStr) as Map<String, dynamic>?;
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Clears local session upon user logout
  Future<void> clearSession() async {
    authToken = null;
    currentUser = null;
    _dio.options.headers.remove("Authorization");
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenPrefKey);
      await prefs.remove(_userPrefKey);
    } catch (_) {}
  }

  // 1. Unified Login (Supports Civil ID or Email)
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final cleanId = identifier.trim();
    if (cleanId.contains("@")) {
      return loginWithEmail(cleanId, password);
    } else {
      return loginWithCivilId(cleanId, password);
    }
  }

  // 1a. Civil ID Login
  Future<Map<String, dynamic>> loginWithCivilId(String civilId, String password) async {
    try {
      final response = await _dio.post(
        "/auth/login-civil-id",
        data: {"civil_id": civilId.trim(), "password": password.trim()},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = Map<String, dynamic>.from(response.data);
        final token = data["access_token"] as String?;
        final user = data["user"] as Map<String, dynamic>? ?? {};
        if (token != null) {
          await saveSession(token, user);
        } else {
          currentUser = user;
        }
        return {"success": true, "data": data};
      }
    } on DioException catch (e) {
      final detail = e.response?.data?["detail"]?.toString() ?? "";
      final isPending = e.response?.statusCode == 403 || detail.contains("pending") || detail.contains("انتظار");
      return {
        "success": false,
        "isPending": isPending,
        "message": detail.isNotEmpty ? detail : "Worker ID or password incorrect",
      };
    } catch (e) {
      return {"success": false, "isPending": false, "message": e.toString()};
    }
    return {"success": false, "isPending": false, "message": "Login failed"};
  }

  // 1b. Email Login
  Future<Map<String, dynamic>> loginWithEmail(String email, String password) async {
    try {
      final response = await _dio.post(
        "/auth/login-email",
        data: {"email": email.trim(), "password": password.trim()},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = Map<String, dynamic>.from(response.data);
        final token = data["access_token"] as String?;
        final user = data["user"] as Map<String, dynamic>? ?? {};
        if (token != null) {
          await saveSession(token, user);
        } else {
          currentUser = user;
        }
        return {"success": true, "data": data};
      }
    } on DioException catch (e) {
      final detail = e.response?.data?["detail"]?.toString() ?? "";
      final isPending = e.response?.statusCode == 403 || detail.contains("pending") || detail.contains("انتظار");
      return {
        "success": false,
        "isPending": isPending,
        "message": detail.isNotEmpty ? detail : "Invalid email or password",
      };
    } catch (e) {
      return {"success": false, "isPending": false, "message": e.toString()};
    }
    return {"success": false, "isPending": false, "message": "Login failed"};
  }

  // 1b-2. Google Sign-In Login
  Future<Map<String, dynamic>> loginWithGoogle({
    required String email,
    String? name,
    String? photoUrl,
    String? idToken,
  }) async {
    try {
      final response = await _dio.post(
        "/auth/login-google",
        data: {
          "email": email.trim(),
          "name": name?.trim(),
          "photo_url": photoUrl,
          "id_token": idToken,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = Map<String, dynamic>.from(response.data);
        final token = data["access_token"] as String?;
        final user = data["user"] as Map<String, dynamic>? ?? {};
        if (token != null) {
          await saveSession(token, user);
        } else {
          currentUser = user;
        }
        return {"success": true, "data": data};
      }
    } on DioException catch (e) {
      final detail = e.response?.data?["detail"]?.toString() ?? "";
      return {
        "success": false,
        "isPending": false,
        "message": detail.isNotEmpty ? detail : "Google Sign-In failed",
      };
    } catch (e) {
      return {"success": false, "isPending": false, "message": e.toString()};
    }
    return {"success": false, "isPending": false, "message": "Google login failed"};
  }

    // 1c. Register Employee
  Future<Map<String, dynamic>> register({
    required String civilId,
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? ministry,
  }) async {
    try {
      final response = await _dio.post(
        "/auth/register",
        data: {
          "civil_id": civilId.trim(),
          "full_name": fullName.trim(),
          "email": email.trim(),
          "password": password.trim(),
          "phone": phone?.trim() ?? "+965 99001122",
          "ministry": ministry?.trim() ?? "Ministry of Finance",
          "role": "employee",
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return {
          "success": true,
          "status": response.data["status"],
          "message": response.data["message"],
          "data": response.data,
        };
      }
    } on DioException catch (e) {
      final detail = e.response?.data?["detail"]?.toString() ?? "Registration failed";
      return {"success": false, "message": detail};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
    return {"success": false, "message": "Registration failed"};
  }

  // 1d. Logout
  Future<void> logout() async {
    await clearSession();
  }

  // 1e. Account Deletion (Apple Guideline 5.1.1 & Google Play Compliance)
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _dio.delete("/users/me");
      if (response.statusCode == 200) {
        await clearSession();
        return {"success": true, "message": "Account successfully deleted"};
      }
    } on DioException catch (e) {
      final detail = e.response?.data?["detail"]?.toString() ?? "Could not delete account";
      return {"success": false, "message": detail};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
    return {"success": false, "message": "Could not delete account"};
  }

  // 1e. Change Password
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        "/auth/change-password",
        data: {
          "old_password": oldPassword.trim(),
          "new_password": newPassword.trim(),
        },
      );
      if (response.statusCode == 200) {
        return {"success": true, "message": "Password changed successfully"};
      }
    } on DioException catch (e) {
      final detail = e.response?.data?["detail"]?.toString() ?? "Failed to change password";
      return {"success": false, "message": detail};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
    return {"success": false, "message": "Failed to change password"};
  }

  // 2. Fetch Offers
  Future<List<OfferModel>> getOffers({String? category, String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category.isNotEmpty && category.toLowerCase() != "all") {
        queryParams["category"] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams["search"] = search;
      }

      final response = await _dio.get("/offers", queryParameters: queryParams);
      if (response.statusCode == 200 && response.data is List) {
        final list = response.data as List;
        return list.map((item) {
          final m = item as Map<String, dynamic>;
          return OfferModel(
            id: m["id"] ?? "",
            brandName: m["brand_name"] ?? "",
            brandLogoEmoji: m["brand_logo_emoji"] ?? "☕",
            brandLogoUrl: m["brand_logo_url"] ?? "",
            bannerImageUrl: m["banner_image_url"] ?? "",
            categoryId: m["category_id"] ?? "",
            categoryName: m["category_name"] ?? "",
            discountTagText: m["discount_tag_text"] ?? "",
            subtitleText: m["subtitle_text"] ?? "",
            expiresText: m["expires_text"] ?? "",
            distanceText: m["distance_text"] ?? "",
            distanceMeters: (m["distance_meters"] as num?)?.toDouble() ?? 350.0,
            locationBranch: m["location_branch"] ?? "",
            latitude: (m["latitude"] as num?)?.toDouble() ?? 29.3759,
            longitude: (m["longitude"] as num?)?.toDouble() ?? 47.9774,
            description: m["description"] ?? "",
            isSaved: m["is_saved"] ?? false,
            defaultDiscount: (m["default_discount"] as num?)?.toDouble() ?? 20.0,
            specialDiscount: (m["special_discount"] as num?)?.toDouble() ?? 0.0,
            specialDiscountTitle: m["special_discount_title"]?.toString(),
            effectiveDiscount: (m["effective_discount"] as num?)?.toDouble() ?? 20.0,
            isSpecialActive: m["is_special_active"] == true,
            allowMultipleDiscounts: m["allow_multiple_discounts"] != false,
          );
        }).toList();
      }
    } catch (_) {
      // Empty if server offline or no offers
    }
    return [];
  }

  // 2b. Upload Civil ID Card Photos
  Future<Map<String, dynamic>> uploadCivilId({
    required String civilId,
    required String frontDataUrl,
    String? backDataUrl,
  }) async {
    try {
      final response = await _dio.post(
        "/auth/upload-civil-id",
        data: {
          "civil_id": civilId.trim(),
          "image_front": frontDataUrl,
          "image_back": backDataUrl,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return {"success": true, "data": response.data};
      }
    } on DioException catch (e) {
      final detail = e.response?.data?["detail"]?.toString() ?? "Failed to upload Worker ID";
      return {"success": false, "message": detail};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
    return {"success": false, "message": "Failed to upload Worker ID"};
  }

  // 2c. Fetch Partner Merchants
  Future<List<Map<String, dynamic>>> getMerchants() async {
    try {
      final response = await _dio.get("/merchants");
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (_) {}
    return [];
  }

  // 3. Generate Dynamic QR Code
  Future<Map<String, dynamic>?> generateDynamicQr(String offerId, {String? branchName}) async {
    try {
      final payload = {
        "offer_id": offerId,
        "branch_name": branchName ?? "The Avenues Mall",
        if (currentUser?["civil_id"] != null) "civil_id": currentUser!["civil_id"],
        if (currentUser?["id"] != null) "user_id": currentUser!["id"],
      };
      final response = await _dio.post(
        "/redemptions/generate-qr",
        data: payload,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
    } catch (_) {
      // Fallback dynamic payload for offline mode
      final fallbackToken = "WFR-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}";
      return {
        "dynamic_token": fallbackToken,
        "seconds_remaining": 60,
        "qr_payload": jsonEncode({
          "token": fallbackToken,
          "offer_id": offerId,
          "exp": DateTime.now().add(const Duration(seconds: 60)).millisecondsSinceEpoch ~/ 1000,
        }),
      };
    }
    return null;
  }

  // 4. Toggle Save Offer
  Future<bool?> toggleSaveOffer(String offerId) async {
    try {
      final response = await _dio.post("/offers/$offerId/save");
      if (response.statusCode == 200 && response.data != null) {
        return response.data["is_saved"] as bool?;
      }
    } catch (_) {
      // Ignore
    }
    return null;
  }

  // 4b. Check Real-Time Redemption Status (for live discount approval)
  Future<Map<String, dynamic>?> checkRedemptionStatus(String token) async {
    try {
      final cleanToken = token.trim();
      final response = await _dio.get("/redemptions/status/$cleanToken");
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (_) {
      // Ignore polling hiccups
    }
    return null;
  }

  // 5. User Savings Stats
  Future<Map<String, dynamic>?> getUserSavingsStats() async {
    try {
      final response = await _dio.get("/users/stats");
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
    } catch (_) {
      // Fallback
    }
    return {"saved_offers_count": 0, "used_deals_count": 0, "total_savings_kd": 0.0};
  }

  // 6. Update Profile Avatar Photo
  Future<Map<String, dynamic>> updateProfilePhoto(String dataUrl) async {
    try {
      final response = await _dio.post(
        "/auth/profile-photo",
        data: {"profile_photo": dataUrl},
      );
      if (response.statusCode == 200 && response.data != null) {
        if (currentUser != null) {
          currentUser!["profile_photo"] = dataUrl;
        }
        return {"success": true, "data": response.data};
      }
    } on DioException catch (e) {
      final detail = e.response?.data?["detail"] ?? e.message ?? "Update failed";
      return {"success": false, "message": detail.toString()};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
    return {"success": false, "message": "Failed to update profile photo"};
  }

  // 6b. Get and Update User Interests
  Future<List<String>> getUserInterests() async {
    try {
      final response = await _dio.get("/users/interests");
      if (response.statusCode == 200 && response.data != null) {
        if (response.data["interests"] is List) {
          return List<String>.from(response.data["interests"]);
        }
      }
    } catch (_) {}
    return [];
  }

  Future<bool> updateUserInterests(List<String> interests) async {
    try {
      final response = await _dio.put("/users/interests", data: {"interests": interests});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 6c. Request Profile Field Updates (Quarantined for Admin Approval)
  Future<Map<String, dynamic>> requestProfileUpdate({
    String? fullName,
    String? email,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null && fullName.isNotEmpty) data["full_name"] = fullName.trim();
      if (email != null && email.isNotEmpty) data["email"] = email.trim();
      if (phone != null && phone.isNotEmpty) data["phone"] = phone.trim();

      final response = await _dio.put("/users/profile", data: data);
      if (response.statusCode == 200 && response.data != null) {
        if (currentUser != null) {
          currentUser!["has_pending_update"] = true;
          currentUser!["pending_profile_update"] = response.data["pending_updates"] ?? data;
        }
        return {"success": true, "data": response.data};
      }
    } on DioException catch (e) {
      final detail = e.response?.data?["detail"] ?? e.message ?? "Profile update request failed";
      return {"success": false, "message": detail.toString()};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
    return {"success": false, "message": "Failed to submit profile update"};
  }

  // 6d. Refresh Current User Profile
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await _dio.get("/users/profile");
      if (response.statusCode == 200 && response.data != null) {
        final profile = Map<String, dynamic>.from(response.data);
        currentUser = profile;
        return profile;
      }
    } catch (_) {}
    return null;
  }

  // 7. Get My Redemption History
  Future<List<Map<String, dynamic>>> getMyRedemptions() async {
    try {
      final response = await _dio.get("/redemptions/my-history");
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (_) {}
    return [];
  }

  // 8. Geolocation Proximity Check
  Future<Map<String, dynamic>?> checkGeolocationProximity(double lat, double lng) async {
    try {
      final response = await _dio.post(
        "/geolocation/check",
        data: {"latitude": lat, "longitude": lng},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (_) {}
    return null;
  }

  // 9. Notifications
  Future<List<Map<String, dynamic>>> getUserNotifications() async {
    try {
      final response = await _dio.get("/notifications");
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (_) {}
    return [];
  }

  Future<int> getUnreadNotificationsCount() async {
    try {
      final response = await _dio.get("/notifications/unread-count");
      if (response.statusCode == 200 && response.data != null) {
        return (response.data["unread_count"] as num?)?.toInt() ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  Future<bool> markNotificationAsRead(int notifId) async {
    try {
      final response = await _dio.post("/notifications/$notifId/read");
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // 10. Daily Picks Based on City Location
  Future<Map<String, dynamic>?> getDailyPicks(String city) async {
    try {
      final encoded = Uri.encodeComponent(city);
      final response = await _dio.get("/notifications/daily-picks?city=$encoded");
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (_) {}
    return null;
  }

  // 11. Broadcast Offer Drop (When shop creates/drops an offer)
  Future<Map<String, dynamic>?> broadcastOfferDrop({
    required String brandName,
    required String discountTag,
    String title = "Exclusive Special Discount",
    String subtitle = "New deal dropped for all Kuwait civil servants",
    String branchName = "Kuwait Branches",
    String city = "Kuwait City",
  }) async {
    try {
      final response = await _dio.post(
        "/offers/broadcast-drop",
        data: {
          "brand_name": brandName,
          "discount_tag": discountTag,
          "title": title,
          "subtitle": subtitle,
          "branch_name": branchName,
          "city": city,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (_) {}
    return null;
  }
  // 12. Send OTP Verification Code
  Future<Map<String, dynamic>> sendOtp(String target, {String channel = "sms"}) async {
    try {
      final response = await _dio.post(
        "/auth/send-otp",
        data: {"target": target.trim(), "channel": channel},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
    } on DioException catch (e) {
      final detail = e.response?.data?["detail"]?.toString() ?? "Failed to send verification code";
      return {"success": false, "message": detail};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
    return {"success": false, "message": "Failed to send code"};
  }

  // 13. Verify OTP Code
  Future<Map<String, dynamic>> verifyOtp(String target, String code) async {
    try {
      final response = await _dio.post(
        "/auth/verify-otp",
        data: {"target": target.trim(), "code": code.trim()},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
    } on DioException catch (e) {
      final detail = e.response?.data?["detail"]?.toString() ?? "Invalid verification code";
      return {"success": false, "message": detail};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
    return {"success": false, "message": "Failed to verify code"};
  }
}