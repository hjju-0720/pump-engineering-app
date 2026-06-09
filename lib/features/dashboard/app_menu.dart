enum AppMenu {
  dashboard('Dashboard'),
  command('Command'),
  packetMonitor('Packet Monitor'),
  eventLog('Event Log'),
  motorDebug('Motor Debug'),
  sensorDebug('Sensor Debug'),
  otaUpdate('OTA / Update'),
  security('Security'),
  testAutomation('Test Automation'),
  tools('Tools');

  final String label;

  const AppMenu(this.label);
}