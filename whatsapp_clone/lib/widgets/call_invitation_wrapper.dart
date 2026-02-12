import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../utils/navigator_key.dart';

class CallInvitationWrapper extends StatefulWidget {
  final Widget child;
  final String userId;
  final String userName;

  const CallInvitationWrapper({
    super.key,
    required this.child,
    required this.userId,
    required this.userName,
  });

  @override
  State<CallInvitationWrapper> createState() => _CallInvitationWrapperState();
}

class _CallInvitationWrapperState extends State<CallInvitationWrapper> {
  @override
  void initState() {
    super.initState();
    _initService();
  }

  @override
  void didUpdateWidget(covariant CallInvitationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != oldWidget.userId ||
        widget.userName != oldWidget.userName) {
      ZegoUIKitPrebuiltCallInvitationService().uninit();
      _initService();
    }
  }

  void _initService() {
    // NOTE: In a real app, do NOT store credentials here. Fetch from backend.
    const int appID = 1276704067; // Your App ID
    const String appSign =
        "cffb5f1bd0878715f7499ab592196d46f4bfe0cf90ba81e726006d7595915b1c"; // Your App Sign

    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: appID,
      appSign: appSign,
      userID: widget.userId,
      userName: widget.userName,
      plugins: [ZegoUIKitSignalingPlugin()],
    );
  }

  @override
  void dispose() {
    ZegoUIKitPrebuiltCallInvitationService().uninit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
