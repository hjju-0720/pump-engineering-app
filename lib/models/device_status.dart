class DeviceStatus {
  final String connectionState;
  final String deviceName;
  final String firmwareVersion;
  final int batteryPercent;
  final double reservoirUnits;
  final int rssi;
  final String therapyState;
  final double lastBolusUnits;
  final double dailyTotalUnits;

  const DeviceStatus({
    required this.connectionState,
    required this.deviceName,
    required this.firmwareVersion,
    required this.batteryPercent,
    required this.reservoirUnits,
    required this.rssi,
    required this.therapyState,
    required this.lastBolusUnits,
    required this.dailyTotalUnits,
  });

  factory DeviceStatus.mock() {
    return const DeviceStatus(
      connectionState: 'Mock Connected',
      deviceName: 'MockPump_1234',
      firmwareVersion: '1.0.5',
      batteryPercent: 85,
      reservoirUnits: 120.3,
      rssi: -48,
      therapyState: 'IDLE',
      lastBolusUnits: 0.0,
      dailyTotalUnits: 0.0,
    );
  }

  DeviceStatus copyWith({
    String? connectionState,
    String? deviceName,
    String? firmwareVersion,
    int? batteryPercent,
    double? reservoirUnits,
    int? rssi,
    String? therapyState,
    double? lastBolusUnits,
    double? dailyTotalUnits,
  }) {
    return DeviceStatus(
      connectionState: connectionState ?? this.connectionState,
      deviceName: deviceName ?? this.deviceName,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      reservoirUnits: reservoirUnits ?? this.reservoirUnits,
      rssi: rssi ?? this.rssi,
      therapyState: therapyState ?? this.therapyState,
      lastBolusUnits: lastBolusUnits ?? this.lastBolusUnits,
      dailyTotalUnits: dailyTotalUnits ?? this.dailyTotalUnits,
    );
  }
}