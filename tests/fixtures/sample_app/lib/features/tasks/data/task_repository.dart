import 'package:http/http.dart' as http;
import 'package:sample_app/core/session.dart';
// The data layer importing presentation closes a cycle inside the feature.
import '../presentation/task_list_screen.dart' show TaskListScreen;

class TaskRepository {
  final Session session = Session();
  TaskListScreen? lastScreen;
  http.Client? client;
}
