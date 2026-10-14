import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topcraft_flutter/main.dart';
import 'package:topcraft_flutter/theme/app_theme.dart';
import 'package:topcraft_flutter/glob/store.dart';
import 'package:topcraft_flutter/glob/users.dart';
import 'package:topcraft_flutter/glob/products.dart';
import 'package:topcraft_flutter/glob/orders.dart';
import 'package:topcraft_flutter/glob/requests.dart';
import 'package:topcraft_flutter/glob/tasks.dart';
import 'package:topcraft_flutter/glob/materials.dart';
import 'package:topcraft_flutter/glob/addresses.dart';

// Renders every screen of every role on a 360 x 780 dp phone (a small Android
// screen) using the real Inter font, then runs the whole order flow.

Future<void> loadFonts() async {
  FontLoader inter = FontLoader("Inter");
  for (String w in ["Regular", "Medium", "SemiBold", "Bold", "ExtraBold", "Italic", "BoldItalic"]) {
    inter.addFont(rootBundle.load("assets/fonts/Inter-$w.ttf"));
  }
  await inter.load();
}

Future<void> setPhone(WidgetTester t) async {
  t.view.physicalSize = const Size(1080, 2340);
  t.view.devicePixelRatio = 3.0;
  addTearDown(t.view.reset);
}

Widget appAt(String route) => MaterialApp(key: UniqueKey(), theme: AppTheme.build(), routes: appRoutes, initialRoute: route);

Future<void> resetData(String email) async {
  SharedPreferences.setMockInitialValues({});
  await Store.load();
  Store.reset();
  Store.signIn(email);
}

Future<void> tapText(WidgetTester t, String text) async {
  //lists build their children lazily, so scroll until the text exists
  if (find.text(text).evaluate().isEmpty) {
    await t.scrollUntilVisible(find.text(text), 300, scrollable: find.byType(Scrollable).first);
  }
  Finder f = find.text(text).last;
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pumpAndSettle();
}

