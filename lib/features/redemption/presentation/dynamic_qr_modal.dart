import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DynamicQrModal extends StatefulWidget {
  final String userId;
  final String offerId;
  final String brandName;

  const DynamicQrModal({
    super.key,
    required this.userId,
    required this.offerId,
    required this.brandName,
  });

  @override
  State<DynamicQrModal> createState() => _DynamicQrModalState();
}

class _DynamicQrModalState extends State<DynamicQrModal> {
  late Timer _timer;
  int _secondsRemaining = 300; // 5 Minutes Timer
  late String _qrToken;

  @override
  void initState() {
    super.initState();
    _generateToken();
    _startCountdown();
  }

  void _generateToken() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    _qrToken = "WAFRA_${widget.userId}_${widget.offerId}_$timestamp";
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "كود الخصم - ${widget.brandName}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Show this QR code to the cashier at the partner branch.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),

          _secondsRemaining > 0
              ? QrImageView(
                  data: _qrToken,
                  version: QrVersions.auto,
                  size: 200.0,
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1E3A8A),
                  ),
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF1E3A8A),
                  ),
                )
              : const Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 60),
                    SizedBox(height: 8),
                    Text(
                      "انتهت صلاحية الكود!",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: Colors.amber, size: 18),
                const SizedBox(width: 6),
                Text(
                  "ينتهي خلال: $_formattedTime",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("إغلاق", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
