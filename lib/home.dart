import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late WebSocketChannel webSocket;
  final List<List<TextEditingController>> _tableData = [
    [
      TextEditingController(text: 'one'),
      TextEditingController(text: 'two'),
      TextEditingController(text: 'three'),
    ],
    [
      TextEditingController(text: 'four'),
      TextEditingController(text: 'five'),
      TextEditingController(text: 'six'),
    ],
    [
      TextEditingController(text: 'seven'),
      TextEditingController(text: 'eight'),
      TextEditingController(text: 'nine'),
    ],
  ];

  @override
  void initState() {
    super.initState();
    connect();
  }

  Future<void> connect() async {
    try {
      webSocket = IOWebSocketChannel.connect('wss://socketsbay.com/wss/v2/10/497dca4106e10451f84b097d6b77cd68/');
      // webSocket = IOWebSocketChannel.connect('wss://socketsbay.com/wss/v2/1/demo/');
      // webSocket = IOWebSocketChannel.connect('wss://ws.postman-echo.com/raw');
      webSocket.stream.listen(
        (message) => _handleWebSocketMessage(message),
        onError: (error) => _handleWebSocketError(error),
        onDone: () => _handleWebSocketDisconnect(),
      );
    } catch (e) {
      _handleWebSocketError(e);
    }
  }

  void _handleWebSocketMessage(String message) {
    print('WebSocket message: $message');
    final parts = message.split(':');
    if (parts.length == 4 && parts[0] == 'test') {
      final rowIndex = int.tryParse(parts[1]);
      final colIndex = int.tryParse(parts[2]);
      if (rowIndex != null && colIndex != null && rowIndex < _tableData.length && colIndex < _tableData[rowIndex].length) {
        _tableData[rowIndex][colIndex].text = parts[3];
      }
    }
  }

  void _handleWebSocketError(dynamic error) {
    print('WebSocket error: $error');
  }

  void _handleWebSocketDisconnect() {
    print('WebSocket disconnected');
  }

  @override
  void dispose() {
    webSocket.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Table Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Table(
                border: TableBorder.all(),
                children: _tableData.map((row) {
                  return TableRow(
                    children: row.map((cell) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: cell,
                          decoration: const InputDecoration(border: InputBorder.none),
                          onChanged: (value) {
                            webSocket.sink.add('test:${_tableData.indexOf(row)}:${row.indexOf(cell)}:$value');
                          },
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
