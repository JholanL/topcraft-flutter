import '../theme/format.dart';
import 'users.dart';

class AllActivity {
  //in-app notifications {"id","email","title","body","type","date","read"}
  static List<dynamic> notificationList = [];

  //activity logs {"id","email","action","date"}
  static List<dynamic> logList = [];

  static int _seq = 0;

  static String _id() {
    _seq++;
    return "${DateTime.now().microsecondsSinceEpoch}$_seq";
  }

  static void notify(String email, String title, String body, String type) {
    if (email.isEmpty) return;
    notificationList.add({
      "id": _id(),
      "email": email,
      "title": title,
      "body": body,
      "type": type,
      "date": Format.now(),
      "read": false,
    });
  }

  //sends the notification to every account with this role
  static void notifyRole(String role, String title, String body, String type) {
    List<dynamic> users = AllUsers.byRole(role);
    for (int i = 0; i < users.length; i++) {
      notify(users[i]["email"], title, body, type);
    }
  }

  static void log(String email, String action) {
    logList.add({"id": _id(), "email": email, "action": action, "date": Format.now()});
  }

  static List<dynamic> notificationsOf(String email) {
    List<dynamic> list = [];
    for (int i = notificationList.length - 1; i >= 0; i--) {
      if (notificationList[i]["email"] == email) list.add(notificationList[i]);
    }
    return list;
  }

  static int unreadCount(String email) {
    int count = 0;
    for (int i = 0; i < notificationList.length; i++) {
      if (notificationList[i]["email"] == email && notificationList[i]["read"] == false) count++;
    }
    return count;
  }

  static List<dynamic> logsOf(String email) {
    List<dynamic> list = [];
    for (int i = logList.length - 1; i >= 0; i--) {
      if (logList[i]["email"] == email) list.add(logList[i]);
    }
    return list;
  }
}
