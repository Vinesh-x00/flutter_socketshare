import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_socketshare/bloc/file_bloc.dart';
import 'package:flutter_socketshare/models.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_socketshare/utils/validators.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  bool isConEventSended = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "SocketShare",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 36, 39, 46),
      ),
      backgroundColor: const Color.fromARGB(255, 53, 57, 69),
      body: BlocListener<FileBloc, FileState>(
        listenWhen: (previousState, currentState) {
          if (currentState.connectionState == SocketConnectionState.failed) {
            isConEventSended = false;
          }
          if (previousState.connectionState !=
                  SocketConnectionState.connected &&
              currentState.connectionState == SocketConnectionState.connected) {
            return true;
          }
          return false;
        },
        listener: (context, state) {
          if (state.connectionState == SocketConnectionState.connected) {
            Navigator.pushNamed(context, "/sending");
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: MobileScanner(
            fit: BoxFit.contain,
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
              facing: CameraFacing.back,
              torchEnabled: false,
            ),
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (null != barcode.rawValue) {
                  try {
                    Map<String, dynamic> json = jsonDecode(barcode.rawValue!);

                    if (isValidHost(json["ipaddr"] ?? "") &&
                        isValidPort(json["port"] ?? "") &&
                        !isConEventSended) {
                      isConEventSended = true;
                      context.read<FileBloc>().add(Connect(
                          host: json["ipaddr"], port: int.parse(json["port"])));
                    }
                  } catch (err) {
                    developer.log(err.toString());
                  }
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
