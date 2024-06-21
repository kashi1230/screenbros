// // api_functions.dart
//
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:screenbroz2/api/api_mode.dart';
//
// class ApiFunctions {
//   static Future<void> getUninstallCode(String imei, int index) async {
//     String baseUrl = 'https://www.screenbros.in/employeeapi/';
//     try {
//       final response = await http.post(
//         Uri.parse(baseUrl + 'generateimeiUninstallCode.php'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'imei': imei}),
//       );
//
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         if (data['status'] == 'success') {
//           return data['uninstallcode'];
//         } else {
//           throw Exception('Failed to generate uninstall code');
//         }
//       } else {
//         throw Exception('Failed to connect to server');
//       }
//     } catch (e) {
//       throw Exception('Failed to get uninstall code: $e');
//     }
//   }
//
//   static Future<void> getUnlockCode(String imei, int index) async {
//     String baseUrl = 'https://www.screenbros.in/employeeapi/';
//     try {
//       final response = await http.post(
//         Uri.parse(baseUrl + 'generateimeiUnlockCode.php'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'imei': imei}),
//       );
//
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         if (data['status'] == 'success') {
//
//         } else {
//           throw Exception('Failed to generate unlock code');
//         }
//       } else {
//         throw Exception('Failed to connect to server');
//       }
//     } catch (e) {
//       throw Exception('Failed to get unlock code: $e');
//     }
//   }
//
//   static Future<void> searchItems(String query, Function(List<Device>, List<Device>) onDataLoaded) async {
//     String baseUrl = 'https://www.screenbros.in/employeeapi/';
//     try {
//       final response = await http.post(
//         Uri.parse(baseUrl + 'search_device.php'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'search': query}),
//       );
//
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         List<Device> oldDevices = [];
//         List<Device> newDevices = [];
//         if (data['old'] != null) {
//           oldDevices = (data['old'] as List).map((item) => Device.fromJson(item)).toList();
//         }
//         if (data['new'] != null) {
//           newDevices = (data['new'] as List).map((item) => Device.fromJson(item)).toList();
//         }
//         onDataLoaded(oldDevices, newDevices);
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       throw Exception('Failed to search items: $e');
//     }
//   }
// }
