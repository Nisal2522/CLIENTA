import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import 'news_article_screen.dart';

String newsHeroTag(String id) => 'news-cover-$id';

/// News photo with the generative artwork as a fallback.
class NewsImage extends StatelessWidget {
  const NewsImage({super.key, required this.article, this.iconSize = 40});
  final NewsArticle article;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final a = article;
    final fallback = CoverArt(seed: a.id, theme: a.art, icon: a.icon, iconSize: iconSize);
    if (a.image == null) return fallback;
    return Image.asset(
      a.image!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

/// Compact reactions pill: top emojis + total. Tap opens the reaction panel.
class ReactionButton extends StatelessWidget {
  const ReactionButton({super.key, required this.article, this.light = false});
  final NewsArticle article;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final store = Store.instance;
    final pal = context.pal;
    final mine = store.myNewsReaction(article.id);
    final counts = store.newsReactionCounts(article).entries.where((e) => e.value > 0).toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = counts.take(3).map((e) => e.key).join();
    final total = store.likes(article);
    final textColor = mine != null ? AppColors.blue : (light ? Colors.white : pal.textMuted);
    return Builder(
      builder: (anchor) => Pressable(
        scale: 0.9,
        onTap: () => showNewsReactionPanel(context, anchor: anchor, article: article),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: mine != null ? AppColors.blue.withValues(alpha: light ? 0.28 : 0.12) : (light ? Colors.white.withValues(alpha: 0.18) : pal.surfaceAlt),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (top.isEmpty)
                Icon(Icons.add_reaction_outlined, size: 17, color: textColor)
              else
                Text(top, style: const TextStyle(fontSize: 13.5, fontFamily: kEmojiFontFamily, fontFamilyFallback: kEmojiFallback)),
              const SizedBox(width: 5),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (c, a) => SlideTransition(position: Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(a), child: FadeTransition(opacity: a, child: c)),
                child: Text(
                  '$total',
                  key: ValueKey(total),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating emoji panel anchored to [anchor]. Picking your current reaction removes it.
Future<void> showNewsReactionPanel(BuildContext context, {required BuildContext anchor, required NewsArticle article}) {
  final box = anchor.findRenderObject() as RenderBox;
  final rect = box.localToGlobal(Offset.zero) & box.size;
  HapticFeedback.selectionClick();
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Reactions',
    barrierColor: Colors.black.withValues(alpha: 0.2),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (ctx, _, _) {
      final size = MediaQuery.sizeOf(ctx);
      final pad = MediaQuery.paddingOf(ctx);
      const panelW = 5 * 48.0 + 12;
      const panelH = 56.0;
      final above = rect.top - panelH - 8 >= pad.top + 8;
      final top = above ? rect.top - panelH - 8 : rect.bottom + 8;
      final left = (rect.right - panelW).clamp(12.0, size.width - panelW - 12);
      return Stack(
        children: [
          Positioned(
            top: top,
            left: left,
            child: Material(
              color: ctx.pal.surface,
              elevation: 8,
              shadowColor: Colors.black38,
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: ReactionPanel(
                  article: article,
                  compact: true,
                  onPicked: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (ctx, a, _, child) => FadeTransition(
      opacity: a,
      child: ScaleTransition(scale: Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)), child: child),
    ),
  );
}

/// Row of reactions. [compact]: emojis only (popup); otherwise emoji + count chips.
class ReactionPanel extends StatelessWidget {
  const ReactionPanel({super.key, required this.article, this.compact = false, this.onPicked});
  final NewsArticle article;
  final bool compact;
  final VoidCallback? onPicked;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Store.instance,
      builder: (context, _) {
        final store = Store.instance;
        final pal = context.pal;
        final mine = store.myNewsReaction(article.id);
        final counts = store.newsReactionCounts(article);
        void pick(String e) {
          HapticFeedback.lightImpact();
          store.reactToNews(article.id, e);
          onPicked?.call();
        }

        if (compact) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final e in Store.newsReactionTypes)
                Pressable(
                  scale: 0.8,
                  onTap: () => pick(e),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: mine == e ? AppColors.blue.withValues(alpha: 0.14) : null),
                    child: Text(e, style: const TextStyle(fontSize: 27, fontFamily: kEmojiFontFamily, fontFamilyFallback: kEmojiFallback)),
                  ),
                ),
            ],
          );
        }

        return Row(
          children: [
            for (final e in Store.newsReactionTypes)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Pressable(
                    scale: 0.9,
                    onTap: () => pick(e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: mine == e ? AppColors.blue.withValues(alpha: 0.14) : pal.surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: mine == e ? AppColors.blue : Colors.transparent, width: 1.3),
                      ),
                      child: Column(
                        children: [
                          AnimatedScale(
                            scale: mine == e ? 1.18 : 1,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            child: Text(e, style: const TextStyle(fontSize: 24, fontFamily: kEmojiFontFamily, fontFamilyFallback: kEmojiFallback)),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${counts[e] ?? 0}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: mine == e ? AppColors.blue : pal.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class ScopeLabel extends StatelessWidget {
  const ScopeLabel({super.key, required this.article, this.small = true});
  final NewsArticle article;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final global = article.scope == NewsScope.global;
    return TagChip(
      label: global ? '🌍 Global' : '${article.flag} ${article.country}',
      color: global ? AppColors.blue : AppColors.blueDeep,
      small: small,
    );
  }
}

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.article});
  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final a = article;
    final pal = context.pal;
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => push(context, NewsArticleScreen(articleId: a.id)),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            height: 112,
            child: Hero(
              tag: newsHeroTag(a.id),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: NewsImage(article: a),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ScopeLabel(article: a),
                    const SizedBox(width: 6),
                    Flexible(child: Text(a.category, overflow: TextOverflow.ellipsis, style: context.tt.labelSmall?.copyWith(color: pal.textFaint))),
                  ],
                ),
                const SizedBox(height: 7),
                Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall?.copyWith(fontSize: 14.5, height: 1.3)),
                const SizedBox(height: 4),
                Text(a.summary, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(timeAgo(a.published), style: context.tt.bodySmall?.copyWith(color: pal.textFaint)),
                    const Spacer(),
                    ReactionButton(article: a),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
