import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  // Emulator Android memakai 10.0.2.2 untuk mengakses localhost laptop.
  // Jika menjalankan di HP fisik, ganti dengan IP laptop:
  // http://192.168.1.5/papua_youth_career_api
  static String get apiBaseUrl {
    if (_configuredApiBaseUrl.isNotEmpty) {
      return _configuredApiBaseUrl;
    }

    if (kIsWeb) {
      return 'http://192.168.13.233/papua_youth_career_api';
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://192.168.13.233/papua_youth_career_api',
      _ => 'http://192.168.13.233/papua_youth_career_api',
    };
  }
}
