import 'dart:async';
import 'package:universal_html/html.dart' as html;

class Sse {
  final html.EventSource eventSource;
  final StreamController<String> streamController;

  Sse._internal(this.eventSource, this.streamController);

  factory Sse.connect({
    required Uri uri,
    bool withCredentials = false,
    bool closeOnError = true,
  }) {
    final streamController = StreamController<String>();
    final eventSource = html.EventSource(uri.toString(), withCredentials: withCredentials);

    eventSource.addEventListener('message', (html.Event message) {
      streamController.add((message as html.MessageEvent).data as String);
    });

    if (closeOnError) {
      eventSource.onError.listen((event) {
        eventSource?.close();
        streamController?.close();
      });
    }
    return Sse._internal(eventSource, streamController);
  }

  Stream get stream => streamController.stream;

  bool isClosed() => streamController.isClosed;

  void close() {
    eventSource?.close();
    streamController?.close();
  }
}

/*void testSse() {
  final myStream = Sse.connect(
    uri: Uri.parse(
        'http://192.168.1.20/listen'),
    closeOnError: true,
    withCredentials: false,
  ).stream;

  myStream.listen((event) {
    debugPrint('Received:${DateTime.now().millisecondsSinceEpoch} : $event');
  });
}*/