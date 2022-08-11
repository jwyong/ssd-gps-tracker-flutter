class Account {
  final String account_id;
  final String account_name;
  final List<DeviceGrps> device_groups;

  Account({
    this.account_id,
    this.account_name,
    this.device_groups,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    var list = json['device_groups'] as List;
    List<DeviceGrps> deviceGrpsList = list.map((i) => DeviceGrps.fromJson(i)).toList();

    return Account(
      account_id: json["account_id"],
      account_name: json["account_name"],
      device_groups: deviceGrpsList,
    );
  }
}

class DeviceGrps {
  final String device_group_id;
  final String device_group_name;
  final List<Devices> devices;

  DeviceGrps({
    this.device_group_id,
    this.device_group_name,
    this.devices,
  });

  factory DeviceGrps.fromJson(Map<String, dynamic> json) {
    var list = json['devices'] as List;
    List<Devices> devicesList = list.map((i) => Devices.fromJson(i)).toList();

    return DeviceGrps(
      device_group_id: json["device_group_id"],
      device_group_name: json["device_group_name"],
      devices: devicesList,
    );
  }
}

class Devices {
  final String device_id;
  final String device_name;
  final String imei;
  final String model;
  final String sim_number;
  final String activated_date;
  final String expiration_date_p;
  final String expiration_date_u;
  final bool status;
  final String group;

  Devices({
    this.device_id,
    this.device_name,
    this.imei,
    this.model,
    this.sim_number,
    this.activated_date,
    this.expiration_date_p,
    this.expiration_date_u,
    this.status,
    this.group,
  });

  factory Devices.fromJson(Map<String, dynamic> json) {
    return Devices(
      device_id: json["device_id"],
      device_name: json["device_name"],
      imei: json["imei"],
      model: json["model"],
      sim_number: json["sim_number"],
      activated_date: json["activated_date"],
      expiration_date_p: json["expiration_date_p"],
      expiration_date_u: json["expiration_date_u"],
      status: json["status"],
      group: json["group"],
    );
  }
}
