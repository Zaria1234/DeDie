import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  IO.Socket? _socket;
  bool _isConnected = false;

  SocketService._internal();

  void connect(String adminToken) {
    _socket = IO.io(
      'http://localhost:3000',
      IO.OptionBuilder().setTransports(['websocket']).setQuery({
        'adminToken': adminToken,
      }).build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      print('Connecté au dashboard admin');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('Déconnecté du dashboard admin');
    });
  }

  void listenForNewReports(Function(dynamic) callback) {
    _socket?.on('new_report', (data) => callback(data));
  }

  void disconnect() {
    _socket?.disconnect();
    _isConnected = false;
  }

  bool get isConnected => _isConnected;
}
