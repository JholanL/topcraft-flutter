import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/requests.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common.dart';
import '../../widgets/product_image.dart';

// Custom tab: the "Designs" module of mobile-topcraft without the AI.
// The customer describes the furniture and the owner sends a quotation.
class CustomTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const CustomTab({super.key, required this.onRefresh});

  @override
  State<CustomTab> createState() => CustomTabPage();
}

class CustomTabPage extends State<CustomTab> {
  void openPage(String route) {
    Navigator.pushNamed(context, route).then((v) => widget.onRefresh());
  }

  void newRequest() {
    AllRequests.selectedId = "";
    openPage("/requestform");
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> list = AllRequests.ofCustomer(AllUsers.activeEmail);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(title: "Custom Designs", subtitle: "Made to order"),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: const DecorationImage(image: AssetImage("assets/images/header.jpg"), fit: BoxFit.cover),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withValues(alpha: 0.8), Colors.black.withValues(alpha: 0.1)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Build your dream piece", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text("Tell us the size, material and budget. We'll send you a quotation.", style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 12),
                SizedBox(
                  width: 170,
                  child: AppButton(label: "New Request", icon: Icons.add, variant: "light", small: true, onPressed: () => newRequest()),
                ),
              ],
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: SectionTitle("How it works")),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              for (List<dynamic> step in [
                [Icons.edit_note, "Describe"],
                [Icons.request_quote_outlined, "Get quote"],
                [Icons.handshake_outlined, "Approve"],
                [Icons.chair_outlined, "We build"],
              ])
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: AppColors.accentSoft, shape: BoxShape.circle),
                        child: Icon(step[0] as IconData, color: AppColors.accent, size: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(step[1] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: SectionTitle("My Requests (${list.length})")),
        if (list.isEmpty)
          const EmptyState(icon: Icons.design_services_outlined, title: "No custom requests yet", subtitle: "Tap New Request to describe the furniture you want."),
        for (dynamic r in list)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: AppCard(
              onTap: () {
                AllRequests.selectedId = r["id"];
                openPage("/request");
              },
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(14)),
                    clipBehavior: Clip.antiAlias,
                    child: r["image"] == "" ? const Icon(Icons.design_services_outlined, color: AppColors.accent) : ProductImage(r["image"], fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${r["code"]} • ${r["furnitureType"]}", style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text("${r["material"]} • ${r["dimensions"]}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                        const SizedBox(height: 4),
                        Text(
                          r["status"] == "Quoted" ? "Quote: ${Format.peso(r["quotePrice"])}" : "Budget: ${Format.peso(r["budget"])}",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: r["status"] == "Quoted" ? AppColors.accent : AppColors.text),
                        ),
                      ],
                    ),
                  ),
                  StatusPill(r["status"]),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
