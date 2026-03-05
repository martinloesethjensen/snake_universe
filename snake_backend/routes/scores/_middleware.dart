import 'package:dart_frog/dart_frog.dart';
import 'package:snake_backend/database.dart';

final _db = AppDatabase();

Handler middleware(Handler handler) {
  return handler.use(provider<AppDatabase>((_) => _db));
}
