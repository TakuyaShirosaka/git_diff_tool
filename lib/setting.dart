import 'package:git_diff_tool/sembastUtility.dart';

class Setting {
  Setting._privateConstructor();

  static final sembastUtility = SembastUtility();
  static final Setting _instance = Setting._privateConstructor();
  SettingData settingData;

  factory Setting() {
    // Databese SetUp
    return _instance;
  }

  Future<SettingData> getSettingData() async {
    print("Setting-getSettingData");
    return await sembastUtility.fetchSettingData();
  }

  Future<void> saveSettingData(SettingData settingData) async {
    print("Setting-saveSettingData");
    await sembastUtility.save(settingData);
  }
}

class SettingData {
  String gitInstallPath = "";
  String sourceClonePath = "";
  String stagingPath ="";
  String branch1 = "";
  String branch2 = "";
  SettingData(
      this.gitInstallPath, this.sourceClonePath, this.stagingPath, this.branch1, this.branch2);
}
