enum Sender {
  client,
  server,
}

enum SocketConnectionState {
  disconnected,
  connected,
  failed,
  none,
}

enum FileTState {
  sending,
  ended,
}

enum Signals {
  start,
  cancel,
  end,
}

class FileInfo {
  final String filepath;
  final String id;
  final String extenstion;
  double percentage = 0.0;
  FileTState state;

  FileInfo({
    required this.id,
    required this.filepath,
    required this.extenstion,
    required this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "path": filepath,
      "exnetnstion": extenstion,
    };
  }
}

class Message {
  final Signals signal;
  String? filepath;
  String id;
  String? extenstion;

  Message({
    required this.signal,
    required this.id,
    this.filepath,
    this.extenstion,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    Signals? signal;

    switch (json["signal"]) {
      case "start":
        signal = Signals.start;
        break;
      case "cancel":
        signal = Signals.cancel;
        break;
      case "end":
        signal = Signals.end;
        break;
    }
    return Message(
      signal: signal!,
      filepath: json["filepath"],
      id: json["id"],
      extenstion: json["ext"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "signal": signal.name,
      "path": filepath ?? "",
      "ext": extenstion ?? "",
      "id": id
    };
  }
}
