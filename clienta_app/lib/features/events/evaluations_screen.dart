import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/sample_data.dart';
import '../../data/store.dart';

class EvaluationsScreen extends StatelessWidget {
  const EvaluationsScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final e = Store.instance.event(eventId);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: const Padding(padding: EdgeInsets.all(8), child: BackBtn()),
          title: Column(
            children: [
              const Text('Evaluations'),
              Text(e.title, style: context.tt.bodySmall),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: context.pal.surfaceAlt, borderRadius: BorderRadius.circular(16)),
              child: const TabBar(tabs: [
                Tab(height: 38, child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.assignment_rounded, size: 18), SizedBox(width: 6), Text('Survey')])),
                Tab(height: 38, child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.poll_rounded, size: 18), SizedBox(width: 6), Text('Polls')])),
              ]),
            ),
          ),
        ),
        body: TabBarView(children: [_Survey(eventId: eventId), const _Polls()]),
      ),
    );
  }
}

class _Survey extends StatefulWidget {
  const _Survey({required this.eventId});
  final String eventId;

  @override
  State<_Survey> createState() => _SurveyState();
}

class _SurveyState extends State<_Survey> with AutomaticKeepAliveClientMixin {
  final Map<String, Object> _answers = {};
  bool _submitting = false;

  @override
  bool get wantKeepAlive => true;

  bool _answered(SurveyQuestion q) {
    final a = _answers[q.id];
    if (a == null) return false;
    if (a is Set && a.isEmpty) return false;
    if (a is String && a.trim().isEmpty) return false;
    return true;
  }

  Future<void> _submit() async {
    final missing = SampleData.surveyQuestions.where((q) => q.required && !_answered(q)).toList();
    if (missing.isNotEmpty) {
      toast(context, 'Please answer question ${SampleData.surveyQuestions.indexOf(missing.first) + 1}', icon: Icons.info_rounded, color: AppColors.orange);
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Store.instance.submitSurvey(widget.eventId);
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final pal = context.pal;
    final qs = SampleData.surveyQuestions;
    if (Store.instance.submittedSurveys.contains(widget.eventId)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AnimatedCheck(size: 120),
              const SizedBox(height: 22),
              Text('Thank you for your feedback!', style: context.tt.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Your responses help us make future events even better.', textAlign: TextAlign.center, style: context.tt.bodyLarge?.copyWith(color: pal.textMuted)),
            ],
          ),
        ),
      );
    }
    final required = qs.where((q) => q.required).length;
    final done = qs.where((q) => q.required && _answered(q)).length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: done / required),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => LinearProgressIndicator(value: v, minHeight: 7, backgroundColor: pal.surfaceAlt),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('$done/$required', style: context.tt.labelMedium),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              FadeSlideIn(
                child: AppCard(
                  gradient: AppColors.brandGradient,
                  border: false,
                  child: const Text(
                    'Thank you for attending! Your feedback is valuable in helping us improve future events. Please take a few moments to share your thoughts.',
                    style: TextStyle(color: Colors.white, height: 1.5, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < qs.length; i++)
                FadeSlideIn(index: i + 1, child: _question(context, i, qs[i])),
              const SizedBox(height: 8),
              AppButton(label: 'Submit feedback', icon: Icons.send_rounded, loading: _submitting, onPressed: _submit),
            ],
          ),
        ),
      ],
    );
  }

  Widget _question(BuildContext context, int i, SurveyQuestion q) {
    final pal = context.pal;
    Widget body;
    switch (q.type) {
      case QuestionType.rating:
        final v = (_answers[q.id] as int?) ?? 0;
        const labels = ['', 'Very poor', 'Poor', 'Neutral', 'Good', 'Excellent'];
        body = Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var s = 1; s <= 5; s++)
                  Pressable(
                    scale: 0.8,
                    onTap: () => setState(() => _answers[q.id] = s),
                    child: AnimatedScale(
                      scale: s <= v ? 1.15 : 1,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      child: Icon(s <= v ? Icons.star_rounded : Icons.star_outline_rounded, size: 40, color: s <= v ? AppColors.blue : pal.textFaint),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: Text(labels[v], key: ValueKey(v), style: context.tt.labelMedium?.copyWith(color: AppColors.blue))),
          ],
        );
      case QuestionType.single:
        final sel = _answers[q.id] as String?;
        body = Column(
          children: [
            for (final o in q.options) _option(context, o, sel == o, false, () => setState(() => _answers[q.id] = o)),
          ],
        );
      case QuestionType.multi:
        final sel = (_answers[q.id] as Set<String>?) ?? <String>{};
        body = Column(
          children: [
            for (final o in q.options)
              _option(context, o, sel.contains(o), true, () {
                final next = {...sel};
                next.contains(o) ? next.remove(o) : next.add(o);
                setState(() => _answers[q.id] = next);
              }),
          ],
        );
      case QuestionType.text:
        body = TextField(
          maxLines: 4,
          onChanged: (v) => _answers[q.id] = v,
          decoration: const InputDecoration(hintText: 'Share your thoughts…'),
        );
    }
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _answered(q) ? AppColors.green : AppColors.blue.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: _answered(q)
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : Text('${i + 1}', style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(q.text + (q.required ? ' *' : ''), style: context.tt.titleSmall?.copyWith(fontSize: 14.5))),
            ],
          ),
          const SizedBox(height: 14),
          body,
        ],
      ),
    );
  }

  Widget _option(BuildContext context, String label, bool selected, bool multi, VoidCallback onTap) {
    final pal = context.pal;
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue.withValues(alpha: 0.12) : pal.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.blue : Colors.transparent, width: 1.4),
        ),
        child: Row(
          children: [
            Icon(
              multi
                  ? (selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded)
                  : (selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded),
              color: selected ? AppColors.blue : pal.textFaint,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: context.tt.bodyMedium?.copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500))),
          ],
        ),
      ),
    );
  }
}

