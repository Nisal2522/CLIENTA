import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';
import '../../data/store.dart';
import '../events/resources_screen.dart';
import '../events/section_scaffold.dart';

class KnowledgeHubScreen extends StatefulWidget {
  const KnowledgeHubScreen({super.key});

  @override
  State<KnowledgeHubScreen> createState() => _KnowledgeHubScreenState();
}

class _KnowledgeHubScreenState extends State<KnowledgeHubScreen> {
  String _cat = 'All';
  String _query = '';

  static const _cats = {
    'Standards': (Icons.verified_rounded, AppColors.blue),
    'Guides': (Icons.menu_book_rounded, AppColors.blueDeep),
    'Templates': (Icons.dashboard_customize_rounded, AppColors.darkBlue80),
    'Webinars': (Icons.ondemand_video_rounded, AppColors.steel),
  };

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      keys: const ['knowledge'],
      builder: (context) {
        final docs = Store.instance.knowledge.where((d) {
          final q = _query.toLowerCase();
          return (_cat == 'All' || d.category == _cat) && (q.isEmpty || '${d.title} ${d.description}'.toLowerCase().contains(q));
        }).toList();
        return SectionScaffold(
          title: 'Knowledge Hub',
          subtitle: 'Standards, guides, templates & webinars',
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                  child: SearchField(hint: 'Search the Knowledge Hub', onChanged: (v) => setState(() => _query = v)),
                ),
              ),
              if (_query.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.9,
                      children: [
                        for (final (i, e) in _cats.entries.indexed)
                          FadeSlideIn(
                            index: i,
                            child: AppCard(
                              padding: const EdgeInsets.all(12),
                              color: _cat == e.key ? e.value.$2.withValues(alpha: 0.14) : null,
                              onTap: () => setState(() => _cat = _cat == e.key ? 'All' : e.key),
                              child: Row(
                                children: [
                                  IconBadge(icon: e.value.$1, color: e.value.$2, size: 40, solid: true),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(e.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall),
                                        Text('${Store.instance.knowledge.where((d) => d.category == e.key).length} items', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: _cat == 'All' ? 'All resources' : _cat,
                  action: _cat == 'All' ? null : 'Show all',
                  onAction: () => setState(() => _cat = 'All'),
                  padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
                ),
              ),
              if (docs.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: StateView.empty(icon: Icons.search_off_rounded, title: 'Nothing found', message: 'Try another keyword or category.'))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverList.builder(
                    itemCount: docs.length,
                    itemBuilder: (_, i) => FadeSlideIn(key: ValueKey('$_cat${docs[i].id}'), index: i, child: DocTile(doc: docs[i])),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
