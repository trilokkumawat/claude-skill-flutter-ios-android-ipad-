// Cross-feature import: tasks reaches into the auth feature's presentation.
import 'package:sample_app/features/auth/presentation/login_screen.dart';
import '../data/task_repository.dart';

class TaskListScreen {
  final TaskRepository repository = TaskRepository();
  LoginScreen? back;
}
