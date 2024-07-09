class Device {
  String name;
  String mobile;
  String imei;
  int olduninstallcode;
  int oldunlockcode;
  int uninstallcode;
  int unlockcode;
  String appType;

  Device({
    required this.name,
    required this.mobile,
    required this.imei,
    required this.olduninstallcode,
    required this.oldunlockcode,
    required this.uninstallcode,
    required this.unlockcode,
    required this.appType,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      name: json['name'],
      mobile: json['phone'] ?? '',
      imei: json['imei'] ?? '',
      olduninstallcode: json['olduninstallcode'] ?? 0,
      oldunlockcode: json['oldunlockcode'] ?? 0,
      uninstallcode: json['uninstallcode'] ?? 0,
      unlockcode: json['unlockcode'] ?? 0,
      appType: json['apptype'] ?? '',
    );
  }
}