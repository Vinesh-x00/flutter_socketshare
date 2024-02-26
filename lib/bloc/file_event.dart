part of 'file_bloc.dart';

@immutable
sealed class FileEvent {}

class Connect extends FileEvent {
  final String host;
  final int port;

  Connect({
    required this.host,
    required this.port,
  });
}

class Disconnect extends FileEvent {}

class ErrorOcured extends FileEvent {}

class SendFile extends FileEvent {
  final int index;

  SendFile({
    required this.index,
  });
}

class CheckPending extends FileEvent {}

class AddFile extends FileEvent {
  final String filePath;

  AddFile({required this.filePath});
}

class CancelSendind extends FileEvent {
  final String id;

  CancelSendind({
    required this.id,
  });
}

class FileRecvied extends FileEvent {
  final File file;

  FileRecvied({
    required this.file,
  });
}
