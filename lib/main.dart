// Uncomment the following lines when enabling Firebase Crashlytics
// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'firebase_options.dart';
import 'packages/baby_names/main.dart' as baby_names;
import 'packages/chat_app/main.dart' as chat_app;
import 'packages/chat_app/services/auth_service.dart';
import 'packages/counter/main.dart' as counter;
import 'packages/friendlychat/main.dart' as friendlychat;
import 'packages/game/crashlytics/crashlytics.dart';
import 'packages/game/main.dart' as game;
import 'packages/layout_basic/main.dart' as layout_basic;
import 'packages/shrine/app.dart' as shrine;
import 'packages/startup_namer/main.dart' as startup_namer;
import 'packages/sunflower/main.dart' as sunflower;

Future<List<Demo>> fetchDemo() async {
  final jsonData = await rootBundle.loadString('assets/data/demo.json');
  final list = json.decode(jsonData) as List<dynamic>;
  return list.map((e) => Demo.fromJson(e)).toList();
}

class Demo {
  // data Type
  final int id;
  final String name;
  final String route;

  // constructor
  const Demo({required this.id, required this.name, required this.route});

  factory Demo.fromJson(Map<String, dynamic> json) {
    return Demo(id: json['id'], name: json['name'], route: json['route']);
  }
}

class DemoListItem extends StatelessWidget {
  final Demo demo;
  final _biggerFont = const TextStyle(fontSize: 18);

  DemoListItem({
    required this.demo,
  }) : super(key: ObjectKey(demo));

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.pushReplacementNamed(context, demo.route);
      },
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(demo.name[0]),
      ),
      title: Text(
        demo.name,
        style: _biggerFont,
      ),
    );
  }
}

class DemoList extends StatefulWidget {
  const DemoList({super.key});

  @override
  State<DemoList> createState() => _DemoListState();
}

class _DemoListState extends State<DemoList> {
  late Future<List<Demo>> _futureDemo;

  @override
  void initState() {
    super.initState();
    setState(() {
      _futureDemo = fetchDemo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo List'),
      ),
      body: FutureBuilder<List<Demo>>(
          future: _futureDemo,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var items = snapshot.data as List<Demo>;
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: items.length * 2,
                itemBuilder: (context, i) {
                  if (i.isOdd) {
                    return const Divider();
                  }

                  final index = i ~/ 2;

                  return DemoListItem(demo: items[index]);
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("${snapshot.error}"),
              );
            }

            // By default, show a loading spinner.
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const DemoList(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/counter': (context) => const counter.MyApp(),
        '/sunflower': (context) => const sunflower.Sunflower(),
        '/startup_namer': (context) => const startup_namer.MyApp(),
        '/layout_basic': (context) => const layout_basic.MyApp(),
        '/baby_names': (context) => const baby_names.MyApp(),
        '/friendlychat': (context) => const friendlychat.FriendlychatApp(),
        '/shrine': (context) => const shrine.ShrineApp(),
        '/chat_app': (context) => chat_app.widgetProvider(),
        '/game': (context) => game.gameMain(),
      },
    );
  }
}

Future<void> main() async {
  // To enable Firebase Crashlytics, uncomment the following lines and
  // the import statements at the top of this file.
  // See the 'Crashlytics' section of the main README.md file for details.

  FirebaseCrashlytics? crashlytics;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   try {
  //     WidgetsFlutterBinding.ensureInitialized();
  //     await Firebase.initializeApp(
  //       options: DefaultFirebaseOptions.currentPlatform,
  //     );
  //     crashlytics = FirebaseCrashlytics.instance;
  //   } catch (e) {
  //     debugPrint("Firebase couldn't be initialized: $e");
  //   }
  // }

  // for baby_names
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // for chat_app
  await AuthService.init();

  await guardWithCrashlytics(
    guardedMain,
    crashlytics: crashlytics,
  );
}

/// Without logging and crash reporting, this would be `void main()`.
void guardedMain() {
  if (kReleaseMode) {
    // Don't log anything below warnings in production.
    Logger.root.level = Level.WARNING;
  }
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: '
        '${record.loggerName}: '
        '${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}
