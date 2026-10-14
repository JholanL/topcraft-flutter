import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'users.dart';
import 'products.dart';
import 'orders.dart';
import 'requests.dart';
import 'materials.dart';
import 'tasks.dart';
import 'addresses.dart';
import 'activity.dart';
import 'seed.dart';

// Saves all the global lists on the phone using shared_preferences,
// so the data stays even after the app is closed. No database is used.
class Store {
  static const String _dataKey = "topcraft.data.v1";
  static const String _sessionKey = "topcraft.session.v1";
  static SharedPreferences? _prefs;
  static int _seq = 0;

  static String newId() {
    _seq++;
    return "${DateTime.now().microsecondsSinceEpoch}$_seq";
  }

  static Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    String? raw = _prefs!.getString(_dataKey);
    bool loaded = false;
    if (raw != null) {
      try {
        Map<String, dynamic> data = jsonDecode(raw);
        AllUsers.userList = data["users"];
        AllProducts.productList = data["products"];
        AllProducts.reviewList = data["reviews"];
        AllOrders.cartList = data["cart"];
        AllOrders.orderList = data["orders"];
        AllOrders.orderCounter = data["orderCounter"];
        AllRequests.requestList = data["requests"];
        AllRequests.requestCounter = data["requestCounter"];
        AllMaterials.materialList = data["materials"];
        AllMaterials.stockLogs = data["stockLogs"];
        AllTasks.taskList = data["tasks"];
        AllAddresses.addressList = data["addresses"];
        AllActivity.notificationList = data["notifications"];
        AllActivity.logList = data["logs"];
        loaded = true;
      } catch (e) {
        loaded = false;
      }
    }
    if (!loaded) {
      Seed.apply();
      save();
    }
    //restore the logged in account, like the session restore of mobile-topcraft
    String email = _prefs!.getString(_sessionKey) ?? "";
    AllUsers.activeEmail = AllUsers.find(email) == null ? "" : email;
  }

  static void save() {
    if (_prefs == null) return;
    _prefs!.setString(
      _dataKey,
      jsonEncode({
        "users": AllUsers.userList,
        "products": AllProducts.productList,
        "reviews": AllProducts.reviewList,
        "cart": AllOrders.cartList,
        "orders": AllOrders.orderList,
        "orderCounter": AllOrders.orderCounter,
        "requests": AllRequests.requestList,
        "requestCounter": AllRequests.requestCounter,
        "materials": AllMaterials.materialList,
        "stockLogs": AllMaterials.stockLogs,
        "tasks": AllTasks.taskList,
        "addresses": AllAddresses.addressList,
        "notifications": AllActivity.notificationList,
        "logs": AllActivity.logList,
      }),
    );
  }

  static void signIn(String email) {
    AllUsers.activeEmail = email;
    _prefs?.setString(_sessionKey, email);
  }

  static void signOut() {
    AllUsers.activeEmail = "";
    _prefs?.remove(_sessionKey);
  }

  //brings back the original demo data
  static void reset() {
    Seed.apply();
    save();
  }
}
