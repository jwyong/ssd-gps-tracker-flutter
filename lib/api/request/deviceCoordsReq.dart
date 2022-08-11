// To parse this JSON data, do
//
//     final test2Req = test2ReqFromJson(jsonString);

import 'dart:convert';

//DeviceCoordsReq test2ReqFromJson(String str) {
//  final jsonData = json.decode(str);
//  return DeviceCoordsReq.fromJson(jsonData);
//}

String deviceCoordsJSON(DeviceCoordsReq data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class DeviceCoordsReq {
  List<String> deviceIds;

  DeviceCoordsReq({
    this.deviceIds,
  });

  factory DeviceCoordsReq.fromJson(Map<String, dynamic> json) => new DeviceCoordsReq(
        deviceIds: json["device_ids"] == null
            ? null
            : new List<String>.from(json["device_ids"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "device_ids": deviceIds == null
            ? null
            : new List<dynamic>.from(deviceIds.map((x) => x)),
      };
}
