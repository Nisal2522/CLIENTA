import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../events/event_card.dart';
import '../news/news_article_screen.dart';
import '../services/contacts_screen.dart';
import '../services/document_preview_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _c = TextEditingController();
  String _q = '';
  String _scope = 'All';
  final _recent = ['GOTS 7.0', 'FutureTech', 'Certificate', 'Colombo'];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _set(String v) {
    _c.text = v;
    _c.selection = TextSelection.collapsed(offset: v.length);
    setState(() => _q = v);
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const BackBtn(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SearchField(
                      controller: _c,
                      autofocus: true,
                      hint: 'Search CLIENTA',
                      onChanged: (v) => setState(() => _q = v.trim()),
                      trailing: _q.isEmpty ? null : IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => _set('')),
                    ),
                  ),
                ],
              ),
            ),
            ChoiceChips(options: const ['All', 'Events', 'News', 'People', 'Knowledge'], selected: _scope, onSelected: (v) => setState(() => _scope = v)),
            Expanded(
              child: AsyncView(
                keys: const ['events', 'news', 'people', 'knowledge'],
                builder: (context) {
                  if (_q.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text('RECENT SEARCHES', style: context.tt.labelSmall?.copyWith(color: pal.textFaint, letterSpacing: 1.1)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final r in _recent)
                              ActionChip(
                                avatar: Icon(Icons.history_rounded, size: 16, color: pal.textMuted),
                                label: Text(r),
                                onPressed: () => _set(r),
                                backgroundColor: pal.surface,
                                side: BorderSide(color: pal.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        StateView(
                          icon: Icons.manage_search_rounded,
                          title: 'Search everything',
                          message: 'Find events, news articles, people and Knowledge Hub resources in one place.',
                          compact: true,
                        ),
                      ],
                    );
                  }
                  final store = Store.instance;
                  final q = _q.toLowerCase();
                  bool show(String s) => _scope == 'All' || _scope == s;
                  final List<ClientaEvent> events = show('Events') ? store.events.where((e) => '${e.title} ${e.category} ${e.venue.city} ${e.venue.country}'.toLowerCase().contains(q)).toList() : [];
                  final List<NewsArticle> news = show('News') ? store.news.where((n) => '${n.title} ${n.summary} ${n.category} ${n.country}'.toLowerCase().contains(q)).toList() : [];
                  final List<Person> people = show('People') ? store.people.where((p) => '${p.name} ${p.company} ${p.title} ${p.country}'.toLowerCase().contains(q)).toList() : [];
                  final List<ResourceDoc> docs = show('Knowledge') ? store.knowledge.where((d) => '${d.title} ${d.description} ${d.category}'.toLowerCase().contains(q)).toList() : [];
                  final total = events.length + news.length + people.length + docs.length;
                  if (total == 0) {
                    return StateView.empty(icon: Icons.search_off_rounded, title: 'No results for “$_q”', message: 'Check the spelling or try a broader term.');
                  }
                  var i = 0;
                  Widget result(IconData icon, Color color, String title, String sub, VoidCallback onTap, {Widget? leading}) => FadeSlideIn(
                        index: i++,
                        child: AppCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          onTap: onTap,
                          child: Row(
                            children: [
                              leading ?? IconBadge(icon: icon, color: color, size: 44),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall),
                                    Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: pal.textFaint),
                            ],
                          ),
                        ),
                      );
                  Widget header(String t, int n) => Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 8, left: 4),
                        child: Text('$t · $n', style: context.tt.labelLarge?.copyWith(color: AppColors.blue)),
                      );
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                    children: [
                      Text('$total results', style: context.tt.bodySmall),
                      if (events.isNotEmpty) header('Events', events.length),
                      for (final e in events) result(categoryIcon(e.category), categoryColor(e.category), e.title, '${fmtDate(e.start)} · ${e.venue.city}', () => openEvent(context, e)),
                      if (news.isNotEmpty) header('News', news.length),
                      for (final n in news) result(n.icon, AppColors.purple, n.title, '${n.category} · ${timeAgo(n.published)}', () => push(context, NewsArticleScreen(articleId: n.id))),
                      if (people.isNotEmpty) header('People', people.length),
                      for (final p in people)
                        result(Icons.person, AppColors.blue, p.name, '${p.title} · ${p.company}', () => showPersonSheet(context, p), leading: AppAvatar(name: p.name, url: p.photoUrl, size: 44, online: p.online)),
                      if (docs.isNotEmpty) header('Knowledge Hub', docs.length),
                      for (final d in docs) result(Icons.menu_book_rounded, AppColors.green, d.title, d.category, () => push(context, DocumentPreviewScreen(doc: d))),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
