import '../enums/enums.dart';

extension TaskStatusExtension on TaskStatus? {
  bool get isFinished {
    return this == null ||
        this == TaskStatus.done ||
        this == TaskStatus.canceled ||
        this == TaskStatus.failure;
  }

  bool get isFailed {
    return this == TaskStatus.failure || this == TaskStatus.canceled;
  }

  bool get isNotStarted {
    return this == null || this == TaskStatus.initial;
  }

  /// التحقق مما إذا كانت المهمة لم تبدأ بعد
  bool get isInProgress {
    return this == null || this == TaskStatus.inProgress;
  }

  bool get isDone {
    return this == TaskStatus.done;
  }
}
