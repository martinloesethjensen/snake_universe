import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:snake_backend/database.dart';

final _pool = createPool();

Handler middleware(Handler handler) {
  return handler.use(provider<Pool<Object>>((_) => _pool));
}
