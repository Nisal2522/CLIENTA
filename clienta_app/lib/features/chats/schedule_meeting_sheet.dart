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
  TimeOfDay _from = const TimeOfDay(hour: 10, minute: 30);
  TimeOfDay _to = const TimeOfDay(hour: 11, minute: 0);
  bool _online = true;
  final _place = TextEditingController();
  final _placeFocus = FocusNode();

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _place.dispose();
    _placeFocus.dispose();
    super.dispose();
  }

  void _setOnline(bool online) {
    setState(() => _online = online);
    if (!online) WidgetsBinding.instance.addPostFrameCallback((_) => _placeFocus.requestFocus());
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 120)));
    if (d != null) setState(() => _date = d);
  }

  static int _mins(TimeOfDay t) => t.hour * 60 + t.minute;

  DateTime _at(TimeOfDay t) => DateTime(_date.year, _date.month, _date.day, t.hour, t.minute);

  Future<void> _pickFrom() async {
    final t = await showTimePicker(context: context, initialTime: _from, helpText: 'Start time');
    if (t == null) return;
    setState(() {
      // Keep the same length when the start moves past the end.
      final length = _mins(_to) - _mins(_from);
      _from = t;
      if (_mins(_to) <= _mins(_from)) {
        final end = (_mins(_from) + (length > 0 ? length : 30)).clamp(0, 23 * 60 + 59);
        _to = TimeOfDay(hour: end ~/ 60, minute: end % 60);
      }
    });
  }

  Future<void> _pickTo() async {
    final t = await showTimePicker(context: context, initialTime: _to, helpText: 'End time');
    if (t == null || !mounted) return;
    if (_mins(t) <= _mins(_from)) {
      toast(context, 'End time must be after the start time', icon: Icons.info_rounded, color: AppColors.orange);
      return;
    }
    setState(() => _to = t);
  }

  void _send() {
    if (_title.text.trim().isEmpty) {
      toast(context, 'Please add a meeting title', icon: Icons.info_rounded, color: AppColors.orange);
      return;
    }
    if (!_online && _place.text.trim().isEmpty) {
      toast(context, 'Please type the meeting location', icon: Icons.info_rounded, color: AppColors.orange);
      _placeFocus.requestFocus();
      return;
    }
    if (_mins(_to) <= _mins(_from)) {
      toast(context, 'End time must be after the start time', icon: Icons.info_rounded, color: AppColors.orange);
      return;
    }
    Navigator.pop(
      context,
      MeetingInvite(
        id: 'mt${DateTime.now().microsecondsSinceEpoch}',
        title: _title.text.trim(),
        description: _desc.text.trim().isEmpty ? 'Meeting with ${widget.withName}' : _desc.text.trim(),
        start: _at(_from),
        end: _at(_to),
        location: _online ? 'Online' : _place.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final length = _mins(_to) - _mins(_from);
    final lengthText = length >= 60 ? '${length ~/ 60} h${length % 60 == 0 ? '' : ' ${length % 60} min'}' : '$length min';
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
          _picker(context, Icons.calendar_month_rounded, 'Date', fmtDate(_date), _pickDate),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _picker(context, Icons.schedule_rounded, 'From', fmtTime12(_at(_from)), _pickFrom)),
              const SizedBox(width: 10),
              Expanded(child: _picker(context, Icons.update_rounded, 'To', fmtTime12(_at(_to)), _pickTo)),
            ],
          ),
          if (length > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text('Meeting length: $lengthText', style: context.tt.bodySmall),
            ),
          const SizedBox(height: 16),
          Text('LOCATION', style: context.tt.labelSmall?.copyWith(color: context.pal.textFaint, letterSpacing: 1)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _option(Icons.videocam_rounded, 'Online', _online, () => _setOnline(true))),
              const SizedBox(width: 10),
              Expanded(child: _option(Icons.place_rounded, 'Physical', !_online, () => _setOnline(false))),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _online
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextField(
                      controller: _place,
                      focusNode: _placeFocus,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(hintText: 'Type the location (e.g. Meeting Hall, Level 2)', prefixIcon: Icon(Icons.edit_location_alt_rounded)),
                    ),
                  ),
          ),
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

  Widget _option(IconData icon, String label, bool sel, VoidCallback onTap) {
    final pal = context.pal;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 48,
        decoration: BoxDecoration(
          gradient: sel ? AppColors.brandGradient : null,
          color: sel ? null : pal.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 19, color: sel ? Colors.white : AppColors.blue),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: sel ? Colors.white : pal.text)),
          ],
        ),
      ),
    );
  }
}
