import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key, this.initialTab = 0});
  final int initialTab;

  static const _terms = [
    ('1. About CLIENTA', 'CLIENTA is an event management and client collaboration application provided by Peterson & Control Union (“PCU”) to its clients, partners and employees.'),
    ('2. Your account', 'You are responsible for keeping your sign-in details confidential. Client accounts are personal and may not be shared. Employee accounts are managed through your organisation’s single sign-on.'),
    ('3. Acceptable use', 'Use chat, groups and meeting features respectfully and only for legitimate business purposes. Do not upload unlawful, misleading or confidential third-party content.'),
    ('4. Event content', 'Agendas, resources, recordings and photographs are provided for your personal reference. Please do not redistribute materials marked confidential.'),
    ('5. Certificates', 'Digital certificates confirm participation or achievement as stated on the certificate. They do not constitute product or management-system certification.'),
    ('6. Changes', 'We may update these terms. Material changes will be announced in the app before they take effect.'),
  ];

  static const _privacy = [
    ('What we collect', 'Profile details you provide (name, company, job title, country, contact details), event registrations, chat messages, notes stored in your account, survey responses and basic usage data.'),
    ('Why we use it', 'To run events, connect participants, issue certificates, personalise news by country and improve our services.'),
    ('Who can see it', 'Other participants of an event may see your name, company, title and country if you enable profile visibility. Organisers can see registrations and survey results.'),
    ('Your choices', 'Control visibility, messaging and analytics in Settings → Privacy. You can download your data or request account deletion in Settings → Account.'),
    ('Retention', 'Event data is retained for 24 months after the event unless a longer period is required by law.'),
    ('Contact', 'Questions about privacy? Email privacy@example.com.'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          leading: const Padding(padding: EdgeInsets.all(8), child: BackBtn()),
          title: const Text('Terms & Privacy'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: context.pal.surfaceAlt, borderRadius: BorderRadius.circular(16)),
              child: const TabBar(tabs: [Tab(text: 'Terms of Use', height: 38), Tab(text: 'Privacy Policy', height: 38)]),
            ),
          ),
        ),
        body: TabBarView(children: [_list(context, _terms), _list(context, _privacy)]),
      ),
    );
  }

  Widget _list(BuildContext context, List<(String, String)> items) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text('Last updated: 1 November 2026', style: context.tt.bodySmall),
          const SizedBox(height: 14),
          for (var i = 0; i < items.length; i++)
            FadeSlideIn(
              index: i,
              child: AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(items[i].$1, style: context.tt.titleMedium),
                    const SizedBox(height: 8),
                    Text(items[i].$2, style: context.tt.bodyMedium?.copyWith(color: context.pal.textMuted)),
                  ],
                ),
              ),
            ),
        ],
      );
}
