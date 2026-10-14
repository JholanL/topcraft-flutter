import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glob/store.dart';
import 'theme/app_theme.dart';

import 'screens/auth/splash.dart';
import 'screens/auth/landing.dart';
import 'screens/auth/login.dart';
import 'screens/auth/signup.dart';
import 'screens/auth/otp.dart';
import 'screens/auth/forgotpassword.dart';
import 'screens/auth/resetpassword.dart';

import 'screens/shared/profile.dart';
import 'screens/shared/changepassword.dart';
import 'screens/shared/notifications.dart';

import 'screens/customer/customershell.dart';
import 'screens/customer/productdetail.dart';
import 'screens/customer/cart.dart';
import 'screens/customer/checkout.dart';
import 'screens/customer/orderdetail.dart';
import 'screens/customer/requestform.dart';
import 'screens/customer/requestdetail.dart';
import 'screens/customer/addresses.dart';
import 'screens/customer/addressform.dart';

import 'screens/admin/adminshell.dart';
import 'screens/admin/adminorder.dart';
import 'screens/admin/productform.dart';
import 'screens/admin/materialform.dart';
import 'screens/admin/stocklogs.dart';
import 'screens/admin/adminrequests.dart';
import 'screens/admin/adminrequest.dart';
import 'screens/admin/accounts.dart';
import 'screens/admin/accountform.dart';
import 'screens/admin/customers.dart';
import 'screens/admin/reports.dart';

import 'screens/worker/workershell.dart';
import 'screens/worker/taskdetail.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //load the saved data before the app starts (the native splash stays visible)
  await Store.load();
  runApp(TopCraftApp());
}

// every page of the app (named routes)
final Map<String, WidgetBuilder> appRoutes = {
  //auth flow
  "/landing": (context) => LandingState(),
  "/login": (context) => LoginState(),
  "/signup": (context) => SignupState(),
  "/otp": (context) => OtpState(),
  "/forgot": (context) => ForgotPasswordState(),
  "/reset": (context) => ResetPasswordState(),

  //shared pages
  "/profile": (context) => ProfileState(),
  "/changepassword": (context) => ChangePasswordState(),
  "/notifications": (context) => NotificationsState(),

  //customer (client flow)
  "/customer": (context) => CustomerShellState(),
  "/product": (context) => ProductDetailState(),
  "/cart": (context) => CartState(),
  "/checkout": (context) => CheckoutState(),
  "/order": (context) => OrderDetailState(),
  "/requestform": (context) => RequestFormState(),
  "/request": (context) => RequestDetailState(),
  "/addresses": (context) => AddressesState(),
  "/addressform": (context) => AddressFormState(),

  //owner (admin flow)
  "/admin": (context) => AdminShellState(),
  "/adminorder": (context) => AdminOrderState(),
  "/productform": (context) => ProductFormState(),
  "/materialform": (context) => MaterialFormState(),
  "/stocklogs": (context) => StockLogsState(),
  "/adminrequests": (context) => AdminRequestsState(),
  "/adminrequest": (context) => AdminRequestState(),
  "/accounts": (context) => AccountsState(),
  "/accountform": (context) => AccountFormState(),
  "/customers": (context) => CustomersState(),
  "/reports": (context) => ReportsState(),

  //worker flow
  "/worker": (context) => WorkerShellState(),
  "/task": (context) => TaskDetailState(),
};

class TopCraftApp extends StatelessWidget {
  const TopCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Industrial Manila Furniture",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      routes: appRoutes,
      home: SplashState(),
    );
  }
}
