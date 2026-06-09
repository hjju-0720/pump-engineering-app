class Crc16 {
  static int generate(List<int> data, {bool encrypted = false, bool danaI = true}) {
    var crc = 0;
    for (final byte in data) {
      crc = ((crc >> 8) | ((crc << 8) & 0xFFFF)) & 0xFFFF;
      crc ^= byte & 0xFF;
      crc ^= (crc & 0xFF) >> 4;
      crc ^= ((crc << 8) << 4) & 0xFFFF;
      if (encrypted) {
        crc ^= danaI
            ? ((((crc & 0xFF) << 4) | (((crc & 0xFF) >> 3) << 2)) & 0xFFFF)
            : ((((crc & 0xFF) << 5) | (((crc & 0xFF) >> 4) << 2)) & 0xFFFF);
      } else {
        crc ^= ((((crc & 0xFF) << 3) | (((crc & 0xFF) >> 2) << 5)) & 0xFFFF);
      }
    }
    return crc & 0xFFFF;
  }
}
