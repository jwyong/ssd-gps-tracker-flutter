class DeviceCoords {
  String deviceId;
  String deviceName;
  String imei;
  String datetime;
  String latitude;
  String longitude;
  int speed;
  int course;
  dynamic mnc;
  dynamic cellId;
  dynamic status;

  DeviceCoords({
    this.deviceId,
    this.deviceName,
    this.imei,
    this.datetime,
    this.latitude,
    this.longitude,
    this.speed,
    this.course,
    this.mnc,
    this.cellId,
    this.status,
  });

  factory DeviceCoords.fromJson(Map<String, dynamic> json) => new DeviceCoords(
        deviceId: json["device_id"] == null ? null : json["device_id"],
        deviceName: json["device_name"] == null ? null : json["device_name"],
        imei: json["imei"] == null ? null : json["imei"],
        datetime: json["datetime"] == null ? null : json["datetime"],
        latitude: json["latitude"] == null ? null : json["latitude"],
        longitude: json["longitude"] == null ? null : json["longitude"],
        speed: json["speed"] == null ? null : json["speed"],
        course: json["course"] == null ? null : json["course"],
        mnc: json["mnc"],
        cellId: json["cell_id"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "device_id": deviceId == null ? null : deviceId,
        "device_name": deviceName == null ? null : deviceName,
        "imei": imei == null ? null : imei,
        "datetime": datetime == null ? null : datetime,
        "latitude": latitude == null ? null : latitude,
        "longitude": longitude == null ? null : longitude,
        "speed": speed == null ? null : speed,
        "course": course == null ? null : course,
        "mnc": mnc,
        "cell_id": cellId,
        "status": status,
      };

  @override
  String toString() {
    return 'Test2{deviceId: $deviceId, deviceName: $deviceName, imei: $imei, '
        'datetime: $datetime, latitude: $latitude, longitude: $longitude, '
        'speed: $speed, course: $course, mnc: $mnc, cellId: $cellId, status: $status}';
  }
}
