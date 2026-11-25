import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import 'section_scaffold.dart';

const noteColors = [AppColors.blue, AppColors.purple, AppColors.green, AppColors.orange, AppColors.pink];

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key, this.eventId});
  final String? eventId;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _query = '';

  void _new() {
    push(
      context,
      NoteEditorScreen(
        note: Note(id: 'n${DateTime.now().microsecondsSinceEpoch}', eventId: widget.eventId ?? 'futuretech', title: '', body: '', updated: DateTime.now()),
        isNew: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      keys: const ['events', 'notes'],
      builder: (context) {
        final store = Store.instance;
        final notes = store.notes
            .where((n) => widget.eventId == null || n.eventId == widget.eventId)
            .where((n) => _query.isEmpty || '${n.title} ${n.body}'.toLowerCase().contains(_query.toLowerCase()))
            .toList();
        return SectionScaffold(
          title: 'My Notes',
          subtitle: widget.eventId == null ? 'All events' : store.event(widget.eventId!).title,
          floating: GradientFab(icon: Icons.add_rounded, label: 'New note', onTap: _new),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: SearchField(hint: 'Search notes', onChanged: (v) => setState(() => _query = v)),
              ),
              Expanded(
                child: notes.isEmpty
                    ? StateView.empty(
                        icon: Icons.edit_note_rounded,
                        title: _query.isEmpty ? 'No notes yet' : 'No matching notes',
                        message: _query.isEmpty ? 'Capture ideas, questions and follow-ups during sessions.' : 'Try a different search.',
                        actionLabel: _query.isEmpty ? 'Create a note' : null,
                        onAction: _new,
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                        itemCount: notes.length,
                        itemBuilder: (_, i) {
                          final n = notes[i];
                          return FadeSlideIn(
                            key: ValueKey(n.id),
                            index: i,
                            child: Dismissible(
                              key: ValueKey('d${n.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(22)),
                                child: const Icon(Icons.delete_rounded, color: Colors.white),
                              ),
                              onDismissed: (_) {
                                final index = store.notes.indexOf(n);
                                store.deleteNote(n);
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(SnackBar(
                                    content: const Text('Note deleted'),
                                    action: SnackBarAction(label: 'UNDO', textColor: AppColors.blue, onPressed: () => store.restoreNote(n, index)),
                                  ));
                              },
                              child: _NoteCard(note: n),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});
  final Note note;

  @override
  Widget build(BuildContext context) {
    final n = note;
    final c = noteColors[n.color % noteColors.length];
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      onTap: () => push(context, NoteEditorScreen(note: n)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, decoration: BoxDecoration(color: c, borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(n.title.isEmpty ? 'Untitled note' : n.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall?.copyWith(fontSize: 15))),
                        const SizedBox(width: 8),
                        Text(chatStamp(n.updated), style: context.tt.bodySmall),
                      ],
                    ),
                    if (n.body.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(n.body, maxLines: 3, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key, required this.note, this.isNew = false});
  final Note note;
  final bool isNew;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final _title = TextEditingController(text: widget.note.title);
  late final _body = TextEditingController(text: widget.note.body);
  late int _color = widget.note.color;
  bool _deleted = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _save() {
    if (_deleted) return;
    final empty = _title.text.trim().isEmpty && _body.text.trim().isEmpty;
    if (widget.isNew && empty) return;
    final n = widget.note
      ..title = _title.text.trim()
      ..body = _body.text.trim()
      ..color = _color;
    Store.instance.saveNote(n);
  }

  @override
  Widget build(BuildContext context) {
    final c = noteColors[_color % noteColors.length];
    final pal = context.pal;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _save();
      },
      child: SectionScaffold(
        title: widget.isNew ? 'New note' : 'Edit note',
        subtitle: 'Saved automatically',
        actions: [
          if (!widget.isNew)
            CircleIconBtn(
              icon: Icons.delete_outline_rounded,
              size: 40,
              iconColor: AppColors.red,
              onTap: () async {
                final ok = await confirmDialog(context, title: 'Delete note?', message: 'This note will be permanently removed.', confirmLabel: 'Delete', destructive: true);
                if (!ok || !context.mounted) return;
                _deleted = true;
                Store.instance.deleteNote(widget.note);
                Navigator.pop(context);
                toast(context, 'Note deleted', icon: Icons.delete_rounded, color: AppColors.red);
              },
            ),
          CircleIconBtn(
            icon: Icons.check_rounded,
            size: 40,
            iconColor: AppColors.blue,
            onTap: () => Navigator.maybePop(context),
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Row(
              children: [
                for (var i = 0; i < noteColors.length; i++)
                  Pressable(
                    onTap: () => setState(() => _color = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.only(right: 10),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: noteColors[i],
                        shape: BoxShape.circle,
                        border: Border.all(color: i == _color ? pal.text : Colors.transparent, width: 2.5),
                      ),
                      child: i == _color ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
                    ),
                  ),
                const Spacer(),
                Text(fmtDateLong(widget.note.updated), style: context.tt.bodySmall),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: c.withValues(alpha: 0.35)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _title,
                    autofocus: widget.isNew,
                    style: context.tt.titleLarge,
                    decoration: const InputDecoration(hintText: 'Title', filled: false, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none),
                  ),
                  Divider(height: 1, color: c.withValues(alpha: 0.3), indent: 16, endIndent: 16),
                  TextField(
                    controller: _body,
                    minLines: 12,
                    maxLines: null,
                    style: context.tt.bodyLarge,
                    decoration: const InputDecoration(hintText: 'Start writing…', filled: false, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
