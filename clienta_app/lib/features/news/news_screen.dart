import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../shell/main_shell.dart';
import 'news_article_screen.dart';
import 'news_card.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _scope = 'For you';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      keys: const ['news'],
      builder: (context) {
        final store = Store.instance;
        final app = AppState.instance;
        final region = app.regionCountry;
        final list = store.news.where((n) {
          final scopeOk = switch (_scope) {
            // PCU: organisation-wide news.
            'PCU' => n.scope == NewsScope.global,
            // For you: PCU-wide plus news for your region.
            _ => n.scope == NewsScope.global || n.country == region,
          };
          final q = _query.toLowerCase();
          return scopeOk && (q.isEmpty || '${n.title} ${n.summary}'.toLowerCase().contains(q));
        }).toList()
          ..sort((a, b) => b.published.compareTo(a.published));

        return RefreshIndicator(
          color: AppColors.blue,
          onRefresh: () => store.refresh(['news']),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 14, 20, 0),
                  child: FadeSlideIn(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('News', style: context.tt.headlineMedium),
                        const SizedBox(height: 4),
                        Text('PCU updates from around the world', style: context.tt.bodyMedium?.copyWith(color: context.pal.textMuted)),
                        const SizedBox(height: 16),
                        SearchField(hint: 'Search news', onChanged: (v) => setState(() => _query = v)),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: ChoiceChips(options: const ['For you', 'PCU'], selected: _scope, onSelected: (v) => setState(() => _scope = v)),
                ),
              ),
              if (list.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: kNavBarSpace),
                    child: StateView.empty(
                      icon: Icons.campaign_rounded,
                      title: 'No news here yet',
                      message: _query.isNotEmpty ? 'Try another search term.' : 'Check back soon for new updates.',
                      actionLabel: _scope == 'PCU' ? null : 'Show PCU news',
                      onAction: () => setState(() => _scope = 'PCU'),
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: FadeSlideIn(key: ValueKey('f${list.first.id}'), child: _FeaturedNews(article: list.first)),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, kNavBarSpace),
                  sliver: SliverList.separated(
                    itemCount: list.length - 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => FadeSlideIn(key: ValueKey('$_scope${list[i + 1].id}'), index: i, child: NewsCard(article: list[i + 1])),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FeaturedNews extends StatelessWidget {
  const _FeaturedNews({required this.article});
  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final a = article;
    return Pressable(
      onTap: () => push(context, NewsArticleScreen(articleId: a.id)),
      child: SizedBox(
        height: 260,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(tag: newsHeroTag(a.id), child: NewsImage(article: a, iconSize: 90)),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)], stops: const [0.3, 1]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const TagChip(label: 'FEATURED', color: AppColors.blueDeep, solid: true, small: true),
                        const SizedBox(width: 6),
                        ScopeLabel(article: a),
                      ],
                    ),
                    const Spacer(),
                    Text(a.category.toUpperCase(), style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800, height: 1.2)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: Text('${timeAgo(a.published)} · ${a.readMinutes} min read', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12.5))),
                        ReactionButton(article: a, light: true),
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
}
