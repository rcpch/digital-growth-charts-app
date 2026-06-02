import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

String? hashedId;

Future<String?> getHashedDeviceId() async {
  if (hashedId != null) {
    return hashedId;
  }

  final deviceInfo = DeviceInfoPlugin();

  String rawId;

  if (kIsWeb) {
    final deviceId = await FlutterSecureStorage().read(key: 'web_device_id');
    if (deviceId == null) {
      rawId = const Uuid().v4();
      await FlutterSecureStorage().write(key: 'web_device_id', value: rawId);
    } else {
      rawId = deviceId;
    }
  } else if (Platform.isAndroid) {
    final info = await deviceInfo.androidInfo;
    rawId = info.id;
  } else if (Platform.isIOS) {
    final info = await deviceInfo.iosInfo;
    rawId = info.identifierForVendor ?? 'unknown';
  } else {
    return null;
  }

  hashedId = sha256.convert(utf8.encode(rawId)).toString();
  return hashedId;
}
