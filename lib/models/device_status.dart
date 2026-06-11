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

  final String modelName;
  final int? protocolVersion;
  final int? productCode;

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
    required this.modelName,
    required this.protocolVersion,
    required this.productCode,
  });

  factory DeviceStatus.mock() {
    return const DeviceStatus(
      connectionState: 'Disconnected',
      deviceName: '-',
      firmwareVersion: '-',
      batteryPercent: 0,
      reservoirUnits: 0.0,
      rssi: 0,
      therapyState: 'UNKNOWN',
      lastBolusUnits: 0.0,
      dailyTotalUnits: 0.0,
      modelName: '-',
      protocolVersion: null,
      productCode: null,
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
    String? modelName,
    int? protocolVersion,
    int? productCode,
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
      modelName: modelName ?? this.modelName,
      protocolVersion: protocolVersion ?? this.protocolVersion,
      productCode: productCode ?? this.productCode,
    );
  }
}