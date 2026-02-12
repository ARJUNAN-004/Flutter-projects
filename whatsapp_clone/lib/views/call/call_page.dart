import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatelessWidget {
  final String callId;
  final String userId;
  final String userName;
  final bool isVideoCall;

  const CallPage({
    super.key,
    required this.callId,
    required this.userId,
    required this.userName,
    this.isVideoCall = true,
  });

  @override
  Widget build(BuildContext context) {
    // NOTE: In a real app, do NOT store credentials here. Fetch from backend.
    // Get these from ZegoCloud Console: https://console.zegocloud.com/
    const int appID = 1276704067; // Replace with your App ID
    const String appSign = "cffb5f1bd0878715f7499ab592196d46f4bfe0cf90ba81e726006d7595915b1c"; // Replace with your App Sign

    return ZegoUIKitPrebuiltCall(
      appID: appID,
      appSign: appSign,
      userID: userId,
      userName: userName,
      callID: callId,
      config: isVideoCall
          ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
    );
  }
}
