// import 'package:firebase_remote_config/firebase_remote_config.dart';
//
// class RemoteConfigService {
//   static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
//
//   static Future<void> init() async {
//     await _remoteConfig.setConfigSettings(
//       RemoteConfigSettings(
//         fetchTimeout: const Duration(seconds: 10),
//         minimumFetchInterval: const Duration(seconds: 0),
//       ),
//     );
//
//     await _remoteConfig.fetchAndActivate();
//   }
//
//   static String get whatsappAccessToken => _remoteConfig.getString('whatsapp_access_token');
//
//   static bool get isAppEnabled => _remoteConfig.getBool('app_enabled');
// }

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../helper/extensions/getx_controller_extensions.dart';

class RemoteConfigService {
  static final FirebaseFirestore _firestoreInstance = read<FirebaseFirestore>();
  static bool _appEnabled = true;
  static String _whatsappAccessToken = '';

  static bool get isAppEnabled => _appEnabled;

  static String get whatsappAccessToken => _whatsappAccessToken;

  static Future<void> init() async {
    try {
      final snapshot = await _firestoreInstance.collection('config').doc('app').get();

      if (snapshot.exists) {
        final data = snapshot.data();
        _appEnabled = data?['app_enabled'] ?? true;
        _whatsappAccessToken = data?['whatsapp_access_token'] ?? '';
      }
    } catch (e) {
      // fallback to defaults
      _appEnabled = true;
      _whatsappAccessToken = '';
    }
  }
}
