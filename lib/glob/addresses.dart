class AllAddresses {
  //delivery addresses of customers
  //{"id","email","label","recipient","phone","street","barangay","city","province","isDefault"}
  static List<dynamic> addressList = [];

  //id of the address being edited ("" = new address)
  static String selectedId = "";

  static List<dynamic> ofUser(String email) {
    List<dynamic> list = [];
    for (int i = 0; i < addressList.length; i++) {
      if (addressList[i]["email"] == email) list.add(addressList[i]);
    }
    return list;
  }

  static dynamic defaultOf(String email) {
    List<dynamic> list = ofUser(email);
    for (int i = 0; i < list.length; i++) {
      if (list[i]["isDefault"] == true) return list[i];
    }
    return list.isEmpty ? null : list[0];
  }

  static dynamic find(String id) {
    for (int i = 0; i < addressList.length; i++) {
      if (addressList[i]["id"] == id) return addressList[i];
    }
    return null;
  }

  static String fullText(dynamic address) {
    return "${address["street"]}, ${address["barangay"]}, ${address["city"]}, ${address["province"]}";
  }
}
