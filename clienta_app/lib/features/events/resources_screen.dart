import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../common/download_sheet.dart';
import '../services/document_preview_screen.dart';
import 'section_scaffold.dart';

(IconData, Color, String) docStyle(DocType t) => switch (t) {
      DocType.pdf => (Icons.picture_as_pdf_rounded, AppColors.blueDeep, 'PDF'),
      DocType.pptx => (Icons.slideshow_rounded, AppColors.darkBlue80, 'PPTX'),
      DocType.docx => (Icons.description_rounded, AppColors.blue, 'DOCX'),
      DocType.xlsx => (Icons.table_chart_rounded, AppColors.darkGrey, 'XLSX'),
      DocType.image => (Icons.image_rounded, AppColors.steel, 'IMAGE'),
      DocType.video => (Icons.play_circle_fill_rounded, AppColors.blue, 'VIDEO'),
    };

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      keys: const ['events', 'resources'],
      builder: (context) {
        final store = Store.instance;
        final docs = store.resources.where((r) => r.eventId == eventId).toList();
        return SectionScaffold(
          title: 'Resources',
          subtitle: store.event(eventId).title,
          body: docs.isEmpty
              ? StateView.empty(icon: Icons.folder_open_rounded, title: 'No resources yet', message: 'Programs, slides and venue maps will be shared here.')
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  itemCount: docs.length,
                  itemBuilder: (_, i) => FadeSlideIn(index: i, child: DocTile(doc: docs[i])),
                ),
        );
      },
    );
  }
}

class DocTile extends StatelessWidget {
  const DocTile({super.key, required this.doc});
  final ResourceDoc doc;

  @override
  Widget build(BuildContext context) {
    final d = doc;
    final (icon, color, label) = docStyle(d.type);
    final downloaded = Store.instance.downloaded.contains(d.id);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      onTap: () => push(context, DocumentPreviewScreen(doc: d)),
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, size: 50),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    TagChip(label: label, color: color, small: true),
                    const SizedBox(width: 6),
                    Flexible(child: Text('${fmtSize(d.sizeMb)} · ${timeAgo(d.updated)}', overflow: TextOverflow.ellipsis, style: context.tt.bodySmall)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: downloaded
                ? const Icon(Icons.download_done_rounded, key: ValueKey('d'), color: AppColors.green)
                : IconButton(
                    key: const ValueKey('n'),
                    icon: const Icon(Icons.download_rounded, color: AppColors.blue),
                    onPressed: () => simulateDownload(context, id: d.id, fileName: '${d.title}.${label.toLowerCase()}', sizeLabel: fmtSize(d.sizeMb), icon: icon, color: color),
                  ),
          ),
        ],
      ),
    );
  }
}
