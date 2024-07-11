import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenbroz2/Screens/Login_Screen.dart';
import 'package:screenbroz2/Widgets/TextBuilder.dart';
import 'dart:convert';
import 'package:screenbroz2/api/api_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Device> oldDevices = [];
  List<Device> newDevices = [];
  bool isFirstVisit = true;
  bool isLoading = false;
  String baseUrl = 'https://www.screenbros.in/employeeapi/';

  Future<void> _searchItems(String query) async {
    setState(() {
      isLoading = true;
    });
    setState(() {
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

    final response = await http.post(
      Uri.parse('${baseUrl}search_device.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'search': query}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        oldDevices = data['old'] != null
            ? (data['old'] as List)
            .map((item) => Device.fromJson(item))
            .toList()
            : [];
        newDevices = data['new'] != null
            ? (data['new'] as List)
            .map((item) => Device.fromJson(item))
            .toList()
            : [];
        isLoading = false;
      });
      print(data);
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }
  Future<void> _getCode(String endpoint, String identifier, int index, bool isOldDevice) async {
    final response = await http.post(
      Uri.parse(baseUrl + endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          isOldDevice ? {'phone': identifier} : {'imei': identifier}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        print(data);
        setState(() {
          if (isOldDevice) {
            if (endpoint.contains('Uninstall')) {
              oldDevices[index].olduninstallcode = data["uninstallcode"];
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 1),
                    backgroundColor: Colors.blueAccent,
                      content: TextBuilder(text: "Old device unistall code Generated",color: Colors.white,fontWeight: FontWeight.bold,)));
            } else {
              oldDevices[index].oldunlockcode = data["unlockcode"];
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      duration: Duration(seconds: 1),
                      backgroundColor: Colors.blueAccent,
                      content: TextBuilder(text: "Old device unLock code Generated",color: Colors.white,fontWeight: FontWeight.bold,)));
            }
          } else {
            if (endpoint.contains('Uninstall')) {
              newDevices[index].uninstallcode = data["uninstallcode"];
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    duration: Duration(seconds: 1),
                    backgroundColor: Colors.blueAccent,
                    content: TextBuilder(text: "New device unistall code Generated",color: Colors.white,fontWeight: FontWeight.bold,)),
              );
            } else {
              newDevices[index].unlockcode = data["unlockcode"];
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      duration: Duration(seconds: 1),
                      backgroundColor: Colors.blueAccent,
                      content: TextBuilder(text: "New device unLock code Generated",color: Colors.white,fontWeight: FontWeight.bold,))
              );
            }
          }
        });
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Code retrieved successfully')),
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load code')),
        );
      }
    } else {
      throw Exception('Failed to connect to server');
    }
  }
  Future<void> _getLUcode(String identifier, int index, bool isOldDevice, String apptype, String action,) async {
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
      print(data);
      String status = data['status'] ?? 'failed'; // Initialize 'status'
      if (status == 'success') {
        setState(() {
          if (isOldDevice) {
            if (endpoint.contains('oldDeviceNotification')) {
              print("old scan");
            }
          } else {
            if (endpoint.contains('newdeviceNotification')) {
          print("new scan");
          }
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
            endpoint.contains('newdeviceNotification')
                ? SnackBar(
              backgroundColor: Colors.blueAccent,
              duration: Duration(seconds: 1),
                content: TextBuilder(text : action == "UNLOCK"
                    ? "New Device Unlock"
                    : "New Device Lock",fontWeight: FontWeight.bold,color: Colors.white,))
                : SnackBar(
                duration: Duration(seconds: 1),
                backgroundColor: Colors.blueAccent,
                content: TextBuilder(text:action == "UNLOCK"
                    ? "Old Device Unlock"
                    : "Old  Device Lock",fontWeight: FontWeight.bold,color: Colors.white,)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            endpoint.contains('newdeviceNotification')
                ? SnackBar(
                duration: Duration(seconds: 1),
                backgroundColor: Colors.blueAccent,
                content: Text(action == "UNLOCK"
                    ? "New Device Unlock failed"
                    : "New Device Lock failed"))
                : SnackBar(
                duration: Duration(seconds: 1),
                backgroundColor: Colors.blueAccent,
                content: Text(action == "UNLOCK"
                    ? "Old Device Unlock failed"
                    : "Old  Device Lock failed")));
      }
    } else {
      throw Exception('Failed to connect to server');
    }
  }


  void showActionDialog(BuildContext context, int index, bool isOldDevice, String identifier1, String identifire2,apptype,) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Action',
            style: TextStyle(
                color: Colors.black, fontSize: 19, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 11),
                        ),
                        child: Text('Lock',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () { _getLUcode(
                          // _getEndpoint(isOldDevice, apptype, "UNLOCK"),
                          isOldDevice ? identifier1 :identifire2,
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 11),
                        ),
                        child: Text('Unlock',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 11),
                        ),
                        child: Text('Uninstall Code',
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 11),
                        ),
                        child: Text('Unlock Code',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
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
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildDeviceList(List<Device> devices, bool isOldDevice) {
    if (devices.isEmpty) {
      return Center(
        child: Text(
          'No devices found. Search your devices.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return InkWell(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          Device device = devices[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            child: Card(
              elevation: 4,
              color: Colors.white,
              child: InkWell(
                onTap: () => showActionDialog(
                    context, index, isOldDevice, device.mobile, device.imei,device.appType),
                child: ListTile(
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name ➯ ${device.name}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 17),
                      ),
                      Text(
                        "Number: ${device.mobile}",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      Text(
                        "IMEI: ${device.imei}",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            "Uninstall Code: ",
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isOldDevice
                                ? device.olduninstallcode.toString()
                                : device.uninstallcode.toString(),
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Unlock Code: ",
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isOldDevice
                                ? device.oldunlockcode.toString()
                                : device.unlockcode.toString(),
                            style: TextStyle(
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
                        device.appType
                    ),
                    icon: Icon(Icons.more_vert),
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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextBuilder(
                text: "DashBoard",
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              IconButton(
                onPressed: () async {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  await prefs.clear();
                  Get.offAll(()=>LoginScreen(),transition: Transition.leftToRight);
                },
                icon: Icon(
                  Icons.power_settings_new,
                  color: Colors.red,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(12.0),
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
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by IMEI or Phone Number...',
                    hintStyle: TextStyle(fontWeight: FontWeight.w600,color: Colors.black),
                    prefixIcon: Icon(Icons.search,color: Colors.black,),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear,color: Colors.black,),
                      onPressed: () {
                        setState(() {});
                        isLoading = true;
                        _searchController.clear();
                        _searchItems('');
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  controller: _searchController,
                  onChanged: _searchItems,
                ),
              ),
              isFirstVisit ? Container(child: Padding(
                padding: const EdgeInsets.only(top: 250),
                child: TextBuilder(text: "Serch devices here.....",fontWeight: FontWeight.bold,fontSize: 18,textAlign: TextAlign.center,),
              )): Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                  child: Column(
                    children: [
                      if (oldDevices.isNotEmpty)
                        Column(
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 12, top: 8),
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
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 12, top: 8),
                              child: Text(
                                'New Devices',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            _buildDeviceList(newDevices, false),
                          ],
                        ),if (newDevices.isEmpty && oldDevices.isEmpty)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 12, top: 200),
                              child: TextBuilder(text: "No Devices Found",fontWeight: FontWeight.w600,)
                            ),
                          ],
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
