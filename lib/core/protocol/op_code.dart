class OpCode {
  // Review / status
  static const int initialScreenInformation = 0x02;
  static const int deliveryStatus = 0x03;

  // Review / history / information
  static const int getShippingInformation = 0x20;
  static const int getPumpCheck = 0x21;
  static const int getUserTimeChangeFlag = 0x22;
  static const int clearUserTimeChangeFlag = 0x23;
  static const int getMoreInformation = 0x24;
  static const int setHistoryUploadMode = 0x25;
  static const int getTodayDeliveryTotal = 0x26;

  // Bolus
  static const int setStepBolusStop = 0x44;
  static const int setStepBolusStart = 0x4A;

  // Basal
  static const int setTemporaryBasal = 0x60;
  static const int cancelTemporaryBasal = 0x62;
  static const int getBasalRate = 0x67;
  static const int setSuspendOn = 0x69;
  static const int setSuspendOff = 0x6A;
}