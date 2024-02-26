import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_socketshare/bloc/file_bloc.dart';
import 'package:flutter_socketshare/models.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  final _hostController = TextEditingController(text: "192.168.1.16");
  final _portController = TextEditingController(text: "8000");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("SocketShare"),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 36, 39, 46),
      ),
      backgroundColor: const Color.fromARGB(255, 53, 57, 69),
      body: SafeArea(
        child: BlocListener<FileBloc, FileState>(
          listenWhen: (previousState, currentState) {
            if (previousState.connectionState !=
                    SocketConnectionState.connected &&
                currentState.connectionState ==
                    SocketConnectionState.connected) {
              return true;
            }
            return false;
          },
          listener: (context, state) {
            if (state.connectionState == SocketConnectionState.connected) {
              Navigator.pushNamed(context, "/sending");
            }
          },
          child: ListView(
            padding: const EdgeInsets.only(left: 10, top: 10),
            children: [
              TextField(
                controller: _hostController,
                decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0.0),
                    ),
                    hintText: "Ip Adress"),
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: _portController,
                decoration: const InputDecoration(hintText: "Port"),
              ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  final host = _hostController.text;
                  final port = int.parse(_portController.text == ""
                      ? "5000"
                      : _portController.text);
                  context.read<FileBloc>().add(Connect(host: host, port: port));
                },
                child: const Text(
                  "Connect",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Builder(builder: (context) {
                final state = context
                    .select((FileBloc bloc) => bloc.state.connectionState);
                if (state == SocketConnectionState.failed) {
                  return const Text("Unable to Connect",
                      style: TextStyle(color: Colors.red));
                } else {
                  return const SizedBox.shrink();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
