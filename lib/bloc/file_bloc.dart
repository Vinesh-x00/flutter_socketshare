import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:flutter_socketshare/models.dart';
import 'package:flutter_socketshare/utils/filesmanager.dart';
import 'package:flutter_socketshare/utils/generators.dart';

part 'file_event.dart';
part 'file_state.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  Socket? _msgSocket;
  StreamSubscription? _msgSocketStreamSub;
  ConnectionTask<Socket>? _msgSocketConnectionTask;

  Socket? _fileSocket;
  StreamSubscription? _fileSocketStreamSub;
  ConnectionTask<Socket>? _fileSocketConnectionTask;

  bool isCanceled = false;
  bool isSomeThingSending = false;

  File? currentFile;
  Queue indexQueue = Queue<int>();

  Future<FileState> _connect(Connect event) async {
    try {
      //create socket form msg sending
      _msgSocketConnectionTask =
          await Socket.startConnect(event.host, event.port);
      _msgSocket = await _msgSocketConnectionTask!.socket;

      //create socket for file sending
      _fileSocketConnectionTask =
          await Socket.startConnect(event.host, event.port);
      _fileSocket = await _fileSocketConnectionTask!.socket;

      _msgSocket?.handleError((err) {
        add(ErrorOcured());
      });

      _fileSocket?.handleError((err) {
        add(ErrorOcured());
      });

      _msgSocketStreamSub = _msgSocket?.listen((event) {}, onDone: () {
        add(ErrorOcured());
      });

      _fileSocketStreamSub = _fileSocket?.listen((event) {}, onDone: () {
        add(ErrorOcured());
      });

      return state.copy(connectionState: SocketConnectionState.connected);
    } catch (err) {
      return state.copy(connectionState: SocketConnectionState.failed);
    }
  }

  Future<void> _sendFile(SendFile event, Emitter<FileState> emit) async {
    String path = state.sended[event.index].filepath;
    String extenstion = state.sended[event.index].extenstion;
    final file = File(path);
    final int size = file.lengthSync();
    final stream = file.openRead();

    String id = getRandomId(5);

    isSomeThingSending = true;
    Message startMsg = Message(
      signal: Signals.start,
      id: id,
      filepath: path,
      extenstion: extenstion,
    );

    _msgSocket!.write(jsonEncode(startMsg.toJson()));
    await Future.delayed(const Duration(seconds: 1));

    int currentSize = 0;
    double percentage;

    await for (final packet in stream) {
      if (isCanceled) {
        break;
      }
      currentSize += packet.length;
      percentage = currentSize / size;

      percentage = percentage >= 1.0 ? 1.0 : percentage;

      _fileSocket?.add(packet);
      emit(state.copyWithNewPercentage(
          index: event.index, percentage: percentage));
    }

    if (isCanceled) {
      Message cancelMsg = Message(signal: Signals.cancel, id: id);
      _msgSocket!.write(jsonEncode(cancelMsg.toJson()));
      emit(state.copyWithRemovedSend(index: event.index));
    } else {
      Message endMsg = Message(signal: Signals.end, id: id);
      _msgSocket!.write(jsonEncode(endMsg.toJson()));
      emit(state.copyWithNewFileTstate(
          index: event.index, ts: FileTState.ended));
    }

    isCanceled = false;
    isSomeThingSending = false;
    add(CheckPending());
  }

  void _checkPending(CheckPending event) {
    if (indexQueue.isNotEmpty && !isSomeThingSending) {
      add(SendFile(index: indexQueue.removeFirst()));
    }
  }

  FileState _addFiletoSendingList(AddFile event) {
    String path = event.filePath;
    String ext = getFileExtension(path);
    final f = FileInfo(
        id: "id", filepath: path, extenstion: ext, state: FileTState.sending);
    final newstate = state.copyWithNewSend(newFile: f);
    indexQueue.addLast(newstate.sended.length - 1);
    add(CheckPending());
    return newstate;
  }

  Future<FileState> _disconnect(Disconnect event) async {
    if (state.connectionState != SocketConnectionState.failed) {
      try {
        _msgSocketConnectionTask?.cancel();
        await _msgSocketStreamSub?.cancel();
        await _msgSocket?.close();

        _fileSocketConnectionTask?.cancel();
        await _fileSocketStreamSub?.cancel();
        await _fileSocket?.close();
      } catch (err) {
        developer.log("", name: 'Disconnect', error: err);
      }
    }

    return state.clear();
  }

  Future<FileState> _errorOcured(ErrorOcured event) async {
    _msgSocketConnectionTask?.cancel();
    await _msgSocketStreamSub?.cancel();
    await _msgSocket?.close();

    _fileSocketConnectionTask?.cancel();
    await _fileSocketStreamSub?.cancel();
    await _fileSocket?.close();
    return state.copy(connectionState: SocketConnectionState.failed);
  }

  FileBloc() : super(FileState.initial()) {
    on<Connect>((event, emit) async {
      emit(await _connect(event));
    });

    on<Disconnect>((event, emit) async {
      emit(await _disconnect(event));
    });

    on<ErrorOcured>((event, emit) async {
      emit(await _errorOcured(event));
    });

    on<SendFile>((event, emit) async {
      await _sendFile(event, emit);
    });

    on<CancelSendind>((event, emit) {
      isCanceled = true;
    });

    on<CheckPending>((event, emit) {
      _checkPending(event);
    });

    on<AddFile>((event, emit) {
      emit(_addFiletoSendingList(event));
    });
  }

  @override
  Future<void> close() async {
    _msgSocketConnectionTask?.cancel();
    await _msgSocketStreamSub?.cancel();
    await _msgSocket?.close();

    _fileSocketConnectionTask?.cancel();
    await _fileSocketStreamSub?.cancel();
    await _fileSocket?.close();
    return super.close();
  }
}
