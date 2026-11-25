import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';
import '../../data/store.dart';

/// Shows a simulated download with progress and a success state.
Future<void> simulateDownload(BuildContext context, {required String id, required String fileName, String sizeLabel = '', IconData icon = Icons.picture_as_pdf_rounded, Color color = AppColors.red}) {
  return showAppSheet(context, builder: (_) => _DownloadSheet(id: id, fileName: fileName, sizeLabel: sizeLabel, icon: icon, color: color));
}

class _DownloadSheet extends StatefulWidget {
  const _DownloadSheet({required this.id, required this.fileName, required this.sizeLabel, required this.icon, required this.color});
  final String id;
  final String fileName;
  final String sizeLabel;
  final IconData icon;
  final Color color;

  @override
  State<_DownloadSheet> createState() => _DownloadSheetState();
}

class _DownloadSheetState extends State<_DownloadSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() {
      if (!mounted) return;
      Store.instance.markDownloaded(widget.id);
      setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _done
                  ? const AnimatedCheck(key: ValueKey('ok'), size: 92)
                  : IconBadge(key: const ValueKey('f'), icon: widget.icon, color: widget.color, size: 72, solid: true),
            ),
            const SizedBox(height: 16),
            Text(_done ? 'Download complete' : 'Downloading…', style: context.tt.titleLarge),
            const SizedBox(height: 6),
            Text(widget.fileName, textAlign: TextAlign.center, style: context.tt.bodyMedium?.copyWith(color: pal.textMuted)),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _c,
              builder: (_, _) {
                final v = Curves.easeInOut.transform(_c.value);
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(value: v, minHeight: 8, backgroundColor: pal.surfaceAlt, color: _done ? AppColors.green : AppColors.blue),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('${(v * 100).round()}%', style: context.tt.labelMedium),
                        const Spacer(),
                        Text(widget.sizeLabel, style: context.tt.bodySmall),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            if (_done)
              AppButton(label: 'Done', onPressed: () => Navigator.pop(context))
            else
              AppButton(label: 'Cancel', variant: ButtonVariant.secondary, onPressed: () => Navigator.pop(context)),
            const SizedBox(height: 8),
            Text('Saved to Downloads (prototype)', style: context.tt.bodySmall),
          ],
        ),
      ),
    );
  }
}
