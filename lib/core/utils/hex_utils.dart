class HexUtils {
  static String toHex(List<int> data) {
    return data.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
  }
}
