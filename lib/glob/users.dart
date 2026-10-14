class AllUsers {
  //all accounts of the system: owner, worker and customer
  //{"id","firstName","lastName","email","phone","password","role","position","status","createdAt"}
  static List<dynamic> userList = [];

  //email of the logged user
  static String activeEmail = "";

  //email of the account the owner wants to view or edit ("" = new account)
  static String selectedEmail = "";

  //simulated email OTP (signup and forgot password)
  static String otpCode = "";
  static String otpEmail = "";
  static String otpPurpose = ""; // signup or reset
  static dynamic pendingUser;

  static String newOtp() {
    otpCode = (100000 + DateTime.now().microsecondsSinceEpoch % 900000).toString();
    return otpCode;
  }

  //each role has its own home, same as FLOW_BY_ROLE of mobile-topcraft
  static String homeRoute(String role) {
    if (role == "owner") return "/admin";
    if (role == "worker") return "/worker";
    return "/customer";
  }

  static dynamic find(String email) {
    for (int i = 0; i < userList.length; i++) {
      if (userList[i]["email"].toString().toLowerCase() == email.toLowerCase()) {
        return userList[i];
      }
    }
    return null;
  }

  static dynamic get active => find(activeEmail);

  static String get activeRole => active == null ? "" : active["role"];

  static String fullName(String email) {
    dynamic user = find(email);
    if (user == null) return email.isEmpty ? "Unassigned" : email;
    return "${user["firstName"]} ${user["lastName"]}";
  }

  static String initials(String email) {
    dynamic user = find(email);
    if (user == null) return "?";
    String first = user["firstName"].toString();
    String last = user["lastName"].toString();
    return "${first.isEmpty ? "" : first[0]}${last.isEmpty ? "" : last[0]}".toUpperCase();
  }

  static List<dynamic> byRole(String role) {
    List<dynamic> list = [];
    for (int i = 0; i < userList.length; i++) {
      if (userList[i]["role"] == role) list.add(userList[i]);
    }
    return list;
  }
}
