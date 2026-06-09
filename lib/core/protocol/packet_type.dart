enum PacketType {
  command(0xA1),
  response(0xB2),
  notify(0xC3),
  encryptionRequest(0x01),
  encryptionResponse(0x02);

  final int value;

  const PacketType(this.value);

  static PacketType? fromValue(int value) {
    for (final type in PacketType.values) {
      if (type.value == value) return type;
    }
    return null;
  }

  String get label {
    switch (this) {
      case PacketType.command:
        return 'CMD';
      case PacketType.response:
        return 'RSP';
      case PacketType.notify:
        return 'NTF';
      case PacketType.encryptionRequest:
        return 'ENC_REQ';
      case PacketType.encryptionResponse:
        return 'ENC_RSP';
    }
  }
}