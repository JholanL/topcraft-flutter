class AllProducts {
  //furniture catalog
  //{"id","name","category","price","stock","material","dimensions","description","image","featured","createdAt"}
  //image is "asset:<path>" for built-in photos or "b64:<data>" for uploaded photos
  static List<dynamic> productList = [];

  //customer reviews {"id","productId","orderId","customer","rating","comment","date"}
  static List<dynamic> reviewList = [];

  //id of the product being viewed or edited ("" = new product)
  static String selectedId = "";

  static List<String> categories = ["Chairs", "Tables", "Storage", "Beds", "Sofas"];

  //built-in photos the owner can choose from
  static List<String> builtInImages = [
    "asset:assets/images/chair1.png",
    "asset:assets/images/chair2.png",
    "asset:assets/images/table1.png",
    "asset:assets/images/table2.png",
    "asset:assets/images/table3.png",
  ];

  static dynamic find(String id) {
    for (int i = 0; i < productList.length; i++) {
      if (productList[i]["id"] == id) return productList[i];
    }
    return null;
  }

  static List<dynamic> reviewsOf(String productId) {
    List<dynamic> list = [];
    for (int i = reviewList.length - 1; i >= 0; i--) {
      if (reviewList[i]["productId"] == productId) list.add(reviewList[i]);
    }
    return list;
  }

  static double averageRating(String productId) {
    List<dynamic> list = reviewsOf(productId);
    if (list.isEmpty) return 0;
    num total = 0;
    for (int i = 0; i < list.length; i++) {
      total = total + list[i]["rating"];
    }
    return total / list.length;
  }

  //how many pieces were already ordered (used for "best sellers")
  static int soldCount(String productId, List<dynamic> orderList) {
    int count = 0;
    for (int i = 0; i < orderList.length; i++) {
      if (orderList[i]["status"] == "Cancelled") continue;
      List<dynamic> items = orderList[i]["items"];
      for (int j = 0; j < items.length; j++) {
        if (items[j]["productId"] == productId) count = count + (items[j]["qty"] as int);
      }
    }
    return count;
  }
}
