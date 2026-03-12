import 'dart:io';

import 'package:backend/bootstrap.dart';
import 'package:dart_frog/dart_frog.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  return bootstrap(handler: handler, ip: ip, port: port);
}
