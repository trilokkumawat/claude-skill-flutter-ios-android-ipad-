# Screen states

Every screen that loads or changes data handles the states it can reach. Missing states are the
most common UI defect.

| State | When | Show | Avoid |
|---|---|---|---|
| Initial | Before the first load starts | Usually goes straight to loading | A blank frame |
| Loading | First load, nothing cached | Skeleton shaped like the content for content-heavy screens; a small indicator for short actions | A bare centred spinner as the default for whole screens |
| Success | Data present | The content | — |
| Refreshing | Reloading with data shown | Content plus a subtle indicator (pull-to-refresh) | Replacing content with a skeleton |
| Empty (first use) | No data yet | What this area is for and the action that fills it | A dead end |
| Empty (filtered) | Filters or search hide everything | Say so and offer to clear filters | The first-use message |
| Error (recoverable) | A request failed | What happened in plain words, what to do, and Retry | Raw exception text, error codes alone |
| Error (partial) | One section failed | That section's error with its own retry; the rest works | Failing the whole screen |
| Offline | No connection | Cached content with an offline notice; queued actions marked pending | Blocking the screen when cached data exists |
| Disabled | An action is unavailable | Visibly disabled control plus the reason when not obvious | Controls that look tappable but do nothing |
| Submitting | An action is in flight | Busy state on the control; prevent double submission | Freezing the whole screen |
| Done | An action succeeded | Brief confirmation (snackbar, inline check) and, for destructive actions, undo where possible | Silent success |
| Unauthorised | Session expired | Route to sign-in, preserving where the user was | An error message with no way forward |

## Modelling states in Dart

Model states explicitly instead of a bag of nullable fields plus `isLoading`:

```dart
sealed class TasksState {
  const TasksState();
}

final class TasksLoading extends TasksState {
  const TasksLoading();
}

final class TasksLoaded extends TasksState {
  const TasksLoaded(this.tasks, {this.isOffline = false, this.isRefreshing = false});
  final List<Task> tasks;
  final bool isOffline;
  final bool isRefreshing;
}

final class TasksFailed extends TasksState {
  const TasksFailed(this.failure);
  final Failure failure;
}
```

With Riverpod, `AsyncValue` already models loading, data, and error; keep the previous value on
reload (`AsyncValue.value`, `hasValue`) so refreshing does not flash a skeleton. The widget
switches over the state exhaustively; the state owner decides which state applies.

## Copy

- Errors: what happened, then what to do ("Couldn't load your tasks. Check your connection and
  try again.").
- Empty states: what belongs here and the first action ("No tasks yet. Add your first task.").
- Sentence case for messages; labels follow the project's casing rules.
- Never blame the user; never show stack traces, error codes alone, or server messages verbatim.

## Tests

One widget test per reachable state, asserting the visible text or widget and that the primary
action is present and enabled or disabled as expected.
