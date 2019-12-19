class AppData {
  static final AppData _appData = new AppData._internal();

  String name = "JF";
  String phone = "600000001";

  factory AppData() {
    return _appData;
  }  AppData._internal();
}

final appData = AppData();