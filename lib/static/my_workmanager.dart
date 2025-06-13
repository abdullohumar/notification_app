enum MyWorkmanager {
  oneOff("task-identifier", "task-identifier"),
  periodic("com.ngumar.notificationApp", "com.ngumar.notificationApp");

  final String uniqueName;
  final String taskName;

  const MyWorkmanager(this.uniqueName, this.taskName);
}