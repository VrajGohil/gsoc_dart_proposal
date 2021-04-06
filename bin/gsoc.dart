import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:path/path.dart';

Future<void> main() async {
  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(_echoRequest);

  var server = await io.serve(handler, '0.0.0.0', 5901);
  print('Serving at http://${server.address.host}:${server.port}');
}

Future<shelf.Response> _echoRequest(shelf.Request request) async {
  // POST request example
  // {
  //   'username': 'gsoc',
  //   'password': 'verysecurepassword'
  // }
  //Response
  // {'token': 'gsocverysecurepassword'}
  if (request.method == 'POST') {
    final headers = {'Content-Type': 'application/json'};

    final data = request.read();
    final json = await data.transform(Utf8Decoder()).join();

    final String username = jsonDecode(json)['username'];
    final String password = jsonDecode(json)['password'];

    final token = '{"token": "${username}_${password}"}';
    print(token);

    return shelf.Response.ok(token, headers: headers);
  } else {
    final headers = {'Content-Type': 'text/html'};
    final html = await renderHtml(request.url.toString());
    return shelf.Response.ok(html, headers: headers);
  }
}

Future<String> renderHtml(String text) async {
  try {
    final pathToFile = join(dirname(Platform.script.toFilePath()), 'game.html');
    final html = await File(pathToFile).readAsString().then((String contents) {
      return contents;
    });
    return html.replaceAll('{{ text }}', 'You are at $text');
  } catch (e) {
    return '<h1>Error:  $e</h1>';
  }
}
