import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';

/// Bottom sheet for creating a meeting invitation. Returns a [MeetingInvite].
class ScheduleMeetingSheet extends StatefulWidget {
  const ScheduleMeetingSheet({super.key, required this.withName});
  final String withName;

  @override
  State<ScheduleMeetingSheet> createState() => _ScheduleMeetingSheetState();
}

class _ScheduleMeetingSheetState extends State<ScheduleMeetingSheet> {
  final _title = TextEditingController(text: 'Catch-up');
  final _desc = TextEditingController();
  late DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 30);
  int _duration = 30;
  String _place = 'Meeting Hall';

  static const _places = ['Meeting Hall', 'Foyer Café', 'Lotus Room', 'Online (Teams)'];

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 120)));
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  void _send() {
    if (_title.text.trim().isEmpty) {
      toast(context, 'Please add a meeting title', icon: Icons.info_rounded, color: AppColors.orange);
      return;
    }
    final start = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    Navigator.pop(
      context,
      MeetingInvite(
        id: 'mt${DateTime.now().microsecondsSinceEpoch}',
        title: _title.text.trim(),
        description: _desc.text.trim().isEmpty ? 'Meeting with ${widget.withName}' : _desc.text.trim(),
        start: start,
        end: start.add(Duration(minutes: _duration)),
        location: _place,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final start = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(icon: Icons.event_available_rounded, solid: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Schedule meeting', style: context.tt.titleLarge),
                    Text('with ${widget.withName}', style: context.tt.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(controller: _title, decoration: const InputDecoration(hintText: 'Meeting title', prefixIcon: Icon(Icons.title_rounded))),
          const SizedBox(height: 10),
          TextField(controller: _desc, decoration: const InputDecoration(hintText: 'Agenda / description (optional)', prefixIcon: Icon(Icons.notes_rounded))),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _picker(context, Icons.calendar_month_rounded, 'Date', fmtDate(_date), _pickDate)),
              const SizedBox(width: 10),
              Expanded(child: _picker(context, Icons.schedule_rounded, 'Time', fmtTime12(start), _pickTime)),
            ],
          ),
          const SizedBox(height: 16),
          Text('DURATION', style: context.tt.labelSmall?.copyWith(color: context.pal.textFaint, letterSpacing: 1)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [for (final d in [15, 30, 45, 60]) _chip('$d min', _duration == d, () => setState(() => _duration = d))]),
          const SizedBox(height: 16),
          Text('LOCATION', style: context.tt.labelSmall?.copyWith(color: context.pal.textFaint, letterSpacing: 1)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final p in _places) _chip(p, _place == p, () => setState(() => _place = p))]),
          const SizedBox(height: 22),
          AppButton(label: 'Send invitation', icon: Icons.send_rounded, onPressed: _send),
        ],
      ),
    );
  }

  Widget _picker(BuildContext context, IconData icon, String label, String value, VoidCallback onTap) => Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: context.pal.surfaceAlt, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Icon(icon, color: AppColors.blue, size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: context.tt.bodySmall),
                  Text(value, style: context.tt.titleSmall),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _chip(String label, bool sel, VoidCallback onTap) {
    final pal = context.pal;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: sel ? AppColors.brandGradient : null,
          color: sel ? null : pal.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: sel ? Colors.white : pal.text)),
      ),
    );
  }
}
