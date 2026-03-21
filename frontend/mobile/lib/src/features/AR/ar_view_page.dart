import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketroom/src/core/firebase_providers.dart';
import 'package:pocketroom/src/features/cart/presentation/providers/cart_provider.dart';

class ArViewPage extends ConsumerStatefulWidget {
  const ArViewPage({super.key});

  @override
  ConsumerState<ArViewPage> createState() => _ArViewPageState();
}

class _ArViewPageState extends ConsumerState<ArViewPage>
    with WidgetsBindingObserver {
  static const MethodChannel _unityArChannel = MethodChannel(
    'com.example.pocketroom/unity_ar',
  );

  bool _isLaunching = true;
  String? _errorMessage;
  bool _didBackgroundAfterLaunch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _launchNativeAr();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_errorMessage != null) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _didBackgroundAfterLaunch = true;
      return;
    }

    if (state == AppLifecycleState.resumed && _didBackgroundAfterLaunch) {
      _didBackgroundAfterLaunch = false;
      if (!mounted) return;
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _launchNativeAr() async {
    try {
      final cartItems = ref.read(cartProvider);
      final currentUser = ref.read(firebaseAuthProvider).currentUser;
      final cartPayload = cartItems.isEmpty
          ? null
          : jsonEncode({
              'uid': currentUser?.uid ?? '',
              'cart': cartItems
                  .map(
                    (item) => {
                      'id': item.furniture.id,
                      'quantity': item.quantity,
                      'furniture': item.furniture.toJson(),
                    },
                  )
                  .toList(),
            });

      await _unityArChannel.invokeMethod<void>('launchNativeAr', {
        if (cartPayload != null) 'cartPayload': cartPayload,
      });
      if (!mounted) return;
      setState(() {
        _isLaunching = false;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLaunching = false;
        _errorMessage = error.message ?? error.code;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLaunching = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View in AR')),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _errorMessage != null
                ? Text(_errorMessage!)
                : Text(_isLaunching ? 'Starting native AR...' : 'AR opened'),
          ),
        ),
      ),
    );
  }
}
