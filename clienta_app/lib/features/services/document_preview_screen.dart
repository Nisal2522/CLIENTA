import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../common/download_sheet.dart';
import '../events/resources_screen.dart';
import '../events/section_scaffold.dart';

/// In-app document preview (rendered placeholder pages) with download.
class DocumentPreviewScreen extends StatefulWidget {
  const DocumentPreviewScreen({super.key, required this.doc});
  final ResourceDoc doc;

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  final _page = PageController(viewportFraction: 0.86);
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doc;
    final (icon, color, label) = docStyle(d.type);
    final pages = d.pages.clamp(1, 6);
    final pal = context.pal;
    return SectionScaffold(
      title: d.title,
      subtitle: '$label · ${fmtSize(d.sizeMb)} · ${d.pages} page${d.pages == 1 ? '' : 's'}',
      actions: [CircleIconBtn(icon: Icons.ios_share_rounded, size: 40, onTap: () => toast(context, 'Share link copied', icon: Icons.link_rounded))],
      body: ListenableBuilder(
        listenable: Store.instance,
        builder: (context, _) => Column(
          children: [
            Expanded(
              child: d.type == DocType.video
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CoverArt(seed: d.id, theme: ArtTheme.summit),
                                Center(
                                  child: Pressable(
                                    onTap: () => toast(context, 'Playing webinar (prototype)', icon: Icons.play_arrow_rounded),
                                    child: const IconBadge(icon: Icons.play_arrow_rounded, color: Colors.white, size: 72, circle: true),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : PageView.builder(
                      controller: _page,
                      itemCount: pages,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (_, i) => AnimatedScale(
                        scale: i == _index ? 1 : 0.92,
                        duration: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                          child: InteractiveViewer(maxScale: 3, child: _FakePage(doc: d, page: i, color: color, icon: icon)),
                        ),
                      ),
                    ),
            ),
            if (d.type != DocType.video)
              Text('Page ${_index + 1} of ${d.pages}', style: context.tt.bodySmall),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.paddingOf(context).bottom + 16),
              child: Column(
                children: [
                  Text(d.description, textAlign: TextAlign.center, style: context.tt.bodyMedium?.copyWith(color: pal.textMuted)),
                  const SizedBox(height: 14),
                  AppButton(
                    label: Store.instance.downloaded.contains(d.id) ? 'Downloaded · Open file' : 'Download $label',
                    icon: Store.instance.downloaded.contains(d.id) ? Icons.download_done_rounded : Icons.download_rounded,
                    variant: Store.instance.downloaded.contains(d.id) ? ButtonVariant.secondary : ButtonVariant.primary,
                    onPressed: () => Store.instance.downloaded.contains(d.id)
                        ? toast(context, 'Opening ${d.title}…', icon: Icons.open_in_new_rounded)
                        : simulateDownload(context, id: d.id, fileName: '${d.title}.${label.toLowerCase()}', sizeLabel: fmtSize(d.sizeMb), icon: icon, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FakePage extends StatelessWidget {
  const _FakePage({required this.doc, required this.page, required this.color, required this.icon});
  final ResourceDoc doc;
  final int page;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    Widget line(double w, {double h = 7, Color c = AppColors.lightGrey20}) => Container(
          margin: const EdgeInsets.only(bottom: 7),
          width: w,
          height: h,
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
        );
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 10))],
      ),
      child: LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ClientaLogo(size: 22),
                const SizedBox(width: 6),
                const Text('PCU', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.steel, letterSpacing: 1.5, fontSize: 11)),
                const Spacer(),
                Icon(icon, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 18),
            if (page == 0) ...[
              Text(doc.title, style: const TextStyle(color: AppColors.navy900, fontWeight: FontWeight.w800, fontSize: 18, height: 1.2)),
              const SizedBox(height: 6),
              Text(doc.category.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1)),
              const SizedBox(height: 16),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(height: 110, width: double.infinity, child: CoverArt(seed: doc.id, theme: ArtTheme.ocean))),
              const SizedBox(height: 16),
            ] else ...[
              line(w * 0.55, h: 11, c: color.withValues(alpha: 0.5)),
              const SizedBox(height: 10),
            ],
            for (var i = 0; i < (page == 0 ? 6 : 14); i++) line(w * (i % 4 == 3 ? 0.6 : 0.95)),
            const Spacer(),
            Align(alignment: Alignment.bottomRight, child: Text('${page + 1}', style: const TextStyle(color: AppColors.steel, fontSize: 10))),
          ],
        );
      }),
    );
  }
}
