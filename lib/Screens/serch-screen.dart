import 'package:flutter/material.dart';
import 'package:screenbroz2/Screens/Login_Screen.dart';
import 'package:screenbroz2/Widgets/TextBuilder.dart';
import 'package:screenbroz2/api/api_calling.dart';
import 'dart:convert';
import 'package:screenbroz2/api/api_mode.dart';
import 'package:screenbroz2/search-const/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Future<void> _searchItems(String query) async {
    setState(() {
      isLoading = true;
      isFirstVisit = false;
    });

    if (query.isEmpty) {
      setState(() {
        oldDevices = [];
        newDevices = [];
        isLoading = false;
      });
      return;
    }

    try {
      final response = await DeviceAPIManager.searchDevices(query);

      setState(() {
        oldDevices = response['old'] != null
            ? (response['old'] as List)
            .map((item) => Device.fromJson(item))
            .toList()
            : [];
        newDevices = response['new'] != null
            ? (response['new'] as List)
            .map((item) => Device.fromJson(item))
            .toList()
            : [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to load data')),
      // );
    }
  }

  Future<void> _getCode(
      String endpoint, String identifier, int index, bool isOldDevice) async {
    final response = await http.post(
      Uri.parse(baseUrl + endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          isOldDevice ? {'phone': identifier} : {'imei': identifier}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          if (isOldDevice) {
            if (endpoint.contains('Uninstall')) {
              oldDevices[index].olduninstallcode = data["uninstallcode"];
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Old Unistall')));
            } else {
              oldDevices[index].oldunlockcode = data["unlockcode"];
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Old Unlock')));
            }
          } else {
            if (endpoint.contains('Uninstall')) {
              newDevices[index].uninstallcode = data["uninstallcode"];
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New Unistall')),
              );
            } else {
              newDevices[index].unlockcode = data["unlockcode"];
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New Unlock')),
              );
            }
          }
        });
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Code retrieved successfully')),
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load code')),
        );
      }
    } else {
      throw Exception('Failed to connect to server');
    }
  }

  Future<void> _getLUcode(
    String identifier,
    int index,
    bool isOldDevice,
    String apptype,
    String action,
  ) async {
    String endpoint;
    Map<String, String> body;

    if (isOldDevice && apptype == 'SCAN') {
      endpoint = 'oldDeviceNotification.php';
      body = {'phone': identifier, 'action': action};
    } else if (!isOldDevice && apptype == 'SCAN') {
      endpoint = 'newdeviceNotification.php';
      body = {'imei': identifier, 'action': action};
    } else if (apptype == 'ZT') {
      endpoint = action == 'LOCK' ? 'testlock.php' : 'testunlock.php';
      body = {'imei': identifier};
    } else {
      throw Exception('Invalid device type or app type');
    }

    final response = await http.post(
      Uri.parse(baseUrl + endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String status = data['status'] ?? 'failure'; // Initialize 'status'
      if (status == 'success') {
        setState(() {
          if (isOldDevice) {
            if (endpoint.contains('oldDeviceNotification')) {}
          } else {
            if (endpoint.contains('newDeviceNotification')) {}
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
            endpoint.contains('newDeviceNotification')
                ? SnackBar(
                    content: Text(action == "UNLOCK"
                        ? "New Device Unlock"
                        : "New Device Lock"))
                : SnackBar(
                    content: Text(action == "UNLOCK"
                        ? "Old Device Unlock"
                        : "Old  Device Lock")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load Lock/Unlock code')),
        );
      }
    } else {
      throw Exception('Failed to connect to server');
    }
  }

  void showActionDialog(
    BuildContext context,
    int index,
    bool isOldDevice,
    String identifier1,
    String identifire2,
    apptype,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Action',
            style: TextStyle(
                color: Colors.black, fontSize: 19, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _getLUcode(
                            // _getEndpoint(isOldDevice, apptype, "LOCK"),
                            isOldDevice ? identifier1 : identifire2,
                            index,
                            isOldDevice,
                            apptype,
                            "LOCK",
                          );
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 11),
                        ),
                        child: const Text('Lock',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _getLUcode(
                            // _getEndpoint(isOldDevice, apptype, "UNLOCK"),
                            isOldDevice ? identifier1 : identifire2,
                            index,
                            isOldDevice,
                            apptype,
                            "UNLOCK",
                          );
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 11),
                        ),
                        child: const Text('Unlock',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _getCode(
                              isOldDevice
                                  ? 'generateUninstallCode.php'
                                  : 'generateimeiUninstallCode.php',
                              isOldDevice ? identifier1 : identifire2,
                              index,
                              isOldDevice);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 11),
                        ),
                        child: const Text('Uninstall Code',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _getCode(
                              isOldDevice
                                  ? 'generateUnlockCode.php'
                                  : 'generateimeiUnlockCode.php',
                              isOldDevice ? identifier1 : identifire2,
                              index,
                              isOldDevice);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 11),
                        ),
                        child: const Text('Unlock Code',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ElevatedButton(
                      //   onPressed: () {},
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.blueAccent,
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     padding:
                      //         EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                      //   ),
                      //   child: Text('Claim',
                      //       style: TextStyle(
                      //           fontSize: 14,
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.bold)),
                      // ),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     Navigator.of(context).pop();
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.green,
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     padding:
                      //         EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                      //   ),
                      //   child: Text('Declaim',
                      //       style: TextStyle(
                      //           fontSize: 14,
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.bold)),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceList(List<Device> devices, bool isOldDevice) {
    return InkWell(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          Device device = devices[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            child: Card(
              elevation: 4,
              color: Colors.white,
              child: InkWell(
                onTap: () => showActionDialog(context, index, isOldDevice,
                    device.mobile, device.imei, device.appType),
                child: ListTile(
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name ➯ ${device.name}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 17),
                      ),
                      Text(
                        "Number: ${device.mobile}",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      Text(
                        "IMEI: ${device.imei}",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            "Uninstall Code: ",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isOldDevice
                                ? device.olduninstallcode.toString()
                                : device.uninstallcode.toString(),
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            "Unlock Code: ",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isOldDevice
                                ? device.oldunlockcode.toString()
                                : device.unlockcode.toString(),
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => showActionDialog(
                        context,
                        index,
                        isOldDevice,
                        isOldDevice ? device.mobile : '',
                        isOldDevice ? '' : device.imei,
                        device.appType),
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TextBuilder(
                text: "DashBoard",
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              IconButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.clear();
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(
                  Icons.power_settings_new,
                  color: Colors.red,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by IMEI or Phone Number...',
                    prefixIcon: const Icon(Icons.search),
                    // errorText: _isValid ? null : 'Please enter a valid 10-digit number',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          oldDevices.clear();
                          newDevices.clear();
                          isLoading = false;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 20.0),
                  ),
                  controller: _searchController,
                  onChanged: (val) {
                    _searchItems(val);
                  },
                ),
              ),
              isFirstVisit
                  ? const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                          child: TextBuilder(
                        text: "Serach items  here...",
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                    )
                  : Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  Visibility(
                                    visible: oldDevices.isEmpty &&
                                        newDevices.isEmpty &&
                                        !isLoading,
                                    child: const Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: TextBuilder(
                                        text:
                                            "No devices found for the searched no.",
                                        fontWeight: FontWeight.w600,fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (oldDevices.isNotEmpty)
                                    Column(
                                      children: [
                                        const Padding(
                                          padding:
                                              EdgeInsets.only(left: 12, top: 8),
                                          child: Text(
                                            'Old Devices',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        _buildDeviceList(oldDevices, true),
                                      ],
                                    ),
                                  if (newDevices.isNotEmpty)
                                    Column(
                                      children: [
                                        const Padding(
                                          padding:
                                              EdgeInsets.only(left: 12, top: 8),
                                          child: Text(
                                            'New Devices',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        _buildDeviceList(newDevices, false),
                                      ],
                                    ),
                                  Visibility(
                                    visible: isFirstVisit,
                                    child: const TextBuilder(
                                      text:
                                          "Please search for a IMEI or phone for the devices by clicking the icon at the top right corner of the screen",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
            ],
          ),
        ));
  }
}
