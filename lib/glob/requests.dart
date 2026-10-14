class AllRequests {
  //custom furniture requests (the "Designs" module of mobile-topcraft without AI)
  //{"id","code","customer","furnitureType","dimensions","material","finish","quantity","budget",
  // "notes","image","status","quotePrice","quoteNote","leadDays","orderId","createdAt","updatedAt"}
  //status: Submitted -> Quoted -> Approved (becomes an order) / Rejected / Withdrawn
  static List<dynamic> requestList = [];

  static String selectedId = "";

  static int requestCounter = 2003;

  static List<String> furnitureTypes = ["Table", "Chair", "Cabinet", "Shelf", "Bed Frame", "Bench", "Sofa"];
  static List<String> materials = ["Narra Wood", "Acacia Wood", "Steel + Wood", "Black Steel", "Mahogany"];

  static dynamic find(String id) {
    for (int i = 0; i < requestList.length; i++) {
      if (requestList[i]["id"] == id) return requestList[i];
    }
    return null;
  }

  static List<dynamic> ofCustomer(String email) {
    List<dynamic> list = [];
    for (int i = requestList.length - 1; i >= 0; i--) {
      if (requestList[i]["customer"] == email) list.add(requestList[i]);
    }
    return list;
  }

  static int countStatus(String status) {
    int count = 0;
    for (int i = 0; i < requestList.length; i++) {
      if (requestList[i]["status"] == status) count++;
    }
    return count;
  }
}
