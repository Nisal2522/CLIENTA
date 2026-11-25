import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import 'news_card.dart';

class NewsArticleScreen extends StatelessWidget {
  const NewsArticleScreen({super.key, required this.articleId});
  final String articleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AsyncView(
        keys: const ['news'],
        builder: (context) {
          final store = Store.instance;
          final a = store.news.firstWhere((n) => n.id == articleId);
          final related = store.news.where((n) => n.id != a.id && (n.category == a.category || n.scope == a.scope)).take(2).toList();
          final pal = context.pal;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                backgroundColor: pal.bg,
                automaticallyImplyLeading: false,
                leading: const Padding(padding: EdgeInsets.all(8), child: BackBtn(light: true)),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CircleIconBtn(
                      icon: Icons.ios_share_rounded,
                      size: 40,
                      color: Colors.black.withValues(alpha: 0.28),
                      iconColor: Colors.white,
                      onTap: () => toast(context, 'Article link copied', icon: Icons.link_rounded),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(tag: newsHeroTag(a.id), child: NewsImage(article: a, iconSize: 110)),
                      // Shade at the top keeps the back/share buttons readable on bright photos.
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x80000000), Color(0x00000000)],
                            stops: [0, 0.4],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -26, 0),
                  decoration: BoxDecoration(color: pal.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideIn(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [ScopeLabel(article: a, small: false), TagChip(label: a.category, color: AppColors.blue)],
                        ),
                      ),
                      const SizedBox(height: 14),
                      FadeSlideIn(index: 1, child: Text(a.title, style: context.tt.headlineMedium?.copyWith(height: 1.2))),
                      const SizedBox(height: 16),
                      FadeSlideIn(
                        index: 2,
                        child: Row(
                          children: [
                            const ClientaLogo(size: 38),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.author, style: context.tt.titleSmall),
                                  Text('${fmtDateLong(a.published)} · ${a.readMinutes} min read', style: context.tt.bodySmall),
                                ],
                              ),
                            ),
                            ReactionButton(article: a),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeSlideIn(
                        index: 3,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          decoration: BoxDecoration(
                            border: const Border(left: BorderSide(color: AppColors.blue, width: 4)),
                            color: AppColors.blue.withValues(alpha: 0.07),
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
                          ),
                          child: Text(a.summary, style: context.tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      for (var i = 0; i < a.body.length; i++)
                        FadeSlideIn(
                          index: 4 + i,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(a.body[i], style: context.tt.bodyLarge?.copyWith(fontSize: 16, height: 1.75, color: pal.text.withValues(alpha: 0.88))),
                          ),
                        ),
                      const SizedBox(height: 8),
                      ListenableBuilder(
                        listenable: store,
                        builder: (context, _) => AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store.isLiked(a.id) ? 'You and ${store.likes(a) - 1} others reacted' : 'React to this article',
                                style: context.tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              ReactionPanel(article: a),
                            ],
                          ),
                        ),
                      ),
                      if (related.isNotEmpty) ...[
                        const SizedBox(height: 26),
                        Text('Related news', style: context.tt.titleLarge),
                        const SizedBox(height: 12),
                        for (final r in related) Padding(padding: const EdgeInsets.only(bottom: 12), child: _RelatedCard(article: r)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RelatedCard extends StatelessWidget {
  const _RelatedCard({required this.article});
  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final a = article;
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).pushReplacement(AppRoute(NewsArticleScreen(articleId: a.id))),
      child: Row(
        children: [
          SizedBox(width: 70, height: 70, child: ClipRRect(borderRadius: BorderRadius.circular(14), child: NewsImage(article: a, iconSize: 28))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall),
                const SizedBox(height: 4),
                Text(timeAgo(a.published), style: context.tt.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
