      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       TextBuilder(
      //         text: "DashBoard",
      //         color: Colors.black,
      //         fontWeight: FontWeight.bold,
      //       ),
      //       IconButton(
      //         onPressed: () async {
      //           SharedPreferences prefs = await SharedPreferences.getInstance();
      //           await prefs.clear();
      //           Navigator.pop(context);
      //           Navigator.pushAndRemoveUntil(
      //             context,
      //             MaterialPageRoute(builder: (_) => LoginScreen()),
      //                 (route) => false,
      //           );
      //         },
      //         icon: Icon(
      //           Icons.power_settings_new,
      //           color: Colors.red,
      //           size: 28,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      // body: Padding(
      //   padding: EdgeInsets.all(8.0),
      //   child: Column(
      //     children: [
      //       Container(
      //         decoration: BoxDecoration(
      //           color: Colors.white,
      //           borderRadius: BorderRadius.circular(30.0),
      //           boxShadow: [
      //             BoxShadow(
      //               color: Colors.grey.withOpacity(0.5),
      //               spreadRadius: 2,
      //               blurRadius: 5,
      //               offset: Offset(0, 3), // changes position of shadow
      //             ),
      //           ],
      //         ),
      //         child: TextField(
      //           decoration: InputDecoration(
      //             hintText: 'Search by IMEI or Phone Number...',
      //             prefixIcon: Icon(Icons.search),
      //             suffixIcon: IconButton(
      //               icon: Icon(Icons.clear),
      //               onPressed: () {
      //                 setState(() {
      //                   screen = !screen;
      //                 });
      //                 _searchController.clear();
      //                 _searchItems('');
      //               },
      //             ),
      //             border: InputBorder.none,
      //             contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      //           ),
      //           controller: _searchController,
      //           onChanged: _searchItems,
      //         ),
      //       ),