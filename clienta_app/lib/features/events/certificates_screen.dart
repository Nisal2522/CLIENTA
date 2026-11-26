import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/format.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../common/download_sheet.dart';
import 'section_scaffold.dart';

/// Lists certificates — for one event, or all of the user's certificates.
class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key, this.eventId});
  final String? eventId;

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      keys: const ['events', 'certificates'],
      builder: (context) {
        final store = Store.instance;
        final certs = store.certificates.where((c) => eventId == null || c.eventId == eventId).toList();
        return SectionScaffold(
          title: eventId == null ? 'My Certificates' : 'Certificate',
          subtitle: eventId == null ? '${certs.length} certificates' : store.event(eventId!).title,
          body: certs.isEmpty
              ? StateView.empty(
                  icon: Icons.workspace_premium_outlined,
                  title: 'No certificate yet',
                  message: 'Certificates are issued after the event once attendance is confirmed. We’ll notify you when yours is ready.',
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  itemCount: certs.length,
                  itemBuilder: (_, i) => FadeSlideIn(index: i, child: _CertificateTile(cert: certs[i])),
                ),
        );
      },
    );
  }
}

class _CertificateTile extends StatelessWidget {
  const _CertificateTile({required this.cert});
  final Certificate cert;

  @override
  Widget build(BuildContext context) {
    final c = cert;
    final downloaded = Store.instance.downloaded.contains(c.id);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.zero,
      onTap: () => push(context, CertificatePreviewScreen(cert: c)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SizedBox(
              height: 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CoverArt(seed: c.id, theme: c.art),
                  Center(
                    child: Hero(
                      tag: 'cert-${c.id}',
                      child: Container(
                        width: 120,
                        height: 84,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 16)]),
                        child: const Icon(Icons.workspace_premium_rounded, color: AppColors.blue, size: 40),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.kind.toUpperCase(), style: context.tt.labelSmall?.copyWith(color: AppColors.blue, letterSpacing: 0.8)),
                      const SizedBox(height: 4),
                      Text(c.title, style: context.tt.titleMedium),
                      const SizedBox(height: 4),
                      Text('Issued ${fmtDateLong(c.issued)} · ${c.credentialId}', style: context.tt.bodySmall),
                    ],
                  ),
                ),
                if (downloaded) const TagChip(label: 'Saved', icon: Icons.check_rounded, color: AppColors.green, small: true) else const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CertificatePreviewScreen extends StatelessWidget {
  const CertificatePreviewScreen({super.key, required this.cert});
  final Certificate cert;

  @override
  Widget build(BuildContext context) {
    final user = AppState.instance.user!;
    final c = cert;
    return SectionScaffold(
      title: 'Certificate Preview',
      subtitle: c.credentialId,
      actions: [
        CircleIconBtn(icon: Icons.ios_share_rounded, size: 40, onTap: () => toast(context, 'Verification link copied', icon: Icons.link_rounded)),
      ],
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Hero(
            tag: 'cert-${c.id}',
            child: InteractiveViewer(
              maxScale: 3,
              child: AspectRatio(
                aspectRatio: 0.72,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, 14))],
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.lightBlue40, width: 2), borderRadius: BorderRadius.circular(4)),
                    child: DefaultTextStyle(
                      style: const TextStyle(fontFamily: AppTheme.fontFamily, color: AppColors.cuDarkBlue, fontSize: 11, height: 1.5),
                      textAlign: TextAlign.center,
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              ClientaLogo(size: 26),
                              SizedBox(width: 6),
                              Text('PETERSON & CONTROL UNION', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 9, letterSpacing: 1.2, color: AppColors.steel)),
                              Spacer(),
                              Icon(Icons.verified_rounded, color: AppColors.blue, size: 22),
                            ],
                          ),
                          const Spacer(),
                          Text(c.kind, style: const TextStyle(color: AppColors.blue, fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(c.title, style: const TextStyle(color: AppColors.blueDeep, fontSize: 21, fontWeight: FontWeight.w800, height: 1.2)),
                          const SizedBox(height: 14),
                          const Text('This certificate is presented with honour to confirm that'),
                          const SizedBox(height: 8),
                          Text(user.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.navy900)),
                          Text(user.company, style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.steel)),
                          const SizedBox(height: 10),
                          Text(c.statement),
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Signed', style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.steel)),
                                  Text('Managing Director', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 9.5)),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Issued ${fmtDateLong(c.issued)}', style: const TextStyle(fontSize: 9.5)),
                                  Text('ID ${c.credentialId}', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(width: 8),
                              QrCodeView(data: c.credentialId, size: 44),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(child: Text('Pinch to zoom', style: context.tt.bodySmall)),
          const SizedBox(height: 18),
          AppButton(
            label: 'Download PDF',
            icon: Icons.picture_as_pdf_rounded,
            onPressed: () => simulateDownload(context, id: c.id, fileName: '${c.title.replaceAll(' ', '_')}_${c.credentialId}.pdf', sizeLabel: '480 KB'),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Add to LinkedIn profile',
            icon: Icons.add_link_rounded,
            variant: ButtonVariant.secondary,
            onPressed: () => toast(context, 'Opening LinkedIn… (prototype)', icon: Icons.open_in_new_rounded),
          ),
        ],
      ),
    );
  }
}
