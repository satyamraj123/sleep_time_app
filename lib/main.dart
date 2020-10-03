import 'package:flutter/material.dart';
import 'package:app_usage/app_usage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<AppUsageInfo> appusage = [];
  DateTime startDate = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0);
  DateTime endDate = DateTime.now();
  Duration totalDuration;

  int minutes = 0;
  bool isloading = false;
  var _isinit = true;
  Future<void> getSleepTime() async {
    try {
      appusage = await AppUsage.getAppUsage(startDate, endDate);
      for (int i = 0; i < appusage.length; i++) {
        minutes = minutes + appusage[i].usage.inMinutes;
      }
      setState(() {});
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }

  @override
  Future<void> didChangeDependencies() async {
    if (_isinit) {
      setState(() {
        isloading = true;
      });
      totalDuration = Duration(
          hours: endDate.hour - startDate.hour,
          minutes: endDate.minute - startDate.minute);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // await initUsage();
        await getSleepTime();
        print("usage-" + appusage[1].usage.inMinutes.toString());
      });

      setState(() {
        isloading = false;
      });
    }

    _isinit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Container(
                    height: 100,
                    width: 300,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        Text(
                          "Sleep Time for today -",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        Text(
                          (totalDuration.inMinutes ~/ 60 - minutes ~/ 60)
                                  .toString() +
                              " hours and " +
                              (totalDuration.inMinutes.remainder(60) -
                                      minutes.remainder(60))
                                  .toString() +
                              " minutes",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      color: Colors.green,
                    ),
                    child: ListTile(
                      title: Text("App Name"),
                      trailing: Text("Use Time in Minutes"),
                    ),
                  ),
                  Expanded(
                    child: Container(
                        child: ListView.separated(
                            padding: EdgeInsets.all(5),
                            itemBuilder: (context, index) {
                              print(appusage[index].appName);
                              return ListTile(
                                title: Text(appusage[index].appName),
                                trailing: Text(
                                    appusage[index].usage.inMinutes.toString() +
                                        " minutes"),
                              );
                            },
                            separatorBuilder: (context, index) => Divider(),
                            itemCount: appusage.length)),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await getSleepTime();
        },
        child: Icon(
          Icons.refresh,
        ),
        mini: true,
      ),
    );
  }
}
