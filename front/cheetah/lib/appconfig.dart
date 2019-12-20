class AppData {
  static final AppData _appData = new AppData._internal();

  // String name = "Homer";
  // String phone = "600000002";
  // String name = "Lisa";
  // String phone = "600000003";
  String name = "JF";
  String phone = "600000001";

  factory AppData() {
    return _appData;
  }  AppData._internal();
}

final appData = AppData();