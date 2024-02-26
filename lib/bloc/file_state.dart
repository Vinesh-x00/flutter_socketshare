part of 'file_bloc.dart';

class FileState {
  final SocketConnectionState connectionState;
  final List<FileInfo> sended;

  FileState({
    required this.connectionState,
    required this.sended,
  });

  factory FileState.initial() {
    return FileState(
      connectionState: SocketConnectionState.none,
      sended: const <FileInfo>[],
    );
  }

  FileState copy({SocketConnectionState? connectionState}) {
    return FileState(
      connectionState: connectionState ?? this.connectionState,
      sended: sended,
    );
  }

  FileState copyWithNewPercentage(
      {required int index, required double percentage}) {
    sended[index].percentage += percentage;
    return copy();
  }

  FileState copyWithNewFileTstate(
      {required int index, required FileTState ts}) {
    sended[index].state = ts;
    return copy();
  }

  FileState copyWithRemovedSend({required int index}) {
    sended.removeAt(index);
    return copy();
  }

  FileState copyWithNewSend(
      {SocketConnectionState? connectionState, required FileInfo newFile}) {
    return FileState(
      connectionState: connectionState ?? this.connectionState,
      sended: List.from(sended)..add(newFile),
    );
  }

  FileState clear() {
    return FileState(
      connectionState: SocketConnectionState.disconnected,
      sended: [],
    );
  }
}
