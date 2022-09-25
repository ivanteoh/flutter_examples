import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_page.dart';
import 'login_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  runApp(widgetProvider());
  // runApp(ChangeNotifierProvider(
  //   create: (BuildContext context) => AuthService(),
  //   child: ChatApp(),
  // ));
}

Widget widgetProvider() {
  return ChangeNotifierProvider(
    create: (BuildContext context) => AuthService(),
    child: const ChatApp(),
  );
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat App",
      theme: ThemeData(
          canvasColor: Colors.transparent,
          primarySwatch: Colors.deepPurple,
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue, foregroundColor: Colors.black)),
      home: FutureBuilder<bool>(
          future: context.read<AuthService>().isLoggedIn(),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data!) {
                return const ChatPage();
              } else {
                return LoginPage();
              }
            }
            return const CircularProgressIndicator();
          }),
      routes: {'/chat': (context) => const ChatPage()},
    );
  }
}
