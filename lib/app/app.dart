import 'package:flutter/material.dart';
import 'package:github_repo_list/screens/app_shell.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        "/": (context) => const AppShell()
      },
      initialRoute: "/",
    );
  }
}