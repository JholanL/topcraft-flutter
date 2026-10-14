import '../theme/format.dart';
import 'activity.dart';

class AllOrders {
  //cart items {"id","email","productId","qty"}
  static List<dynamic> cartList = [];

  //orders {"id","code","customer","type","items":[{"productId","name","price","qty","image"}],
  //        "subtotal","deliveryFee","total","payment","recipient","phone","address",
  //        "status","worker","notes","qcNotes","rated","createdAt","updatedAt",
  //        "timeline":[{"status","note","date"}]}
  static List<dynamic> orderList = [];

  //id of the order being viewed
  static String selectedId = "";

  //used to create the next order number
  static int orderCounter = 1006;

  static const int deliveryFee = 500;

  //production flow, same idea as the stages of mobile-topcraft
  static List<String> stages = ["Pending", "In Production", "Quality Check", "Out for Delivery", "Completed"];

  static dynamic find(String id) {
    for (int i = 0; i < orderList.length; i++) {
      if (orderList[i]["id"] == id) return orderList[i];
    }
    return null;
  }

  static List<dynamic> cartOf(String email) {
    List<dynamic> list = [];
    for (int i = 0; i < cartList.length; i++) {
      if (cartList[i]["email"] == email) list.add(cartList[i]);
    }
    return list;
  }

  static int cartCount(String email) {
    int count = 0;
    for (int i = 0; i < cartList.length; i++) {
      if (cartList[i]["email"] == email) count = count + (cartList[i]["qty"] as int);
    }
    return count;
  }

  //CREATE/UPDATE cart item. Returns an error message or "" if added.
  static String addToCart(String email, dynamic product, int qty) {
    if (product["stock"] <= 0) return "This item is out of stock.";
    dynamic existing;
    for (int i = 0; i < cartList.length; i++) {
      if (cartList[i]["email"] == email && cartList[i]["productId"] == product["id"]) existing = cartList[i];
    }
    int inCart = existing == null ? 0 : existing["qty"];
    if (inCart + qty > product["stock"]) return "Only ${product["stock"]} left in stock (you have $inCart in your cart).";
    if (existing == null) {
      cartList.add({"id": "c${DateTime.now().microsecondsSinceEpoch}", "email": email, "productId": product["id"], "qty": qty});
    } else {
      existing["qty"] = inCart + qty;
    }
    return "";
  }

  static List<dynamic> ofCustomer(String email) {
    List<dynamic> list = [];
    for (int i = orderList.length - 1; i >= 0; i--) {
      if (orderList[i]["customer"] == email) list.add(orderList[i]);
    }
    return list;
  }

  static int countStatus(String status) {
    int count = 0;
    for (int i = 0; i < orderList.length; i++) {
      if (orderList[i]["status"] == status) count++;
    }
    return count;
  }

  static String itemSummary(dynamic order) {
    List<dynamic> items = order["items"];
    if (items.isEmpty) return "No items";
    String first = "${items[0]["name"]} x${items[0]["qty"]}";
    if (items.length == 1) return first;
    return "$first +${items.length - 1} more";
  }

  //changes the status, adds it to the timeline and notifies the customer
  static void setStatus(dynamic order, String status, String note) {
    order["status"] = status;
    order["updatedAt"] = Format.now();
    List<dynamic> timeline = order["timeline"];
    timeline.add({"status": status, "note": note, "date": Format.now()});
    AllActivity.notify(order["customer"], "${order["code"]} • $status", note, "order");
  }
}
