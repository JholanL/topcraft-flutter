import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/format.dart';

// Small reusable widgets used by many screens.

// white rounded card
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;

  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color = AppColors.surface});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
          ),
          child: child,
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String status;
  final String? label;
  const StatusPill(this.status, {super.key, this.label});

  @override
  Widget build(BuildContext context) {
    List<Color> c = AppColors.status(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c[0], borderRadius: BorderRadius.circular(20)),
      child: Text(label ?? status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c[1])),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text)),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent)),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(color: AppColors.accentSoft, shape: BoxShape.circle),
            child: Icon(icon, size: 34, color: AppColors.accent),
          ),
          const SizedBox(height: 14),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
          if (action != null) const SizedBox(height: 16),
          ?action,
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback? onTap;
  const StatCard({super.key, required this.label, required this.value, required this.icon, required this.color, required this.bg, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
          ),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const InfoRow(this.label, this.value, {super.key, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.muted))),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: bold ? 15 : 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  const Avatar(this.text, {super.key, this.size = 44, this.color = AppColors.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
      child: Text(text, style: TextStyle(fontSize: size * 0.36, fontWeight: FontWeight.w800, color: color)),
    );
  }
}

class IconBadgeButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onTap;
  const IconBadgeButton({super.key, required this.icon, required this.onTap, this.count = 0});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Badge(
            isLabelVisible: count > 0,
            label: Text("$count"),
            backgroundColor: AppColors.danger,
            child: Icon(icon, size: 21, color: AppColors.text),
          ),
        ),
      ),
    );
  }
}

class QtyStepper extends StatelessWidget {
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const QtyStepper({super.key, required this.value, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, VoidCallback onTap) => InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 18)),
        );
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.field), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove, onMinus),
          SizedBox(width: 30, child: Text("$value", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
          btn(Icons.add, onPlus),
        ],
      ),
    );
  }
}

// header of the tab pages: big title, subtitle and action buttons
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  const PageHeader({super.key, required this.title, this.subtitle, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.text)),
              ],
            ),
          ),
          for (int i = 0; i < actions.length; i++)
            Padding(padding: const EdgeInsets.only(left: 8), child: actions[i]),
        ],
      ),
    );
  }
}

// horizontal list of filter chips
class FilterChips extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final Map<String, int>? counts;
  const FilterChips({super.key, required this.options, required this.selected, required this.onSelected, this.counts});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: options.length,
        separatorBuilder: (c, i) => const SizedBox(width: 8),
        itemBuilder: (c, i) {
          bool active = options[i] == selected;
          int? count = counts?[options[i]];
          return ChoiceChip(
            label: Text(count == null ? options[i] : "${options[i]} ($count)"),
            selected: active,
            showCheckmark: false,
            labelStyle: TextStyle(color: active ? Colors.white : AppColors.text, fontWeight: FontWeight.w600, fontSize: 13),
            onSelected: (v) => onSelected(options[i]),
          );
        },
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color color;
  final int badge;
  const MenuTile({super.key, required this.icon, required this.title, required this.onTap, this.subtitle, this.color = AppColors.accent, this.badge = 0});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: subtitle == null ? null : Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(10)),
              child: Text("$badge", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          const Icon(Icons.chevron_right, color: AppColors.soft),
        ],
      ),
    );
  }
}

// vertical timeline of an order (CustomerOrderTimeline of mobile-topcraft)
class OrderTimeline extends StatelessWidget {
  final dynamic order;
  final List<String> stages;
  const OrderTimeline({super.key, required this.order, required this.stages});

  @override
  Widget build(BuildContext context) {
    List<dynamic> timeline = order["timeline"];
    bool cancelled = order["status"] == "Cancelled";
    int current = stages.indexOf(order["status"]);
    List<Widget> rows = [];

    for (int i = 0; i < stages.length; i++) {
      dynamic entry;
      for (int j = timeline.length - 1; j >= 0; j--) {
        if (timeline[j]["status"] == stages[i]) {
          entry = timeline[j];
          break;
        }
      }
      bool done = !cancelled && i <= current;
      bool isCurrent = !cancelled && i == current;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: done ? (isCurrent ? AppColors.tabActive : AppColors.success) : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: done ? Colors.transparent : AppColors.field, width: 2),
                    ),
                    child: done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                  ),
                  if (i < stages.length - 1)
                    Expanded(
                      child: Container(width: 2, margin: const EdgeInsets.symmetric(vertical: 2), color: i < current && !cancelled ? AppColors.success : AppColors.line),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stages[i],
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: done ? AppColors.text : AppColors.soft),
                      ),
                      if (entry != null)
                        Text("${entry["note"]}\n${Format.dateTime(entry["date"])}", style: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.4)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (cancelled) {
      rows.add(
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.neutralBg, borderRadius: BorderRadius.circular(12)),
          child: Text("This order was cancelled. ${timeline.isEmpty ? "" : timeline.last["note"]}", style: const TextStyle(color: AppColors.neutral, fontWeight: FontWeight.w600)),
        ),
      );
    }
    return Column(children: rows);
  }
}

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
}

Future<bool> confirmDialog(BuildContext context, String title, String message, {String confirm = "Confirm", bool danger = false}) async {
  bool? result = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      content: Text(message, style: const TextStyle(color: AppColors.muted)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel", style: TextStyle(color: AppColors.muted))),
        TextButton(
          onPressed: () => Navigator.pop(c, true),
          child: Text(confirm, style: TextStyle(color: danger ? AppColors.danger : AppColors.accent, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return result == true;
}
