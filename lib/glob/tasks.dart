class AllTasks {
  //production tasks assigned to workers
  //{"id","orderId","orderCode","worker","title","details","progress","dueDate","assignedAt","completedAt","note"}
  //progress: To Do -> In Progress -> Done
  static List<dynamic> taskList = [];

  static String selectedId = "";

  static dynamic find(String id) {
    for (int i = 0; i < taskList.length; i++) {
      if (taskList[i]["id"] == id) return taskList[i];
    }
    return null;
  }

  static dynamic forOrder(String orderId) {
    for (int i = taskList.length - 1; i >= 0; i--) {
      if (taskList[i]["orderId"] == orderId) return taskList[i];
    }
    return null;
  }

  static List<dynamic> ofWorker(String email) {
    List<dynamic> list = [];
    for (int i = taskList.length - 1; i >= 0; i--) {
      if (taskList[i]["worker"] == email) list.add(taskList[i]);
    }
    return list;
  }

  static int activeCount(String email) {
    int count = 0;
    for (int i = 0; i < taskList.length; i++) {
      if (taskList[i]["worker"] == email && taskList[i]["progress"] != "Done") count++;
    }
    return count;
  }
}
