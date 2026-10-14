import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/store.dart';
import '../../glob/activity.dart';
import '../../widgets/common.dart';

Future<void> logout(BuildContext context) async {
  bool ok = await confirmDialog(context, "Sign out", "Are you sure you want to sign out?", confirm: "Sign out", danger: true);
  if (!ok || !context.mounted) return;
  AllActivity.log(AllUsers.activeEmail, "Signed out");
  Store.save();
  Store.signOut();
  Navigator.pushNamedAndRemoveUntil(context, "/landing", (route) => false);
}