class _Polls extends StatelessWidget {
  const _Polls();

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      keys: const ['polls'],
      builder: (context) {
        final polls = Store.instance.polls;
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          itemCount: polls.length,
          itemBuilder: (_, i) => FadeSlideIn(index: i, child: _PollCard(poll: polls[i])),
        );
      },
    );
  }
}

class _PollCard extends StatelessWidget {
  const _PollCard({required this.poll});
  final Poll poll;

  @override
  Widget build(BuildContext context) {
    final p = poll;
    final pal = context.pal;
    final voted = p.votedIndex != null;
    final maxVotes = p.votes.reduce((a, b) => a > b ? a : b);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TagChip(label: 'LIVE POLL', color: AppColors.red, icon: Icons.bar_chart_rounded, small: true),
              const Spacer(),
              Text(p.closesIn, style: context.tt.bodySmall),
            ],
          ),
          const SizedBox(height: 10),
          Text(p.question, style: context.tt.titleMedium),
          const SizedBox(height: 14),
          for (var i = 0; i < p.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Pressable(
                onTap: voted ? null : () => Store.instance.vote(p, i),
                scale: 0.98,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Container(height: 48, color: pal.surfaceAlt),
                      TweenAnimationBuilder<double>(
                        tween: Tween(end: voted ? p.votes[i] / p.total : 0),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, _) => FractionallySizedBox(
                          widthFactor: v,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: p.votedIndex == i || (voted && p.votes[i] == maxVotes)
                                  ? AppColors.brandGradient
                                  : LinearGradient(colors: [AppColors.blue.withValues(alpha: 0.25), AppColors.blue.withValues(alpha: 0.18)]),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 48,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              if (p.votedIndex == i) const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.check_circle_rounded, size: 18, color: Colors.white)),
                              Expanded(child: Text(p.options[i], style: context.tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: p.votedIndex == i ? Colors.white : pal.text))),
                              if (voted) Text('${(p.votes[i] * 100 / p.total).round()}%', style: context.tt.labelLarge?.copyWith(color: p.votedIndex == i ? Colors.white : pal.text)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(voted ? '${p.total} votes · Thanks for voting!' : 'Tap an option to vote · ${p.total} votes so far', style: context.tt.bodySmall),
        ],
      ),
    );
  }
}
