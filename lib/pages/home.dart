import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:git_diff_tool/setting.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class HomePageWidget extends StatefulWidget {
  HomePageWidget({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

enum RadioValue { LOCAL, STAGING, PLANE }

class _HomePageWidgetState extends State<HomePageWidget> {
  Future<SettingData> _future;
  TextEditingController gitPathController;
  TextEditingController clonePathController;
  TextEditingController stagingPathController;
  TextEditingController branch1Controller;
  TextEditingController branch2Controller;

  RadioValue _gValue = RadioValue.STAGING;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> dataCloums = ["Path", "Status"];
  List<Map<String, String>> dataRows = [];

  @override
  void initState() {
    super.initState();
    _future = asyncSettingData();
  }

  Future<SettingData> asyncSettingData() async {
    SettingData settingData = await new Setting().getSettingData();
    setState(() {
      gitPathController =
          TextEditingController(text: settingData.gitInstallPath);
      clonePathController =
          TextEditingController(text: settingData.sourceClonePath);
      stagingPathController =
          TextEditingController(text: settingData.stagingPath);
      branch1Controller = TextEditingController(text: settingData.branch1);
      branch2Controller = TextEditingController(text: settingData.branch2);
    });
    return settingData;
  }

  void _onRadioSelected(value) {
    setState(() {
      _gValue = value;
    });
  }

  void startGitDiffProcess() async {
    setState(() {
      dataRows = [];
    });

    // git diff での日本語の文字化け対応も行う
    ProcessResult result = await Process.run(
        "cd",
        [
          gitPathController.text,
          "&",
          "git",
          "config",
          "--global",
          "core.pager",
          "'LESSCHARSET=utf-8 less'",
          "&",
          "git",
          "config",
          "--global",
          "core.quotepath",
          "false",
          "&",
          "git",
          "-C",
          clonePathController.text,
          "diff",
          branch1Controller.text,
          branch2Controller.text,
          "--name-status"
        ],
        runInShell: true,
        stdoutEncoding: Encoding.getByName("utf-8"));

    print("exitCode:" + (result.exitCode).toString());
    print(result.stdout);

    if (result.exitCode != 0) {
      showTopSnackBar(
        context,
        CustomSnackBar.error(
          message: "Git Diffに失敗しました。\n Gitのインストールパス・比較ブランチの指定等を見直してください。",
        ),
      );
      throw Exception("Git Diff実行失敗");
    }

    List<String> planeRowDatas = (result.stdout)
        .toString()
        .split("\n")
        .where((f) => f.isNotEmpty)
        .toList();

    List<Map<String, String>> newRows = planeRowDatas
        .map((row) => (() {
              var planeRow = row.split("\t").toList();
              return {
                "path": planeRow.last,
                "status": (() {
                  switch (planeRow.first) {
                    case "A":
                      return "追加";
                    case "D":
                      return "削除";
                    case "M":
                      return "変更";
                    case "R100":
                      return "Rename";
                    default:
                      return (planeRow).toString();
                  }
                })()
              };
            })())
        .toList();

    setState(() {
      dataRows = newRows;
    });

    /** git configを戻す **/
    Process.run(
        "cd",
        [
          gitPathController.text,
          "&",
          "git",
          "config",
          "--global",
          "--unset",
          "core.pager",
          "&",
          "git",
          "config",
          "--global",
          "--unset",
          "core.quotepath",
        ],
        runInShell: true);
  }

  String getFilePath() {
    switch (_gValue) {
      case RadioValue.LOCAL:
        if (clonePathController.text.endsWith("/"))
          return clonePathController.text;
        return clonePathController.text + "/";
      case RadioValue.STAGING:
        if (stagingPathController.text.endsWith("/"))
          return stagingPathController.text;
        return stagingPathController.text + "/";
      case RadioValue.PLANE:
        return "";
      default:
        return "";
    }
  }

  String editFilePath(String path) {
    return getFilePath() + path;
  }

  String _makeTextRow(List<Map<String, String>> dataRows) {
    String res = "";
    switch (_gValue) {
      case RadioValue.LOCAL:
      case RadioValue.STAGING:
        dataRows.forEach((row) {
          res +=
              getFilePath() + row["path"] + '\t' + '\t' + row["status"] + '\n';
        });
        break;
      case RadioValue.PLANE:
        dataRows.forEach((row) {
          res += getFilePath() + row["path"] + '\n';
        });
        break;
      default:
        break;
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                  future: _future,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    Widget childWidget;
                    if (snapshot.connectionState == ConnectionState.done) {
                      childWidget = Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            TextFormField(
                              controller: gitPathController,
                              decoration: InputDecoration(
                                labelText: 'Git Install Path',
                                hintText: 'Git Install Path',
                              ),
                            ),
                            TextFormField(
                              controller: clonePathController,
                              decoration: InputDecoration(
                                labelText: 'Source Clone Path',
                                hintText: 'C:/git',
                              ),
                            ),
                            TextFormField(
                              controller: stagingPathController,
                              decoration: InputDecoration(
                                labelText: 'Staging Path',
                                hintText: '/var/www/html/',
                              ),
                            ),
                            Row(
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    width: 300.0,
                                    child: TextFormField(
                                      controller: branch1Controller,
                                      decoration: InputDecoration(
                                        labelText: 'Branch - 1',
                                        hintText: 'master',
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Container(width: 50.0),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    width: 300.0,
                                    child: TextFormField(
                                      controller: branch2Controller,
                                      decoration: InputDecoration(
                                        labelText: 'Branch - 2',
                                        hintText: 'staging',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.fromLTRB(0, 20, 0, 5),
                                child: SizedBox(
                                  width: 150,
                                  height: 35,
                                  child: ElevatedButton(
                                    onPressed: () => (() async {
                                      SettingData saveSettingData =
                                          new SettingData(
                                        gitPathController.text,
                                        clonePathController.text,
                                        stagingPathController.text,
                                        branch1Controller.text,
                                        branch2Controller.text,
                                      );

                                      await Setting()
                                          .saveSettingData(saveSettingData);

                                      showTopSnackBar(
                                        context,
                                        CustomSnackBar.success(
                                          message: "設定を保存しました。",
                                        ),
                                      );
                                    })(),
                                    child: Text('Save Settings',
                                        style: TextStyle(color: Colors.black)),
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.grey),
                                  ),
                                )),
                          ],
                        ),
                      );
                    } else {
                      childWidget = const CircularProgressIndicator();
                    }
                    return childWidget;
                  }),
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: SizedBox(
                    width: 150,
                    height: 35,
                    child: ElevatedButton(
                      onPressed: () => startGitDiffProcess(),
                      child:
                          Text('EXEC', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(primary: Colors.blue),
                    ),
                  )),
              Divider(
                color: Color(0xFFE0E0E0),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(child: Text("Result ${dataRows.length} files")),
                    Flexible(
                      child: RadioListTile<RadioValue>(
                        title: const Text('Local Path'),
                        value: RadioValue.LOCAL,
                        groupValue: _gValue,
                        onChanged: (RadioValue value) {
                          _onRadioSelected(value);
                        },
                      ),
                    ),
                    Flexible(
                      child: Text('/'),
                    ),
                    Flexible(
                      child: RadioListTile<RadioValue>(
                        title: const Text('Staging Path'),
                        value: RadioValue.STAGING,
                        groupValue: _gValue,
                        onChanged: (RadioValue value) {
                          _onRadioSelected(value);
                        },
                      ),
                    ),
                    Flexible(
                      child: Text('/'),
                    ),
                    Flexible(
                      child: RadioListTile<RadioValue>(
                        title: const Text('Plane'),
                        value: RadioValue.PLANE,
                        groupValue: _gValue,
                        onChanged: (RadioValue value) {
                          _onRadioSelected(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    String res = _makeTextRow(dataRows);
                    await Clipboard.setData(ClipboardData(text: res));
                    print(res);
                    showTopSnackBar(
                      context,
                      CustomSnackBar.success(
                        message: "クリップボードにコピーしました。",
                      ),
                    );
                  },
                  child: Text("Copy")),
              DataTable(
                  columns: dataCloums
                      .map((colum) => DataColumn(label: Text(colum)))
                      .toList(),
                  rows: dataRows
                      .map((row) => DataRow(cells: [
                            DataCell(Text(editFilePath(row["path"]))),
                            DataCell(Text(row["status"])),
                          ]))
                      .toList()),
            ],
          ),
        )));
  }
}
