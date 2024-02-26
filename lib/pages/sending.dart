import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_socketshare/utils/filesmanager.dart';

import 'package:percent_indicator/percent_indicator.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter_socketshare/bloc/file_bloc.dart';
import 'package:flutter_socketshare/models.dart';

class IconGiver extends StatelessWidget {
  final String ext;
  IconGiver({super.key, required this.ext});

  final imagesExt = ["png", "jpg", "jpeg"];

  @override
  Widget build(BuildContext context) {
    if (imagesExt.contains(ext)) {
      return const Icon(Icons.image);
    }
    return const Icon(Icons.question_mark);
  }
}

class SendingPage extends StatefulWidget {
  const SendingPage({super.key});

  @override
  State<SendingPage> createState() => _SendingPageState();
}

class _SendingPageState extends State<SendingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 53, 57, 69),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Builder(builder: (context) {
          final connState =
              context.select((FileBloc bloc) => bloc.state.connectionState);
          return AppBar(
            backgroundColor: connState != SocketConnectionState.failed
                ? const Color.fromARGB(255, 36, 39, 46)
                : const Color.fromARGB(255, 109, 0, 0),
            title: const Text(
              "SocketShare",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              onPressed: () {
                context.read<FileBloc>().add(Disconnect());
                Navigator.pop(context);
              },
              color: Colors.white,
            ),
          );
        }),
      ),
      body: BlocBuilder<FileBloc, FileState>(builder: (context, state) {
        return ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final file = state.sended[index]; //file
              return ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    getFilename(file.filepath),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconGiver(ext: file.extenstion),
                ),
                subtitle: LinearPercentIndicator(
                  lineHeight: 5.0,
                  backgroundColor: const Color.fromARGB(255, 36, 39, 46),
                  progressColor: Colors.white,
                  percent: file.percentage <= 1.0 ? file.percentage : 1.0,
                  barRadius: const Radius.circular(50.0),
                ),
                trailing: state.sended[index].state == FileTState.sending
                    ? GestureDetector(
                        onTap: () {
                          context.read<FileBloc>().add(CancelSendind(id: "hh"));
                        },
                        child: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            },
            itemCount: state.sended.length);
      }),
      floatingActionButton: Builder(builder: (context) {
        final connState =
            context.select((FileBloc bloc) => bloc.state.connectionState);
        return FloatingActionButton(
          onPressed: () {
            if (context.read<FileBloc>().state.connectionState ==
                SocketConnectionState.connected) {
              FilePicker.platform.pickFiles().then((result) {
                if (null != result) {
                  String filePath = result.files.single.path!;
                  developer.log(filePath);
                  context.read<FileBloc>().add(AddFile(filePath: filePath));
                }
              });
            }
          },
          backgroundColor: connState != SocketConnectionState.failed
              ? Colors.blue
              : Colors.red,
          child: const Icon(Icons.add),
        );
      }),
    );
  }
}
