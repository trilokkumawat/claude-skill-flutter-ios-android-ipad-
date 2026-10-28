// import 'package:sample_app/main.dart';  (a commented-out import must be ignored)
/* import 'package:sample_app/app/router.dart'; also ignored */
import 'api_client.dart';
import 'stub.dart' if (dart.library.io) 'io_impl.dart';

part 'session.g.dart';

const docs = 'import "package:sample_app/main.dart"; // not a directive';

class Session {
  ApiClient? client;
}
