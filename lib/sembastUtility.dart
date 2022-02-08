import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'setting.dart';

class SembastUtility {
  SembastUtility._privateConstructor();

  static final SembastUtility _instance = SembastUtility._privateConstructor();

  String dbPath = 'git_diff_tool.db';
  DatabaseFactory dbFactory = databaseFactoryIo;
  Database db;

  factory SembastUtility() {
    return _instance;
  }

  Future<void> getDatabase() async {
    print("SembastUtility-getDatabase");
    db = await dbFactory.openDatabase(dbPath);
  }

  Future<SettingData> fetchSettingData() async {
    print("SembastUtility-fetchSettingData");
    await getDatabase();

    var store = StoreRef.main();
    String gitInstallPath = await store.record('gitInstallPath').get(db) ??
        "E:/GitForWindows/Git/cmd";
    String sourceClonePath =
        await store.record('sourceClonePath').get(db) ?? "E:/git/";

    String stagingPathPath =
        await store.record('stagingPath').get(db) ?? "/var/www/html/";

    String branch1 = await store.record('branch1').get(db) ?? "master";
    String branch2 = await store.record('branch2').get(db) ?? "staging";

    db.close();
    return new SettingData(
        gitInstallPath, sourceClonePath, stagingPathPath, branch1, branch2);
  }

  Future<void> save(SettingData settingData) async {
    print("SembastUtility-save");
    await getDatabase();
    var store = StoreRef.main();
    await store
        .record('gitInstallPath')
        .put(db, settingData.gitInstallPath, merge: true);
    await store
        .record('sourceClonePath')
        .put(db, settingData.sourceClonePath, merge: true);
    await store
        .record('stagingPath')
        .put(db, settingData.stagingPath, merge: true);
    await store.record('branch1').put(db, settingData.branch1, merge: true);
    await store.record('branch2').put(db, settingData.branch2, merge: true);
    db.close();
  }
}
