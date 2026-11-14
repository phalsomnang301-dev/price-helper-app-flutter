import 'package:flutter/foundation.dart';

class BaseURL {
  // ប្រើពេល Run: flutter run --dart-define=API_URL=http://192.168.1.5:8000
  // មិនដាក់ → ប្រើតម្លៃលំនាំដើមខាងក្រោម (Emulator)
  static const String _override = String.fromEnvironment('Url');


  static String get base {
    if (_override.isNotEmpty) return _override;

    // Web (Chrome, Edge, etc.)
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    // Mobile / Desktop
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000'; // Android Emulator
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://127.0.0.1:8000';
      default:
        return 'http://127.0.0.1:8000';
    }
  }
}





// import 'package:flutter/foundation.dart';

// class BaseURL {
//   // ដាក់លេខ IPv4 របស់កុំព្យូទ័រអ្នកនៅទីនេះ (ឆែកមើលតាម ipconfig)
//   static const String _computerIp = '172.20.10.2'; 

//   static String get base {
//     // Web (Chrome, Edge, etc.)
//     if (kIsWeb) {
//       return 'http://127.0.0.1:8000';
//     }

//     // Mobile / Desktop
//     switch (defaultTargetPlatform) {
//       case TargetPlatform.android:
//         // ប្រើ IP របស់កុំព្យូទ័រសម្រាប់ទូរស័ព្ទពិត (Real Device)
//         return 'http://$_computerIp:8000'; 
//       case TargetPlatform.iOS:
//       case TargetPlatform.macOS:
//       case TargetPlatform.windows:
//       case TargetPlatform.linux:
//         return 'http://127.0.0.1:8000';
//       default:
//         return 'http://127.0.0.1:8000';
//     }
//   }
// }