void main() {
  setUpAll(loadFonts);

  Map<String, List<String>> pagesByRole = {
    "maria@gmail.com": ["/customer", "/product", "/cart", "/checkout", "/order", "/requestform", "/request", "/addresses", "/addressform", "/profile", "/changepassword", "/notifications"],
    "owner@imf.com": ["/admin", "/adminorder", "/productform", "/materialform", "/stocklogs", "/adminrequests", "/adminrequest", "/accounts", "/accountform", "/customers", "/reports", "/profile", "/notifications"],
    "juan@imf.com": ["/worker", "/task", "/profile", "/notifications"],
    "": ["/landing", "/login", "/signup", "/forgot"],
  };

  pagesByRole.forEach((email, pages) {
    for (String page in pages) {
      testWidgets("page $page as ${email.isEmpty ? "guest" : email}", (t) async {
        await setPhone(t);
        await t.runAsync(() => resetData(email));
        AllProducts.selectedId = "p1";
        AllOrders.selectedId = "o1002";
        AllRequests.selectedId = "cr1";
        AllTasks.selectedId = "t6";
        AllMaterials.selectedId = "m1";
        AllAddresses.selectedId = "a1";
        AllUsers.selectedEmail = "juan@imf.com";
        await t.pumpWidget(appAt(page));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      });
    }
  });

  testWidgets("every tab of every role", (t) async {
    await setPhone(t);
    Map<String, List<String>> tabs = {
      "maria@gmail.com": ["Orders", "Custom", "More", "Shop"],
      "owner@imf.com": ["Operations", "Inventory", "Catalog", "More", "Home"],
      "juan@imf.com": ["My Tasks", "Schedule", "Logs", "More", "Home"],
    };
    for (String email in tabs.keys) {
      await t.runAsync(() => resetData(email));
      await t.pumpWidget(appAt(AllUsers.homeRoute(AllUsers.activeRole)));
      await t.pumpAndSettle();
      for (String tab in tabs[email]!) {
        await t.tap(find.text(tab).last);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull, reason: "$email tab $tab");
      }
      await t.pumpWidget(const SizedBox());
    }
  });

  testWidgets("full order flow: customer -> owner -> worker -> owner -> customer", (t) async {
    await setPhone(t);
    await t.runAsync(() => resetData(""));
    Store.signOut();

    //customer signs in
    await t.pumpWidget(appAt("/login"));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).at(0), "maria@gmail.com");
    await t.enterText(find.byType(TextField).at(1), "12345678");
    await tapText(t, "Sign in");
    expect(find.text("Find your piece"), findsOneWidget);

    //opens a product, adds it to the cart and checks out
    await tapText(t, "Kyoto Dining Armchair");
    await tapText(t, "Add to Cart");
    expect(AllOrders.cartCount("maria@gmail.com"), 2); // 1 from the demo cart + 1
    await t.tap(find.byIcon(Icons.shopping_bag_outlined).first);
    await t.pumpAndSettle();
    await tapText(t, "Proceed to Checkout");
    int ordersBefore = AllOrders.orderList.length;
    int stockBefore = AllProducts.find("p1")["stock"];
    await t.tap(find.textContaining("Place Order"));
    await t.pumpAndSettle();
    await tapText(t, "Track Order");
    expect(AllOrders.orderList.length, ordersBefore + 1);
    expect(AllProducts.find("p1")["stock"], stockBefore - 1);
    dynamic order = AllOrders.orderList.last;
    expect(order["status"], "Pending");
    expect(AllOrders.cartCount("maria@gmail.com"), 0);
    expect(find.text(order["code"]), findsWidgets);

    //owner assigns a worker
    Store.signIn("owner@imf.com");
    AllOrders.selectedId = order["id"];
    await t.pumpWidget(appAt("/adminorder"));
    await t.pumpAndSettle();
    await tapText(t, "Assign Worker");
    await tapText(t, "Juan Dela Cruz");
    expect(order["status"], "In Production");
    dynamic task = AllTasks.forOrder(order["id"]);
    expect(task["worker"], "juan@imf.com");

    //worker starts and finishes the task
    Store.signIn("juan@imf.com");
    AllTasks.selectedId = task["id"];
    await t.pumpWidget(appAt("/task"));
    await t.pumpAndSettle();
    await tapText(t, "Start Task");
    expect(task["progress"], "In Progress");
    await tapText(t, "Use Material");
    await tapText(t, "Solid Oak Board");
    await t.enterText(find.byType(TextField).at(0), "5");
    await tapText(t, "Save Stock Out");
    expect(AllMaterials.find("m3")["stock"], 55);
    await tapText(t, "Mark as Done");
    await tapText(t, "Done");
    expect(task["progress"], "Done");
    expect(order["status"], "Quality Check");

    //owner passes QC
    Store.signIn("owner@imf.com");
    await t.pumpWidget(appAt("/adminorder"));
    await t.pumpAndSettle();
    await tapText(t, "Pass QC");
    await tapText(t, "Pass & Dispatch");
    expect(order["status"], "Out for Delivery");

    //customer confirms receipt and rates
    Store.signIn("maria@gmail.com");
    await t.pumpWidget(appAt("/order"));
    await t.pumpAndSettle();
    await tapText(t, "Order Received");
    await tapText(t, "Yes, received");
    expect(order["status"], "Completed");
    int reviewsBefore = AllProducts.reviewList.length;
    await tapText(t, "Submit Review");
    expect(AllProducts.reviewList.length, reviewsBefore + (order["items"] as List).length);
    expect(order["rated"], true);
    expect(t.takeException(), isNull);
  });

  testWidgets("custom request: submit -> quote -> approve creates an order", (t) async {
    await setPhone(t);
    await t.runAsync(() => resetData("maria@gmail.com"));
    AllRequests.selectedId = "";
    await t.pumpWidget(appAt("/requestform"));
    await t.pumpAndSettle();
    List<Finder> fields = [for (int i = 0; i < 4; i++) find.byType(TextField).at(i)];
    await t.enterText(fields[0], "120 x 60 x 75 cm");
    await t.enterText(fields[2], "18000");
    await t.enterText(fields[3], "Study desk with two drawers and steel legs.");
    await tapText(t, "Submit Request");
    dynamic r = AllRequests.requestList.last;
    expect(r["status"], "Submitted");

    Store.signIn("owner@imf.com");
    AllRequests.selectedId = r["id"];
    await t.pumpWidget(appAt("/adminrequest"));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).at(0), "17500");
    await tapText(t, "Send Quotation");
    expect(r["status"], "Quoted");

    Store.signIn("maria@gmail.com");
    await t.pumpWidget(appAt("/request"));
    await t.pumpAndSettle();
    int ordersBefore = AllOrders.orderList.length;
    await tapText(t, "Approve");
    await tapText(t, "Approve");
    expect(r["status"], "Approved");
    expect(AllOrders.orderList.length, ordersBefore + 1);
    expect(AllOrders.orderList.last["type"], "Custom");
    expect(t.takeException(), isNull);
  });

  testWidgets("signup with OTP then login", (t) async {
    await setPhone(t);
    await t.runAsync(() => resetData(""));
    Store.signOut();
    await t.pumpWidget(appAt("/signup"));
    await t.pumpAndSettle();
    List<String> values = ["Ana", "Reyes", "ana.reyes@gmail.com", "09170001111", "secret123", "secret123"];
    for (int i = 0; i < values.length; i++) {
      await t.enterText(find.byType(TextField).at(i), values[i]);
    }
    await t.tap(find.byType(Checkbox));
    await tapText(t, "Sign up");
    expect(find.text("Verify your email"), findsOneWidget);
    await t.enterText(find.byType(TextField).first, AllUsers.otpCode);
    await t.pumpAndSettle();
    expect(AllUsers.find("ana.reyes@gmail.com"), isNotNull);
    expect(find.text("Sign In Account"), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
