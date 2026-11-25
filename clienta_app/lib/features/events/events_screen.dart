import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../shell/main_shell.dart';
import 'event_card.dart';

/// Events filter — by date only.
class EventFilters {
  /// Quick range: 'Any time', 'This week', 'This month', 'Next 3 months'.
  String when = 'Any time';

  /// A specific day; overrides [when] when set.
  DateTime? date;

  int get count => (date != null || when != 'Any time') ? 1 : 0;

  bool matches(ClientaEvent e) {
    final d = date;
    if (d != null) {
      final dayStart = DateTime(d.year, d.month, d.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      return e.start.isBefore(dayEnd) && e.end.isAfter(dayStart);
    }
    final days = switch (when) {
      'This week' => 7,
      'This month' => 31,
      'Next 3 months' => 92,
      _ => null,
    };
    if (days == null) return true;
    final now = DateTime.now();
    return !e.end.isBefore(now) && e.start.isBefore(now.add(Duration(days: days)));
  }

  EventFilters copy() => EventFilters()
    ..when = when
    ..date = date;
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _tab = 'Upcoming';
  String _query = '';
  EventFilters _filters = EventFilters();

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      keys: const ['events'],
      builder: (context) {
        final store = Store.instance;
        final list = store.events.where((e) {
          final tabOk = switch (_tab) {
            'My Events' => store.isRegistered(e.id),
            'All Events' => true,
            _ => !e.isPast,
          };
          final q = _query.toLowerCase();
          final queryOk = q.isEmpty || e.title.toLowerCase().contains(q) || e.venue.city.toLowerCase().contains(q) || e.category.toLowerCase().contains(q);
          return tabOk && queryOk && _filters.matches(e);
        }).toList()
          ..sort((a, b) => a.start.compareTo(b.start));

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 14, 20, 0),
                child: FadeSlideIn(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleIconBtn(
                            icon: Icons.arrow_back_ios_new_rounded,
                            size: 40,
                            onTap: () {
                              final nav = Navigator.of(context);
                              if (nav.canPop()) {
                                nav.pop();
                              } else {
                                ShellScope.maybeOf(context)?.goTo(0);
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          Text('Events', style: context.tt.headlineMedium),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Explore and register for PCU events worldwide', style: context.tt.bodyMedium?.copyWith(color: context.pal.textMuted)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: SearchField(hint: 'Search events or cities', onChanged: (v) => setState(() => _query = v))),
                          const SizedBox(width: 10),
                          CircleIconBtn(
                            icon: Icons.tune_rounded,
                            size: 52,
                            badge: _filters.count,
                            onTap: () async {
                              final result = await showAppSheet<EventFilters>(context, builder: (_) => FilterSheet(initial: _filters.copy()));
                              if (result != null) setState(() => _filters = result);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 6),
                child: ChoiceChips(options: const ['Upcoming', 'All Events', 'My Events'], selected: _tab, onSelected: (v) => setState(() => _tab = v)),
              ),
            ),
            if (list.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: kNavBarSpace),
                  child: StateView.empty(
                    icon: Icons.event_busy_rounded,
                    title: 'No events found',
                    message: _filters.count > 0 || _query.isNotEmpty ? 'Try adjusting your search or filters.' : 'There are no events in this list yet.',
                    actionLabel: _filters.count > 0 ? 'Clear filters' : null,
                    onAction: () => setState(() => _filters = EventFilters()),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, kNavBarSpace),
                sliver: SliverList.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (_, i) => FadeSlideIn(
                    key: ValueKey('$_tab-${list[i].id}'),
                    index: i,
                    child: i == 0 && _tab == 'Upcoming' && _query.isEmpty
                        ? SizedBox(height: 325, child: EventHeroCard(event: list[i], heroEnabled: false))
                        : EventListCard(event: list[i]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.initial});
  final EventFilters initial;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late EventFilters f = widget.initial;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: f.date ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
      helpText: 'Show events on',
    );
    if (picked != null) setState(() => f.date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final d = f.date;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Filter by date', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleLarge)),
              TextButton(onPressed: () => setState(() => f = EventFilters()), child: const Text('Reset')),
            ],
          ),
          _title('When'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final w in ['Any time', 'This week', 'This month', 'Next 3 months'])
                _chip(w, d == null && f.when == w, () => setState(() {
                      f.when = w;
                      f.date = null;
                    })),
            ],
          ),
          _title('Specific date'),
          Pressable(
            onTap: _pickDate,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: d != null ? AppColors.blue.withValues(alpha: 0.14) : pal.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: d != null ? AppColors.blue : Colors.transparent, width: 1.3),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, size: 20, color: d != null ? AppColors.blue : pal.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      d == null ? 'Choose a date' : '${fmtDate(d)} ${d.year}',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: d != null ? AppColors.blue : pal.text),
                    ),
                  ),
                  if (d != null)
                    GestureDetector(
                      onTap: () => setState(() => f.date = null),
                      child: const Icon(Icons.close_rounded, size: 20, color: AppColors.blue),
                    )
                  else
                    Icon(Icons.chevron_right_rounded, color: pal.textFaint),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          AppButton(label: 'Show results', onPressed: () => Navigator.pop(context, f)),
        ],
      ),
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 10),
        child: Text(t.toUpperCase(), style: context.tt.labelSmall?.copyWith(color: context.pal.textFaint, letterSpacing: 1.1)),
      );

  Widget _chip(String label, bool sel, VoidCallback onTap) {
    final pal = context.pal;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: sel ? AppColors.blue.withValues(alpha: 0.14) : pal.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? AppColors.blue : Colors.transparent, width: 1.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sel) ...[const Icon(Icons.check_rounded, size: 15, color: AppColors.blue), const SizedBox(width: 4)],
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: sel ? AppColors.blue : pal.text)),
          ],
        ),
      ),
    );
  }
}
