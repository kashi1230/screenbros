import 'package:flutter/material.dart';
import 'package:screenbroz2/Screens/Login_Screen.dart';
import 'package:screenbroz2/Widgets/TextBuilder.dart';
import 'dart:convert';
import 'package:screenbroz2/api/api_calling.dart';
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
  bool isLoading = false;
  bool screen = false;
  String baseUrl = 'https://www.screenbros.in/employeeapi/';
  String code = '';

  Future<void> _searchItems(String query) async {
    setState(() {
      isLoading = true; // Set loading state to true when fetching data
    });

    if (query.isEmpty) {
      setState(() {
        oldDevices = [];
        newDevices = [];
      });
      setState(() {
        isLoading = false; // Set loading state to false when no search query
      });

      return;
    }

    final response = await http.post(
      Uri.parse('https://www.screenbros.in/employeeapi/search_device.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'search': query}),
    );
    print('API Response Status Code: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        oldDevices = data['old'] != null
            ? (data['old'] as List).map((item) => Device.fromJson(item)).toList()
            : [];
        newDevices = data['new'] != null
            ? (data['new'] as List).map((item) => Device.fromJson(item)).toList()
            : [];
      });
    } else {
      print('Failed to load data');
      throw Exception('Failed to load data');
    }

    setState(() {
      isLoading = false; // Set loading state to false after data is fetched
    });
    print('Old Devices: $oldDevices');
    print('New Devices: $newDevices');
  }
  Future<void> getUninstallCode(String  imei,index) async {
    final response = await http.post(
      Uri.parse(baseUrl + 'generateimeiUninstallCode.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'imei': imei}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
       setState(() {
         newDevices[index].uninstallcode = data["uninstallcode"];
       });
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to Load Unlock Code")),
        );
      }
    } else {
      throw Exception('Failed to connect to server');
    }
  }
  Future<void> getUnlockCode(String  imei,index) async {
    final response = await http.post(
      Uri.parse(baseUrl + 'generateimeiUnlockCode.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'imei': imei}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          newDevices[index].unlockcode = data["unlockcode"];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to Load Unlock Code")),
        );
      }
    } else {
      throw Exception('Failed to connect to server');
    }
  }
  Future<void> getUnlockCodeOld(String  phn,index) async {
    final response = await http.post(
      Uri.parse(baseUrl + 'generateUnlockCode.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'phone': phn}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          newDevices[index].unlockcode = data["unlockcode"];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to Load Unlock Code")),
        );
      }
    } else {
      throw Exception('Failed to connect to server');
    }
  }
  Future<void> getUninstallCodeOld(String  phn,index) async {
    final response = await http.post(
      Uri.parse(baseUrl + 'generateimeiUninstallCode.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'phone': phn}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          oldDevices[index].olduninstallcode = data["uninstallcode"];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to Load old Unistall Code")),
        );
      }
    } else {
      throw Exception('Failed to connect to server');
    }
  }

  void callApi(index,imei,phone){
    if (newDevices.isEmpty ||oldDevices.isEmpty) {
      getUninstallCode(imei, index);
      print("new");
    } else if (index < newDevices.length + oldDevices.length) {
      int oldIndex = index - newDevices.length;
      getUninstallCodeOld(phone, index);
      print("new");
    }
    Navigator.of(context).pop(); // Close the dialog
  }

  void _showActionDialog(BuildContext context, int index, String imei,String phone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return  AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  'Action',
                  style: TextStyle(color: Colors.black, fontSize: 19, fontWeight: FontWeight.bold),
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
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                              ),
                              child: Text('        Lock        ', style: TextStyle(fontSize: 14, color: Colors.white,fontWeight: FontWeight.bold)),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                              ),
                              child: Text('      Unlock    ', style: TextStyle(fontSize: 14, color: Colors.white,fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {

                                if (index < newDevices.length) {
                                  getUninstallCode(imei, index);
                                } else if (index < newDevices.length + oldDevices.length) {
                                  int oldIndex = index - newDevices.length;
                                  getUninstallCodeOld(phone, oldIndex);
                                }
                                Navigator.of(context).pop();
                                print("New :${newDevices[index].uninstallcode}");
                                print(oldDevices[index].olduninstallcode);// Close the dialog
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                              ),
                              child: Text('Uninstall Code', style: TextStyle(fontSize: 13, color: Colors.white,fontWeight: FontWeight.bold)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                getUnlockCode(imei,index);
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                              ),
                              child: Text('Unlock Code', style: TextStyle(fontSize: 13, color: Colors.white,fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                              ),
                              child: Text('       Claim       ', style: TextStyle(fontSize: 14, color: Colors.white,fontWeight: FontWeight.bold)),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                              ),
                              child: Text('   Declaim     ', style: TextStyle(fontSize: 14, color: Colors.white,fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,)
                      ],
                    ),
                  ),
                ),
              );
            }
    );
  }

  Widget _buildList(List<Device> devices, bool isOldDevice) {
    if (devices.isEmpty) {
      return Center(
        child: Text(
          'No devices found. Search your devices.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          child: Card(
            elevation: 4,
            color: Colors.white,
            child: ListTile(
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name ➯ ${devices[index].name}",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 17),
                  ),
                  Text(
                    " Number : ${devices[index].mobile}",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    " IMEI : ${devices[index].imei}",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        " Uninstall Code : ",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Text(
                          index < newDevices.length?devices[index].uninstallcode.toString():devices[index].olduninstallcode.toString(),
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        " Unlock Code : ",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        devices[index].unlockcode.toString(),
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  _showActionDialog(context, index, devices[index].imei.trim(),devices[index].mobile.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Action', style: TextStyle(fontSize: 14, color: Colors.white)),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                );
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
        padding: EdgeInsets.all(8.0),
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
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        screen = !screen;
                      });
                      _searchController.clear();
                      _searchItems('');
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                ),
                controller: _searchController,
                onChanged: _searchItems,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    children: [
                      if (oldDevices.isNotEmpty) ...[
                        TextBuilder(
                          text: "Old Devices",
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        _buildList(oldDevices, true),
                      ],
                      if (newDevices.isNotEmpty) ...[
                        SizedBox(height: 20),
                        TextBuilder(
                          text: "New Devices",
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        _buildList(newDevices, false),
                      ],
                      if (!isLoading && oldDevices.isEmpty && newDevices.isEmpty)
                        Center(
                          child: TextBuilder(color: Colors.black,text: "Search Devices here...",fontWeight: FontWeight.bold,fontSize: 18,)
                        ),
                    ],
                  ),
                  if (isLoading)
                    Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
