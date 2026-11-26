import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../common/download_sheet.dart';
import '../events/resources_screen.dart';
import '../events/section_scaffold.dart';
import 'document_preview_screen.dart';

class KnowledgeHubScreen extends StatefulWidget {
  const KnowledgeHubScreen({super.key});

  @override
  State<KnowledgeHubScreen> createState() => _KnowledgeHubScreenState();
}

class _KnowledgeHubScreenState extends State<KnowledgeHubScreen> {
  String _cat = 'All';
  String _query = '';
  bool _savedOnly = false;

  static const _cats = {
    'All': Icons.apps_rounded,
    'Standards': Icons.verified_rounded,
    'Guides': Icons.menu_book_rounded,
    'Templates': Icons.dashboard_customize_rounded,
    'Webinars': Icons.ondemand_video_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      keys: const ['knowledge'],
      builder: (context) {
        final store = Store.instance;
        final q = _query.toLowerCase();
        final docs = store.knowledge.where((d) {
          return (_cat == 'All' || d.category == _cat) &&
              (!_savedOnly || store.savedDocs.contains(d.id)) &&
              (q.isEmpty || '${d.title} ${d.description} ${d.author} ${d.region}'.toLowerCase().contains(q));
        }).toList()
          ..sort((a, b) => b.updated.compareTo(a.updated));

        return SectionScaffold(
          title: 'Knowledge Hub',
          subtitle: 'Standards, guides, templates & webinars',
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                  child: SearchField(hint: 'Search title, topic or author', onChanged: (v) => setState(() => _query = v)),
                ),
              ),
              // ── Category filter ──
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _cats.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final e = _cats.entries.elementAt(i);
                      final count = e.key == 'All' ? store.knowledge.length : store.knowledge.where((d) => d.category == e.key).length;
                      return _CategoryChip(icon: e.value, label: e.key, count: count, selected: _cat == e.key, onTap: () => setState(() => _cat = e.key));
                    },
                  ),
                ),
              ),
              // ── Result count + saved filter ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${docs.length} ${docs.length == 1 ? 'resource' : 'resources'}',
                          style: context.tt.titleSmall?.copyWith(color: context.pal.textMuted),
                        ),
                      ),
                      _SavedToggle(on: _savedOnly, count: store.savedDocs.length, onTap: () => setState(() => _savedOnly = !_savedOnly)),
                    ],
                  ),
                ),
              ),
              if (docs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _savedOnly
                      ? StateView.empty(icon: Icons.bookmark_border_rounded, title: 'Nothing saved yet', message: 'Tap the bookmark on a resource to keep it here.')
                      : StateView.empty(icon: Icons.search_off_rounded, title: 'Nothing found', message: 'Try another keyword or category.'),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverList.builder(
                    itemCount: docs.length,
                    itemBuilder: (_, i) => FadeSlideIn(
                      key: ValueKey('$_cat$_savedOnly${docs[i].id}'),
                      index: i,
                      child: KnowledgeCard(doc: docs[i]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.icon, required this.label, required this.count, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final fg = selected ? Colors.white : pal.text;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.brandGradient : null,
          color: selected ? null : pal.surface,
          borderRadius: BorderRadius.circular(14),
          border: selected ? null : Border.all(color: pal.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: selected ? Colors.white : AppColors.blue),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13.5)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withValues(alpha: 0.25) : pal.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$count', style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 11.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedToggle extends StatelessWidget {
  const _SavedToggle({required this.on, required this.count, required this.onTap});
  final bool on;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: on ? AppColors.blue.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: on ? AppColors.blue : pal.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(on ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, size: 17, color: AppColors.blue),
            const SizedBox(width: 5),
            Text(count > 0 ? 'Saved ($count)' : 'Saved', style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

/// Friendly name for a document type, shown on the cover badge.
String docTypeName(DocType t) => switch (t) {
      DocType.pdf => 'PDF',
      DocType.pptx => 'Slides',
      DocType.docx => 'Document',
      DocType.xlsx => 'Dataset',
      DocType.image => 'Image',
      DocType.video => 'Video',
    };

/// Rich resource card: cover image, type badge, quick actions, details and a View button.
class KnowledgeCard extends StatelessWidget {
  const KnowledgeCard({super.key, required this.doc});
  final ResourceDoc doc;

  void _open(BuildContext context) {
    Store.instance.markDocViewed(doc);
    push(context, DocumentPreviewScreen(doc: doc));
  }

  @override
  Widget build(BuildContext context) {
    final d = doc;
    final pal = context.pal;
    final store = Store.instance;
    final (icon, color, ext) = docStyle(d.type);
    final saved = store.savedDocs.contains(d.id);
    final downloaded = store.downloaded.contains(d.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => _open(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Cover ──
              SizedBox(
                height: 158,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (d.image != null)
                      Image.asset(d.image!, fit: BoxFit.cover, errorBuilder: (_, _, _) => _CoverFallback(icon: icon))
                    else
                      _CoverFallback(icon: icon),
                    // Soft shade so the badges stay readable on bright photos.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x66000000), Color(0x00000000), Color(0x00000000)],
                          stops: [0, 0.45, 1],
                        ),
                      ),
                    ),
                    Positioned(top: 12, left: 12, child: _TypeBadge(icon: icon, color: color, label: docTypeName(d.type))),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        children: [
                          _RoundAction(
                            icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: AppColors.blue,
                            tooltip: saved ? 'Remove from saved' : 'Save',
                            onTap: () {
                              store.toggleSavedDoc(d.id);
                              toast(context, saved ? 'Removed from saved' : 'Saved to your Knowledge Hub', icon: Icons.bookmark_rounded);
                            },
                          ),
                          const SizedBox(width: 8),
                          _RoundAction(
                            icon: downloaded ? Icons.download_done_rounded : Icons.download_rounded,
                            color: downloaded ? AppColors.green : AppColors.blueDeep,
                            tooltip: downloaded ? 'Downloaded' : 'Download',
                            onTap: downloaded
                                ? () => toast(context, 'Already downloaded', icon: Icons.download_done_rounded, color: AppColors.green)
                                : () => simulateDownload(context, id: d.id, fileName: '${d.title}.${ext.toLowerCase()}', sizeLabel: fmtSize(d.sizeMb), icon: icon, color: color),
                          ),
                        ],
                      ),
                    ),
                    if (d.type == DocType.video)
                      Center(
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12)],
                          ),
                          child: const Icon(Icons.play_arrow_rounded, size: 34, color: AppColors.blueDeep),
                        ),
                      ),
                  ],
                ),
              ),
              // ── Details ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.tt.titleMedium?.copyWith(color: pal.dark ? pal.text : AppColors.cuDarkBlue, fontSize: 16.5, height: 1.25)),
                    const SizedBox(height: 6),
                    Text(d.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.tt.bodyMedium?.copyWith(color: pal.textMuted, height: 1.4)),
                    const SizedBox(height: 12),
                    _Meta(icon: Icons.person_outline_rounded, text: 'Uploaded by ${d.author}'),
                    const SizedBox(height: 6),
                    _Meta(icon: Icons.visibility_outlined, text: '${_count(store.docViews(d))} views · Updated ${timeAgo(d.updated)}'),
                  ],
                ),
              ),
              // ── Footer ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Column(
                  children: [
                    Divider(height: 1, color: pal.border),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('PCU', style: context.tt.labelLarge?.copyWith(color: pal.textMuted, letterSpacing: 0.4)),
                        const Spacer(),
                        _ViewButton(onTap: () => _open(context)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _count(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k' : '$n';
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: Center(child: Icon(icon, size: 48, color: Colors.white70)),
      );
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.icon, required this.color, required this.label});
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 11, 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.color, required this.tooltip, required this.onTap});
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        scale: 0.85,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(icon, key: ValueKey(icon), size: 19, color: color),
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: pal.textFaint),
        const SizedBox(width: 5),
        Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall)),
      ],
    );
  }
}

class _ViewButton extends StatelessWidget {
  const _ViewButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.blue, width: 1.4),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.visibility_outlined, size: 17, color: AppColors.blue),
            SizedBox(width: 6),
            Text('View', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800, fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}
