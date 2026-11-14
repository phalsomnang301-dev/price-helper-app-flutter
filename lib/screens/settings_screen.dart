import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../apps/my_app.dart';
import '../providers/auth_provider.dart';
import '../providers/color_notifer_provider.dart';
import '../providers/theme_notifier_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final dark = ref.watch(themeNotifierProvider);
    final selected = ref.watch(colorNotifierProvider) % colorList.length;

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.settings, color: scheme.primary),
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ================= រូបរាង =================
          const _SectionTitle('រូបរាង'),
          const SizedBox(height: 8),
          _Section(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: false,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('ភ្លឺ'),
                      ),
                      ButtonSegment(
                        value: true,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('ងងឹត'),
                      ),
                    ],
                    selected: {dark},
                    onSelectionChanged: (s) {
                      if (s.first != dark) {
                        ref.read(themeNotifierProvider.notifier).toggleDark();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 12),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (var i = 0; i < colorList.length; i++)
                      _ColorDot(
                        color: colorList[i],
                        selected: i == selected,
                        onTap: () => ref
                            .read(colorNotifierProvider.notifier)
                            .changeIndex(i),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // ឧទាហរណ៍: មើលពណ៌ភ្លាមៗ
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ),

          // ================= គណនី =================
          const _SectionTitle('គណនី'),
          _Section(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Icon(Icons.logout, color: scheme.error),
              title: Text(
                'ចាកចេញ',
                style: TextStyle(
                  color: scheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _confirmLogout(context, ref),
            ),
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              'Price Helper · v1.0',
              style: text.bodySmall?.copyWith(color: scheme.outline),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('ចាកចេញ'),
        content: const Text('តើអ្នកចង់ចាកចេញពីគណនីមែនទេ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: const Text('បោះបង់'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(d, true),
            child: const Text('ចាកចេញ'),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(authProvider.notifier).logout();
  }
}

// ---------- ចំណងជើងផ្នែក (ពណ៌ Brand តូច) ----------
class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// ---------- ប្រអប់ផ្នែក ----------
class _Section extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Section({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Material(
        type: MaterialType.transparency, // ← បន្ថែម
        child: child,
      ),
    );
  }
}

// ---------- រង្វង់ពណ៌ ----------
class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        padding: EdgeInsets.all(selected ? 4 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 3,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: selected
              ? const Icon(Icons.check, color: Colors.white, size: 22)
              : null,
        ),
      ),
    );
  }
}
