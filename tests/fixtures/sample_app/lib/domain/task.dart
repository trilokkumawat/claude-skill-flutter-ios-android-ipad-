// Domain depending on a feature's data layer breaks the dependency direction.
import 'package:sample_app/features/tasks/data/task_repository.dart';

class Task {
  TaskRepository? source;
}
