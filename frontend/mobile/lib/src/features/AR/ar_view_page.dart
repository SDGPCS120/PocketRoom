import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_2/flutter_unity_widget_2.dart';

class ArViewPage extends StatefulWidget {
  const ArViewPage({super.key});

  @override
  State<ArViewPage> createState() => _ArViewPageState();
}

class _ArViewPageState extends State<ArViewPage> {
  UnityWidgetController? _unityController;
  Map<String, dynamic>? _cartPayload;
  String? _errorMessage;
  bool _isLoadingCart = true;
  bool _didSendInitialCart = false;
  bool _isSendingCart = false;

  @override
  void initState() {
    super.initState();
    _loadCartForUnity();
  }

  @override
  void dispose() {
    _unityController?.dispose();
    super.dispose();
  }

  Future<void> _loadCartForUnity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      setState(() {
        _isLoadingCart = false;
        _errorMessage = 'Log in with a non-anonymous account to view your cart in AR.';
      });
      return;
    }

    try {
      final cartSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('cart')
              .get();
      final items = cartSnapshot.docs.map((doc) {
        final data = _toJsonSafeMap(doc.data());
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      _cartPayload = {
        'uid': user.uid,
        'email': user.email,
        'cart': items,
      };

      if (!mounted) return;
      setState(() {
        _isLoadingCart = false;
        _errorMessage = null;
      });

      await _sendCartToUnityIfReady();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingCart = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _sendCartToUnityIfReady() async {
    final controller = _unityController;
    final payload = _cartPayload;
    if (_didSendInitialCart || _isSendingCart || controller == null || payload == null) {
      return;
    }

    _isSendingCart = true;
    final payloadJson = jsonEncode(payload);

    try {
      // Unity can report created before the target scene objects are ready, so retry a few times.
      for (var attempt = 0; attempt < 5; attempt++) {
        await controller.postMessage(
          'FlutterCartBridge',
          'ReceiveCartPayload',
          payloadJson,
        );
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
      _didSendInitialCart = true;
    } finally {
      _isSendingCart = false;
    }
  }

  Map<String, dynamic> _toJsonSafeMap(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, _toJsonSafeValue(value)));
  }

  dynamic _toJsonSafeValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }
    if (value is Map<String, dynamic>) {
      return _toJsonSafeMap(value);
    }
    if (value is List) {
      return value.map(_toJsonSafeValue).toList();
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View in AR')),
      body: Stack(
        children: [
          UnityWidget(
            onUnityCreated: (controller) {
              _unityController = controller;
              _sendCartToUnityIfReady();
            },
          ),
          if (_isLoadingCart)
            const Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Expanded(child: Text('Loading your cart for AR...')),
                    ],
                  ),
                ),
              ),
            ),
          if (!_isLoadingCart && _errorMessage != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_errorMessage!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
