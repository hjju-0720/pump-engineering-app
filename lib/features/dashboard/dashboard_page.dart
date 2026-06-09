import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'app_menu.dart';
import '../command/command_page.dart';
import '../event_log/event_log_page.dart';
import '../motor_debug/motor_debug_page.dart';
import '../packet_monitor/packet_monitor_page.dart';
import '../sensor_debug/sensor_debug_page.dart';
import '../test_automation/test_automation_page.dart';
import '../../core/ble/ble_manager.dart';
import '../../core/export/csv_export_service.dart';
import '../../core/mock/mock_pump_device.dart';
import '../../core/protocol/command_builder.dart';
import '../../core/protocol/packet_type.dart';
import '../../core/protocol/pump_packet.dart';
import '../../models/device_status.dart';
import '../../models/event_log.dart';
import '../../models/packet_log.dart';
import 'widgets/command_panel.dart';
import 'widgets/debug_panel.dart';
import 'widgets/device_status_panel.dart';
import 'widgets/event_log_panel.dart';
import 'widgets/packet_monitor_panel.dart';
import 'widgets/side_menu.dart';
import 'widgets/top_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final CommandBuilder _commandBuilder = const CommandBuilder();
  DeviceStatus _deviceStatus = DeviceStatus.mock();
  final List<PacketLog> _packetLogs = [];
  final List<EventLog> _eventLogs = [
    EventLog(timestamp: DateTime.now(), level: 'INFO', message: 'SYSTEM_READY'),
  ];
  final BleManager _bleManager = BleManager();

  StreamSubscription<List<int>>? _rxSubscription;
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  bool _isBleConnected = false;

  final MockPumpDevice _mockPumpDevice = MockPumpDevice();

  StreamSubscription<List<int>>? _mockRxSubscription;
  bool _useMockPump = true;

  final CsvExportService _csvExportService = CsvExportService();

  AppMenu _selectedMenu = AppMenu.dashboard;

  @override
  void initState() {
    super.initState();

    _rxSubscription = _bleManager.rxStream.listen((data) {
      _receivePacket('BLE_RX', data);
      _updateMockStateFromRx(data);
    });

    _mockRxSubscription = _mockPumpDevice.rxStream.listen((data) {
      _receivePacket('MOCK_RX', data);
      _updateMockStateFromRx(data);
    });

    _bleManager.scanResults.listen((results) {
      setState(() {
        _scanResults = results;
      });
    });
  }

  @override
  void dispose() {
    _rxSubscription?.cancel();
    _mockRxSubscription?.cancel();
    _mockPumpDevice.dispose();
    super.dispose();
  }

  Future<void> _connectBle(ScanResult result) async {
    try {
      await _bleManager.connect(result);

      setState(() {
        _isBleConnected = true;
      });

      _eventLogs.insert(
        0,
        EventLog(
          timestamp: DateTime.now(),
          level: 'INFO',
          message: 'BLE_CONNECTED ${result.device.platformName}',
        ),
      );
    } catch (e) {
      setState(() {
        _eventLogs.insert(
          0,
          EventLog(
            timestamp: DateTime.now(),
            level: 'ERROR',
            message: 'BLE_CONNECT_FAILED $e',
          ),
        );
      });
    }
  }

  Future<void> _disconnectBle() async {
    await _bleManager.disconnect();

    setState(() {
      _isBleConnected = false;
      _eventLogs.insert(
        0,
        EventLog(
          timestamp: DateTime.now(),
          level: 'INFO',
          message: 'BLE_DISCONNECTED',
        ),
      );
    });
  }

  Future<void> _writeBlePacket(String label, List<int> data) async {
    _sendPacket(label, data);

    if (_isBleConnected) {
      try {
        await _bleManager.write(data);
      } catch (e) {
        setState(() {
          _eventLogs.insert(
            0,
            EventLog(
              timestamp: DateTime.now(),
              level: 'ERROR',
              message: 'BLE_WRITE_FAILED $e',
            ),
          );
        });
      }

      return;
    }

    if (_useMockPump) {
      await _mockPumpDevice.handleTx(data);
    }
  }

  Future<void> _showScanDialog() async {
    setState(() {
      _isScanning = true;
      _scanResults = [];
    });

    await _bleManager.startScan();

    setState(() {
      _isScanning = false;
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('BLE Scan Results'),
          content: SizedBox(
            width: 520,
            height: 420,
            child: _scanResults.isEmpty
                ? const Center(
              child: Text('No BLE devices found.'),
            )
                : ListView.separated(
              itemCount: _scanResults.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final result = _scanResults[index];
                final name = result.device.platformName.isNotEmpty
                    ? result.device.platformName
                    : 'Unknown Device';

                return ListTile(
                  title: Text(name),
                  subtitle: Text(
                    '${result.device.remoteId}\nRSSI: ${result.rssi} dBm',
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _connectBle(result);
                    },
                    child: const Text('Connect'),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _updateMockStateFromRx(List<int> data) {
    PumpPacket? packet;

    try {
      packet = PumpPacket.parse(data);
    } catch (_) {
      return;
    }

    if (packet.type == PacketType.response && packet.opCode == 0x4A) {
      if (packet.parameters.isNotEmpty && packet.parameters[0] == 0x00) {
        setState(() {
          _deviceStatus = _deviceStatus.copyWith(
            therapyState: 'BOLUS_RUNNING',
          );
        });
      }
    }

    if (packet.type == PacketType.notify && packet.opCode == 0x01) {
      if (packet.parameters.length >= 2) {
        final rawDose = packet.parameters[0] | (packet.parameters[1] << 8);
        final doseU = rawDose / 100.0;

        setState(() {
          _deviceStatus = _deviceStatus.copyWith(
            therapyState: 'IDLE',
            reservoirUnits: (_deviceStatus.reservoirUnits - doseU).clamp(0, 999),
            lastBolusUnits: doseU,
            dailyTotalUnits: _deviceStatus.dailyTotalUnits + doseU,
          );
        });
      }
    }

    if (packet.type == PacketType.notify && packet.opCode == 0x03) {
      setState(() {
        _deviceStatus = _deviceStatus.copyWith(
          therapyState: 'ALARM',
        );
      });
    }
  }

  Future<void> _exportLogs() async {
    try {
      final packetFile =
      await _csvExportService.exportPacketLogs(
        _packetLogs,
      );

      final eventFile =
      await _csvExportService.exportEventLogs(
        _eventLogs,
      );

      setState(() {
        _eventLogs.insert(
          0,
          EventLog(
            timestamp: DateTime.now(),
            level: 'INFO',
            message:
            'EXPORT_COMPLETE\nPacket: $packetFile\nEvent: $eventFile',
          ),
        );
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Export Complete\n$packetFile',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _eventLogs.insert(
          0,
          EventLog(
            timestamp: DateTime.now(),
            level: 'ERROR',
            message: 'EXPORT_FAILED $e',
          ),
        );
      });
    }
  }

  void _clearPacketLogs() {
    setState(() {
      _packetLogs.clear();
      _eventLogs.insert(
        0,
        EventLog(
          timestamp: DateTime.now(),
          level: 'INFO',
          message: 'PACKET_LOG_CLEARED',
        ),
      );
    });
  }

  void _clearEventLogs() {
    setState(() {
      _eventLogs.clear();
      _eventLogs.insert(
        0,
        EventLog(
          timestamp: DateTime.now(),
          level: 'INFO',
          message: 'EVENT_LOG_CLEARED',
        ),
      );
    });
  }

  void _sendPacket(String label, List<int> data) {
    PumpPacket? parsed;
    String? error;

    try {
      parsed = PumpPacket.parse(data);
    } catch (e) {
      error = e.toString();
    }

    setState(() {
      _packetLogs.insert(
        0,
        PacketLog(
          timestamp: DateTime.now(),
          direction: 'TX',
          label: label,
          data: data,
          parsedPacket: parsed,
          parseError: error,
        ),
      );

      _eventLogs.insert(
        0,
        EventLog(
          timestamp: DateTime.now(),
          level: error == null ? 'INFO' : 'ERROR',
          message: error == null ? '$label sent' : '$label packet invalid',
        ),
      );
    });
  }

  void _handleBolus(double doseU) {
    final doseInHundredthsUnit = (doseU * 100).round();

    _sendPacket(
      'BOLUS_${doseU.toStringAsFixed(2)}U',
      _commandBuilder
          .startStepBolus(doseInHundredthsUnit: doseInHundredthsUnit)
          .encode(),
    );
  }

  void _receivePacket(String label, List<int> data) {
    PumpPacket? parsed;
    String? error;

    try {
      parsed = PumpPacket.parse(data);
    } catch (e) {
      error = e.toString();
    }

    setState(() {
      _packetLogs.insert(
        0,
        PacketLog(
          timestamp: DateTime.now(),
          direction: 'RX',
          label: label,
          data: data,
          parsedPacket: parsed,
          parseError: error,
        ),
      );

      _eventLogs.insert(
        0,
        EventLog(
          timestamp: DateTime.now(),
          level: error == null ? 'INFO' : 'ERROR',
          message: error == null ? '$label received' : '$label parse failed',
        ),
      );
    });
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 720),
        child: Column(
          children: [
            TopBar(
              deviceStatus: _deviceStatus,
              onBleScan: _showScanDialog,
              onBleDisconnect: _disconnectBle,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 330,
              child: Row(
                children: [
                  Expanded(child: DeviceStatusPanel(status: _deviceStatus)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommandPanel(
                      onExportLogs: _exportLogs,
                      onGetStatus: () => _writeBlePacket(
                        'GET_STATUS',
                        _commandBuilder.getStatus().encode(),
                      ),
                      onGetDeliveryStatus: () => _writeBlePacket(
                        'GET_DELIVERY_STATUS',
                        _commandBuilder.getDeliveryStatus().encode(),
                      ),
                      onBolus: (doseU) => _writeBlePacket(
                        'BOLUS_${doseU.toStringAsFixed(2)}U',
                        _commandBuilder
                            .startStepBolus(
                          doseInHundredthsUnit: (doseU * 100).round(),
                        )
                            .encode(),
                      ),
                      onStopBolus: () => _writeBlePacket(
                        'STOP_BOLUS',
                        _commandBuilder.stopStepBolus().encode(),
                      ),
                      onMockResponse: () {
                        final packet = const PumpPacket(
                          type: PacketType.response,
                          opCode: 0x4A,
                          parameters: [0x00],
                        ).encode();

                        _receivePacket('RSP_BOLUS_OK', packet);
                      },
                      onMockNotify: () {
                        final packet = const PumpPacket(
                          type: PacketType.notify,
                          opCode: 0x03,
                          parameters: [0x03, 0x00],
                        ).encode();

                        _receivePacket('NTF_OCCLUSION', packet);
                      },
                      onMockOcclusion: _mockPumpDevice.emitOcclusionAlarm,
                      onMockLowBattery: _mockPumpDevice.emitLowBatteryAlarm,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: DebugPanel()),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 360,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PacketMonitorPanel(logs: _packetLogs),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: EventLogPanel(logs: _eventLogs),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonContent({
    required String title,
    required String message,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TopBar(
            deviceStatus: _deviceStatus,
            onBleScan: _showScanDialog,
            onBleDisconnect: _disconnectBle,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Container(
                width: 620,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF101820),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedMenu) {
      case AppMenu.dashboard:
        return _buildDashboardContent();

      case AppMenu.command:
        return CommandPage(
          onGetStatus: () => _writeBlePacket(
            'GET_STATUS',
            _commandBuilder.getStatus().encode(),
          ),
          onGetDeliveryStatus: () => _writeBlePacket(
            'GET_DELIVERY_STATUS',
            _commandBuilder.getDeliveryStatus().encode(),
          ),
          onBolus: (doseU) => _writeBlePacket(
            'BOLUS_${doseU.toStringAsFixed(2)}U',
            _commandBuilder
                .startStepBolus(
              doseInHundredthsUnit: (doseU * 100).round(),
            )
                .encode(),
          ),
          onStopBolus: () => _writeBlePacket(
            'STOP_BOLUS',
            _commandBuilder.stopStepBolus().encode(),
          ),
          onMockOcclusion: _mockPumpDevice.emitOcclusionAlarm,
          onMockLowBattery: _mockPumpDevice.emitLowBatteryAlarm,
          onRawPacketSend: (rawPacket) => _writeBlePacket(
            'RAW_PACKET',
            rawPacket,
          ),
        );

      case AppMenu.packetMonitor:
        return PacketMonitorPage(
          logs: _packetLogs,
          onClearLogs: _clearPacketLogs,
        );

      case AppMenu.eventLog:
        return EventLogPage(
          logs: _eventLogs,
          onClearLogs: _clearEventLogs,
        );

      case AppMenu.motorDebug:
        return const MotorDebugPage();

      case AppMenu.sensorDebug:
        return const SensorDebugPage();

      case AppMenu.testAutomation:
        return const TestAutomationPage();

      default:
        return _buildComingSoonContent(
          title: _selectedMenu.label,
          message: 'This engineering page is not implemented yet.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D13),
      body: SafeArea(
        child: Row(
          children: [
            SideMenu(
              selectedMenu: _selectedMenu,
              onMenuSelected: (menu) {
                setState(() {
                  _selectedMenu = menu;
                });
              },
            ),
            Expanded(
              child: _buildSelectedContent(),
            ),
          ],
        ),
      ),
    );
  }
}
