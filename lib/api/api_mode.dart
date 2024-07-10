class Device {
  final String imei;
  final String name;
  final String mobile;
  int unlockcode;
  int uninstallcode;
  int oldunlockcode;
  int olduninstallcode;
  final String appType;

  Device({
    required this.imei,
    required this.name,
    required this.mobile,
    required this.unlockcode,
    required this.uninstallcode,
    required this.oldunlockcode,
    required this.olduninstallcode,
    required this.appType,

  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      imei: json['imei'],
      name: json['name'],
      mobile: json['mobile'],
      appType: json['apptype'],
      unlockcode: 0,
      uninstallcode: 0,
      oldunlockcode: 0,
      olduninstallcode: 0,
    );
  }
}
