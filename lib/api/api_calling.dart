// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class DeviceAPIManager {
//   static const String baseUrl = 'https://www.screenbros.in/employeeapi/';
//
//   static Future<Map<String, dynamic>> searchDevices(String query) async {
//     final response = await http.post(
//       Uri.parse(baseUrl + 'search_device.php'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'search': query}),
//     );
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to search devices');
//     }
//   }
//
//   static Future<Map<String, dynamic>> getCode(String endpoint, String identifier, bool isOldDevice) async {
//     final response = await http.post(
//       Uri.parse(baseUrl + endpoint),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(
//           isOldDevice ? {'phone': identifier} : {'imei': identifier}),
//     );
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to load code');
//     }
//   }
//
//   static Future<Map<String, dynamic>> getLUCode(String identifier, bool isOldDevice, String apptype, String action) async {
//     String endpoint = '';
//
//     // Determine endpoint based on conditions
//     if (apptype == 'u') {
//       if (action == 'lock') {
//         endpoint = 'lock_code.php';
//       } else if (action == 'unlock') {
//         endpoint = 'unlock_code.php';
//       }
//     } else if (apptype == 'c') {
//       if (action == 'lock') {
//         endpoint = 'code';
//       } else if (action == 'unlock') {
//         endpoint = 'unlock_code';
//       }
//     }
//
//     Map<String, String> body = {
//       'code': identifier,
//     };
//
//     final response = await http.post(
//       Uri.parse(baseUrl + endpoint),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(body),
//     );
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to load Lock/Unlock code');
//     }
//   }
// }
