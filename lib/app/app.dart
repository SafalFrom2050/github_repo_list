import 'package:flutter/material.dart';
import 'package:github_repo_list/app/app_shell.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github Repo List',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.lightBlueAccent, brightness: .dark),
      ),
      routes: {
        "/": (context) => const AppShell()
      },
      initialRoute: "/",
    );
  }
}