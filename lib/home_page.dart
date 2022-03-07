import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hs_mobil/service.dart';
import 'package:hs_mobil/utils.dart';

import 'enums.dart';
import 'models/Status.dart';
import 'models/Temp.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AccessStatus accessStatus = AccessStatus.loading;
  Status? status;

  Timer? tempTimer;
  AccessStatus tempStatus = AccessStatus.loading;
  Temp? temp;

  @override
  void initState() {
    super.initState();
    updateStatus();
  }

  void updateStatus() {
    log("getting status...");
    getStatus().then((value) {
      setState(() {
        dynamic json = jsonDecode(value.body);
        log("got status: $json");
        accessStatus = AccessStatus.accessed;
        status = Status.fromJson(json);
      });
    }).onError((error, stackTrace) {
      log("status error: $error");
      setState(() {
        accessStatus = AccessStatus.failed;
        status = null;
      });
    });
  }

  void clearScreen() {
    accessStatus = AccessStatus.loading;
    status = null;
    tempTimer?.cancel();
    tempTimer = null;
    tempStatus = AccessStatus.loading;
    temp = null;
  }

  void updateTemp() {
    log("getting temp...");
    getTemp().then((value) {
      setState(() {
        log(value.body);
        // Map<String, dynamic> map =
        //     Map<String, dynamic>.from(jsonDecode(value.body));

        temp = Temp.fromJson(jsonDecode(value.body));

        // log("got tempp: $json");
        tempStatus = AccessStatus.accessed;
      });
    }).onError((error, stackTrace) {
      setState(() {
        log("temp error: $error");
        tempStatus = AccessStatus.failed;
      });
    });
  }

  Widget _buildLabelledCard(
      LabelledCardTheme theme, String label, Widget content) {
    Color? cardColor;
    Color? labelColor;

    if (theme == LabelledCardTheme.defaultt) {
      cardColor = null;
      labelColor = Colors.grey.shade700;
    } else if (theme == LabelledCardTheme.error) {
      cardColor = Colors.red[400];
      labelColor = Colors.red.shade900;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: cardColor,
        elevation: 5,
        child: Container(
          constraints: const BoxConstraints(minHeight: 50),
          child: Stack(children: [
            Positioned(
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                decoration: BoxDecoration(
                    color: labelColor,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8))),
                child: Text(
                  label,
                ),
              ),
            ),
            content
          ]),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String label, String error,
      {double? fontSize = 14, double? height = 80, double textTopPadding = 5}) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: SizedBox(
          height: height,
          child: _buildLabelledCard(
              LabelledCardTheme.error,
              label,
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: textTopPadding),
                  child: Text(
                    error,
                    style: TextStyle(
                        color: Colors.grey[850],
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )),
        ));
  }

  Widget _buildAccessedStatusCard() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: _buildLabelledCard(
            LabelledCardTheme.defaultt,
            "Status",
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(children: [
                Center(
                  child: Text(
                    "commit hash: ${status!.commitHash.substring(0, 7)}",
                  ),
                ),
                Center(
                  child: Text("start time: ${status!.startTime}"),
                )
              ]),
            )));
  }

  Widget _buildTempCard() {
    const String cardLabel = "Temperature";
    if (tempStatus == AccessStatus.loading) {
      return _buildLabelledCard(
        LabelledCardTheme.defaultt,
        cardLabel,
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: SizedBox(
              child: CircularProgressIndicator(),
              height: 30.0,
              width: 30.0,
            ),
          ),
        ),
      );
    } else if (accessStatus == AccessStatus.accessed && temp != null) {
      return _buildLabelledCard(
          LabelledCardTheme.defaultt,
          cardLabel,
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Center(
                child: Column(children: [
              Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(flex: 1),
                  1: IntrinsicColumnWidth(flex: 1)
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(children: [
                    Container(
                        alignment: Alignment.centerRight,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text("CPU fan:"),
                        )),
                    Text(temp?.fan2 != null
                        ? "${temp!.fan2.toString()} RPM"
                        : "?")
                  ]),
                  TableRow(children: [
                    Container(
                        alignment: Alignment.centerRight,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text("CPUTIN:"),
                        )),
                    Text(formatDegree(temp!.cputin))
                  ]),
                  TableRow(children: [
                    Container(
                        alignment: Alignment.centerRight,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text("SYSTIN:"),
                        )),
                    Text(formatDegree(temp!.systin))
                  ]),
                ],
              ),
              Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(flex: 2),
                  1: IntrinsicColumnWidth(flex: 1)
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  ...temp!.disks.keys
                      .map((e) => TableRow(children: [
                            Container(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text("$e:"),
                              ),
                            ),
                            Text(formatDegree(temp!.disks[e])),
                          ]))
                      .toList()
                ],
              ),
            ])),
          ));
    } else {
      return _buildErrorCard(cardLabel, "Cannot get system temperature");
    }
  }

  Widget _buildHomeScreenCards() {
    if (accessStatus == AccessStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (accessStatus == AccessStatus.accessed && status != null) {
      tempTimer ??=
          Timer.periodic(const Duration(seconds: 2), (Timer t) => updateTemp());
      return Column(children: [_buildAccessedStatusCard(), _buildTempCard()]);
    } else {
      return _buildErrorCard("Status", "Cannot reach server.",
          fontSize: 20, height: 80, textTopPadding: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Homeserver mobile client")),
        body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                clearScreen();
                updateStatus();
              });
            },
            child: ListView(children: [_buildHomeScreenCards()])));
  }
}
