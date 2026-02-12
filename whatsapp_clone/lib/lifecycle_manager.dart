import 'dart:async';
import 'package:flutter/material.dart';
import 'services/user_service.dart';

class LifecycleManager extends StatefulWidget {
  final Widget child;

  const LifecycleManager({super.key, required this.child});

  @override
  State<LifecycleManager> createState() => _LifecycleManagerState();
}

class _LifecycleManagerState extends State<LifecycleManager>
    with WidgetsBindingObserver {
  final UserService _userService = UserService();
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Set online when app starts
    _userService.updateUserPresence(true);
    _startHeartbeat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopHeartbeat();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _userService.updateUserPresence(true);
      _startHeartbeat();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _userService.updateUserPresence(false);
      _stopHeartbeat();
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat(); // Ensure no existing timer
    _userService.updateLastActive(); // Initial beat
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _userService.updateLastActive();
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
