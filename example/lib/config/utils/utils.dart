import 'package:example/config/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:provider/provider.dart';

import 'device_helper.dart';

void setFontFamilyCall(BuildContext context, FunctionCall functionCall) {
  var fontFamily = functionCall.args['fontFamily']! as String;

  if (context.mounted) {
    context.read<AppState>().setFontFamily(fontFamily);
  }

  return;
}

void setFontSizeFactorCall(BuildContext context, FunctionCall functionCall) {
  var fontSizeFactor = functionCall.args['fontSizeFactor']! as num;

  if (context.mounted) {
    context.read<AppState>().setFontSizeFactor(fontSizeFactor.toDouble());
  }

  return;
}

void consolidatedBalanceToolCall(
  BuildContext context,
  FunctionCall functionCall,
) async {
  return;
}

void setAppColorCall(BuildContext context, FunctionCall functionCall) async {
  int red = functionCall.args['red']! as int;
  int green = functionCall.args['green']! as int;
  int blue = functionCall.args['blue']! as int;

  Color newSeedColor = Color.fromRGBO(red, green, blue, 1);

  if (context.mounted) {
    context.read<AppState>().setAppColor(newSeedColor);
  }
}

Future<String> getDeviceInfoCall() async {
  var deviceInfo = await DeviceHelper.getDeviceInfo();
  return 'Device Info: ${deviceInfo.toString()}';
}

Future<String> getBatteryInfoCall() async {
  var batteryInfo = await DeviceHelper.getBatteryInfo();
  return 'Battery Info: ${batteryInfo.toString()}';
}
