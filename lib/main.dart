import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_socketshare/bloc/file_bloc.dart';
import 'package:flutter_socketshare/pages/connection.dart';
import 'package:flutter_socketshare/pages/sending.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FileBloc _filebloc = FileBloc();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SocketShare',
      routes: {
        "/": (context) {
          return BlocProvider.value(
            value: _filebloc,
            child: const ConnectionPage(),
          );
        },
        "/sending": (context) {
          return BlocProvider.value(
            value: _filebloc,
            child: const SendingPage(),
          );
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
