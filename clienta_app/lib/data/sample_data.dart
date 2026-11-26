import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/widgets/media.dart';
import 'models.dart';

/// Realistic local sample content. Every name, company, address and figure
/// here is fictional placeholder data for the prototype.
class SampleData {
  SampleData._();

  static final DateTime _now = DateTime.now();
  static DateTime at(int day, int h, [int m = 0]) => DateTime(_now.year, _now.month, _now.day + day, h, m);
  static DateTime ago({int days = 0, int hours = 0, int minutes = 0}) =>
      _now.subtract(Duration(days: days, hours: hours, minutes: minutes));

  // Bundled portraits (from randomuser.me), so they also load on web.
  static String _p(String g, int n) => 'assets/images/people/${g}_$n.jpg';
  static List<String> _gallery(String seed, int n) =>
      List.generate(n, (i) => 'https://picsum.photos/seed/$seed$i/900/900');

  // ───────────────────────── Speakers ─────────────────────────
  static final speakers = <Speaker>[
    Speaker(id: 'sp1', name: 'Mr. John Smith', title: 'CEO', company: 'Nexora Group', photoUrl: _p('men', 32), topics: const ['Leadership', 'Innovation'],
        bio: 'John opens FutureTech Connect with a warm welcome to all attendees, setting the stage for a day of innovation and insight. He has led Nexora Group through a decade of digital transformation across 14 markets.'),
    Speaker(id: 'sp2', name: 'Dr. Anya Sharma', title: 'Lead AI Scientist', company: 'TechCorp', photoUrl: _p('women', 68), topics: const ['AI', 'Machine Learning', 'Ethics'],
        bio: 'Dr. Anya Sharma is a visionary in artificial intelligence, pioneering advancements in machine learning for enterprise decision-making. Her research on responsible AI deployment has been published in leading journals.'),
    Speaker(id: 'sp3', name: 'Mr. John Doe', title: 'Security Architect', company: 'SecureNet', photoUrl: _p('men', 46), topics: const ['Cybersecurity', 'Zero Trust'],
        bio: 'John Doe is a seasoned Security Architect with over 15 years of experience designing robust security frameworks for banks, telcos and global supply chains.'),
    Speaker(id: 'sp4', name: 'Mrs. Sarah Lee', title: 'Senior Software Engineer', company: 'DevSolutions', photoUrl: _p('women', 21), topics: const ['Cloud-native', 'DevOps'],
        bio: 'Sarah Lee is a highly skilled Senior Software Engineer with a passion for cloud-native technologies, platform engineering and developer experience.'),
    Speaker(id: 'sp5', name: 'Dr. Kavindi Rathnayake', title: 'Head of Sustainability', company: 'Green Textiles Asia', photoUrl: _p('women', 90), topics: const ['Sustainability', 'Textiles'],
        bio: 'Kavindi leads sustainability strategy for a regional textile group and advises brands on organic and recycled content certification.'),
    Speaker(id: 'sp6', name: 'Mr. Lars van Dijk', title: 'Certification Director', company: 'Peterson & Control Union', photoUrl: _p('men', 11), topics: const ['Certification', 'Organic'],
        bio: 'Lars oversees certification programmes for organic and sustainable supply chains, helping clients prepare for new standard versions.'),
  ];

  // ───────────────────────── People ─────────────────────────
  static final people = <Person>[
    Person(id: 'u1', name: 'Ravindu Silva', title: 'Associate Business Analyst', company: 'Peterson & Control Union', department: 'Business Analysis', email: 'ravindu.silva@example.com', country: 'Sri Lanka', flag: '🇱🇰', photoUrl: _p('men', 52), online: true, phone: '+94 77 555 0101', bio: 'Helping clients digitise audit and certification workflows.'),
    Person(id: 'u2', name: 'Mei Lin Chen', title: 'Supply Chain Director', company: 'Lotus Garments Ltd', department: 'Operations', email: 'meilin.chen@example.com', country: 'China', flag: '🇨🇳', photoUrl: _p('women', 33), online: true, phone: '+86 21 5550 1234', bio: 'Building transparent, certified supply chains across Asia.'),
    Person(id: 'u3', name: 'Lars Visser', title: 'Lead Auditor', company: 'Peterson & Control Union', department: 'Certification', email: 'lars.visser@example.com', country: 'Netherlands', flag: '🇳🇱', photoUrl: _p('men', 64), phone: '+31 38 555 0199', bio: 'GOTS and OCS lead auditor with 12 years in the field.'),
    Person(id: 'u4', name: 'Priya Nair', title: 'ESG Analyst', company: 'Sunrise Agro Exports', department: 'Sustainability', email: 'priya.nair@example.com', country: 'India', flag: '🇮🇳', photoUrl: _p('women', 57), online: true, phone: '+91 80 5550 7788', bio: 'Measuring and reporting impact for agri exporters.'),
    Person(id: 'u5', name: 'Kasun Jayawardena', title: 'Quality Manager', company: 'Crystal Apparel (Pvt) Ltd', department: 'Quality', email: 'kasun.j@example.com', country: 'Sri Lanka', flag: '🇱🇰', photoUrl: _p('men', 41), phone: '+94 71 555 0144'),
    Person(id: 'u6', name: 'Sofia Rossi', title: 'Brand Compliance Lead', company: 'Verde Moda', department: 'Compliance', email: 'sofia.rossi@example.com', country: 'Italy', flag: '🇮🇹', photoUrl: _p('women', 12), online: true, phone: '+39 02 5550 3321'),
    Person(id: 'u7', name: 'Hiroshi Tanaka', title: 'Procurement Manager', company: 'Kaze Textiles', department: 'Procurement', email: 'hiroshi.tanaka@example.com', country: 'Japan', flag: '🇯🇵', photoUrl: _p('men', 85), phone: '+81 3 5550 6677'),
    Person(id: 'u8', name: 'Fatima Rahman', title: 'Sustainability Officer', company: 'Delta Knit Ltd', department: 'Sustainability', email: 'fatima.rahman@example.com', country: 'Bangladesh', flag: '🇧🇩', photoUrl: _p('women', 79), online: true, phone: '+880 2 5550 9090'),
    Person(id: 'u9', name: 'Thilini Gunasekara', title: 'Client Relations Executive', company: 'Peterson & Control Union', department: 'Client Services', email: 'thilini.g@example.com', country: 'Sri Lanka', flag: '🇱🇰', photoUrl: _p('women', 26), phone: '+94 76 555 0177'),
    Person(id: 'u10', name: 'Arjun Mehta', title: 'CTO', company: 'TraceLink Labs', department: 'Technology', email: 'arjun.mehta@example.com', country: 'India', flag: '🇮🇳', photoUrl: _p('men', 15), phone: '+91 22 5550 4400'),
    // Organisers (Contact Us)
    Person(id: 'o1', name: 'Ayesha Fernando', title: 'Content Coordinator', company: 'Peterson & Control Union', department: 'Program Management', email: 'ayesha.fernando@example.com', country: 'Sri Lanka', flag: '🇱🇰', photoUrl: _p('women', 50), online: true, phone: '+94 11 555 0001', isOrganizer: true),
    Person(id: 'o2', name: 'Chamath Silva', title: 'PR Manager', company: 'Peterson & Control Union', department: 'Marketing & Communications', email: 'chamath.silva@example.com', country: 'Sri Lanka', flag: '🇱🇰', photoUrl: _p('men', 22), phone: '+94 11 555 0002', isOrganizer: true),
    Person(id: 'o3', name: 'Ruwan Perera', title: 'Registration Manager', company: 'Peterson & Control Union', department: 'Event Operations', email: 'ruwan.perera@example.com', country: 'Sri Lanka', flag: '🇱🇰', photoUrl: _p('men', 60), online: true, phone: '+94 11 555 0003', isOrganizer: true),
    Person(id: 'o4', name: 'Sanjaya Kumara', title: 'Technical Support Lead', company: 'Peterson & Control Union', department: 'IT & Technical Services', email: 'sanjaya.kumara@example.com', country: 'Sri Lanka', flag: '🇱🇰', photoUrl: _p('men', 71), phone: '+94 11 555 0004', isOrganizer: true),
  ];

  // ───────────────────────── Events ─────────────────────────
  static final events = <ClientaEvent>[
    ClientaEvent(
      id: 'futuretech',
      image: 'assets/images/events/futuretech.jpg',
      title: 'FutureTech Connect 2026',
      tagline: 'Your gateway to the cutting edge of technology',
      category: 'Technology',
      art: ArtTheme.tech,
      inviteOnly: true,
      registered: true,
      attendees: 420,
      start: at(0, 9),
      end: at(1, 16),
      venue: const Venue(
        name: 'BMICH',
        address: 'Bauddhaloka Mawatha, Colombo 07',
        city: 'Colombo',
        country: 'Sri Lanka',
        flag: '🇱🇰',
        directions: 'Enter via Gate 2 on Bauddhaloka Mawatha. Parking is available at the east car park; shuttle carts run to the main hall every 10 minutes.',
      ),
      description:
          'FutureTech Connect is your essential gateway to the cutting edge of information technology. Join us for two days of transformative insights as we explore the revolutionary impact of AI, navigate the complex landscape of cybersecurity, and dive into the power of cloud-native development.\n\nConnect with industry leaders, gain actionable knowledge, and discover the innovations shaping tomorrow’s digital world, all in one place.',
      disclaimers: const [
        'PCU only. Please carry your digital badge (QR) for entry.',
        'Sessions may be photographed and recorded for internal communications.',
        'Agenda is subject to change; live updates appear in the app.',
      ],
      sponsors: const [
        Sponsor('Saxon Renewables', 'Platinum', Color(0xFF15766A), 'Accelerating a sustainable future'),
        Sponsor('Nimbus Cloud', 'Gold', Color(0xFF1A6FC4), 'Cloud infrastructure for Asia'),
        Sponsor('Ceylon Fiber Labs', 'Gold', Color(0xFF8B5CF6), 'Next-gen textile materials'),
        Sponsor('BlueGrid Energy', 'Silver', Color(0xFFFF8A3D), 'Clean power, smart grids'),
      ],
      speakerIds: const ['sp1', 'sp2', 'sp3', 'sp4'],
      sessions: [
        Session(id: 's1', start: at(0, 9), end: at(0, 9, 30), title: 'Opening and Welcome Ceremony', description: 'Welcome address, traditional lamp lighting and an overview of the two days ahead.', speakerIds: const ['sp1'], status: SessionStatus.completed, type: 'Ceremony'),
        Session(id: 's2', start: at(0, 9, 30), end: at(0, 10, 30), title: 'Keynote: AI in Enterprise Solutions', description: 'How enterprises move from AI pilots to production: governance, ethics and measurable value.', speakerIds: const ['sp2'], status: SessionStatus.completed, type: 'Keynote'),
        Session(id: 's3', start: at(0, 10, 40), end: at(0, 11, 40), title: 'Panel: Securing the Cloud-Native Enterprise', description: 'Security leaders debate zero trust, supply-chain attacks and resilience in modern platforms.', speakerIds: const ['sp3', 'sp4'], status: SessionStatus.live, type: 'Panel', room: 'Main Hall'),
        Session(id: 's4', start: at(0, 11, 40), end: at(0, 12, 10), title: 'Networking Break', description: 'Coffee, partner booths and the innovation showcase in the foyer.', status: SessionStatus.upcoming, type: 'Break', room: 'Foyer'),
        Session(id: 's5', start: at(0, 12, 10), end: at(0, 13, 10), title: 'Technical Workshop: Building Cloud-Native', description: 'Hands-on workshop: containerising a service, CI/CD and observability from day one.', speakerIds: const ['sp4'], status: SessionStatus.upcoming, type: 'Workshop', room: 'Lotus Room'),
        Session(id: 's6', start: at(0, 13, 15), end: at(0, 14), title: 'Closing Remarks & Awards', description: 'Innovation awards and closing remarks for day one.', speakerIds: const ['sp1'], status: SessionStatus.upcoming, type: 'Ceremony'),
        Session(id: 's7', start: at(1, 9, 30), end: at(1, 10, 30), title: 'Responsible AI Roundtable', description: 'Small-group roundtable on AI ethics, bias and transparency.', speakerIds: const ['sp2'], status: SessionStatus.upcoming, type: 'Roundtable', room: 'Charles Room'),
        Session(id: 's8', start: at(1, 11), end: at(1, 12, 30), title: 'Zero Trust Masterclass', description: 'Deep dive into zero-trust architecture for distributed teams.', speakerIds: const ['sp3'], status: SessionStatus.upcoming, type: 'Masterclass', room: 'Lotus Room'),
        Session(id: 's9', start: at(1, 14), end: at(1, 16), title: 'Innovation Showcase & Farewell', description: 'Startup demos, partner showcase and farewell reception.', speakerIds: const ['sp1', 'sp4'], status: SessionStatus.upcoming, type: 'Showcase'),
      ],
      tips: const [
        EventTip('Download Event Resources', 'Access presentation slides, whitepapers and workshop materials via the Resources section. These assets remain available for you to review during and after the event.', Icons.download_rounded, AppColors.blue),
        EventTip('Share Your Experience', 'We value your feedback! Look out for our post-event survey in the Evaluations section to share your thoughts on the sessions, speakers and overall experience.', Icons.rate_review_rounded, AppColors.blue),
        EventTip('Your Digital Badge', 'Open the QR code from the home screen at registration desks and session doors. Screen brightness up helps the scanners.', Icons.qr_code_2_rounded, AppColors.blueDeep),
        EventTip('Getting Around BMICH', 'Use the Location section for the venue map. Main Hall is on the ground floor; Lotus and Charles rooms are on level 2.', Icons.map_rounded, AppColors.darkBlue80),
        EventTip('Networking Made Easy', 'Use Chats to message participants and Schedule Meeting to book 1:1 time. Accepted meetings appear in your chat.', Icons.handshake_rounded, AppColors.darkBlue80),
        EventTip('Wi-Fi & Charging', 'Network: FTC-Guest · Password on your badge. Charging lockers are next to the registration desk.', Icons.wifi_rounded, AppColors.darkGrey),
      ],
      gallery: _gallery('ftc', 18),
    ),
    ClientaEvent(
      id: 'asia-meeting',
      image: 'assets/images/events/asia_meeting.jpg',
      title: 'PCU Asia Meeting 2026',
      tagline: 'Aligning teams across Asia for the year ahead',
      category: 'Corporate',
      art: ArtTheme.summit,
      inviteOnly: true,
      registered: true,
      attendees: 180,
      start: at(5, 9),
      end: at(7, 17),
      venue: const Venue(name: 'Shanghai Tower', address: '501 Yincheng Middle Road, Pudong', city: 'Shanghai', country: 'China', flag: '🇨🇳', directions: 'Metro Line 2 to Lujiazui, Exit 6. Registration on the 2nd floor outside the Grand Ballroom.'),
      description: 'The annual Asia Meeting brings together client-facing teams and partners to share results, align on strategy and celebrate success stories from across the region.',
      disclaimers: const ['PCU only. Asia Meeting ID required at all times.', 'Dinner at Shanghai Tower requires your badge.'],
      sponsors: const [Sponsor('Lotus Garments', 'Partner', Color(0xFFDB2FA0), 'Certified sustainable apparel')],
      speakerIds: const ['sp6', 'sp5'],
      sessions: [
        Session(id: 'a1', start: at(5, 9), end: at(5, 10), title: 'Regional Leadership Welcome', description: 'Opening session with regional leadership.', speakerIds: const ['sp6'], type: 'Keynote'),
        Session(id: 'a2', start: at(5, 10, 30), end: at(5, 12), title: 'Client Success Stories', description: 'Teams present standout client journeys from the year.', speakerIds: const ['sp5'], type: 'Panel'),
        Session(id: 'a3', start: at(6, 9, 30), end: at(6, 12), title: 'Certification Roadmap 2027', description: 'Upcoming standard versions and what they mean for clients.', speakerIds: const ['sp6'], type: 'Workshop'),
      ],
      tips: const [
        EventTip('Collect Your Meeting Kit', 'Kits are available from 2:00 PM on day one outside the Grand Ballroom.', Icons.card_giftcard_rounded, AppColors.darkBlue80),
        EventTip('Travel Tips', 'Find the full guidebook in Resources. Safe travels and see you soon!', Icons.flight_takeoff_rounded, AppColors.blue),
      ],
      gallery: _gallery('asia', 9),
    ),
    ClientaEvent(
      id: 'tex360',
      image: 'assets/images/events/tex360.jpg',
      title: 'TEX360° Sustainability Summit',
      tagline: 'Climate action for apparel & textiles',
      category: 'Sustainability',
      art: ArtTheme.textile,
      attendees: 650,
      start: at(12, 8, 30),
      end: at(12, 17),
      venue: const Venue(name: 'Hilton Colombo', address: '2 Sir Chittampalam A. Gardiner Mawatha, Colombo 02', city: 'Colombo', country: 'Sri Lanka', flag: '🇱🇰', directions: 'Grand Ballroom, lobby level. Valet parking available.'),
      description: 'TEX360° convenes brands, manufacturers and certifiers to accelerate climate action across the apparel and textile value chain, from regenerative fibres to circular design.',
      disclaimers: const ['Open registration. Limited seats.'],
      sponsors: const [Sponsor('Saxon Renewables', 'Platinum', Color(0xFF15766A), 'Accelerating a sustainable future'), Sponsor('Ceylon Fiber Labs', 'Gold', Color(0xFF8B5CF6), 'Next-gen textile materials')],
      speakerIds: const ['sp5', 'sp6'],
      sessions: [
        Session(id: 't1', start: at(12, 9), end: at(12, 10), title: 'The State of Sustainable Textiles', description: 'Data-driven look at progress and gaps.', speakerIds: const ['sp5'], type: 'Keynote'),
        Session(id: 't2', start: at(12, 10, 30), end: at(12, 11, 30), title: 'Preparing for GOTS 7.0', description: 'What changes and how to prepare your sites.', speakerIds: const ['sp6'], type: 'Workshop'),
      ],
      gallery: _gallery('tex', 9),
    ),
    ClientaEvent(
      id: 'organic-forum',
      image: 'assets/images/events/organic_forum.jpg',
      title: 'Organic Integrity Forum',
      tagline: 'Trust and traceability in organic supply chains',
      category: 'Certification',
      art: ArtTheme.agri,
      attendees: 300,
      start: at(26, 9),
      end: at(27, 16),
      venue: const Venue(name: 'Hanzehof Conference Centre', address: 'Lübeckplein 12', city: 'Zwolle', country: 'Netherlands', flag: '🇳🇱', directions: '10 minutes walk from Zwolle Central Station.'),
      description: 'A two-day forum on organic integrity, fraud prevention and digital traceability with regulators, certifiers and brands.',
      sponsors: const [Sponsor('Verde Moda', 'Gold', Color(0xFF22B573), 'Organic fashion, traceable')],
      speakerIds: const ['sp6'],
      sessions: [
        Session(id: 'o1', start: at(26, 9, 30), end: at(26, 10, 30), title: 'Organic Fraud: Lessons Learned', description: 'Case studies and prevention strategies.', speakerIds: const ['sp6'], type: 'Keynote'),
      ],
      gallery: _gallery('org', 6),
    ),
    ClientaEvent(
      id: 'climate-citizen',
      image: 'assets/images/events/climate_awards.jpg',
      title: 'Climate Neutral Citizen Awards',
      tagline: 'Celebrating personal climate action',
      category: 'Sustainability',
      art: ArtTheme.ocean,
      registered: true,
      attendees: 260,
      start: at(-40, 18),
      end: at(-40, 21),
      venue: const Venue(name: 'Cinnamon Grand', address: '77 Galle Road, Colombo 03', city: 'Colombo', country: 'Sri Lanka', flag: '🇱🇰'),
      description: 'An evening recognising participants who offset their personal emissions and championed climate action in the apparel and textile industry.',
      speakerIds: const ['sp5'],
      sessions: [
        Session(id: 'c1', start: at(-40, 18), end: at(-40, 19), title: 'Awards Ceremony', description: 'Recognition of Climate Neutral Citizens.', speakerIds: const ['sp5'], status: SessionStatus.completed, type: 'Ceremony'),
      ],
      gallery: _gallery('cnc', 12),
    ),
  ];

  // ───────────────────────── News ─────────────────────────
  static final news = <NewsArticle>[
    NewsArticle(
      id: 'n1',
      image: 'assets/images/news/gots.jpg',
      title: 'GOTS Version 7.0 is now fully effective',
      summary: 'All new and renewed certifications are now assessed against GOTS 7.0, with stricter environmental and social criteria.',
      published: ago(hours: 5),
      category: 'Certification',
      scope: NewsScope.global,
      art: ArtTheme.textile,
      icon: Icons.verified_rounded,
      likes: 128,
      readMinutes: 4,
      body: const [
        'The Global Organic Textile Standard (GOTS) has confirmed that its latest version, GOTS 7.0, is now fully effective. The update enhances sustainability and transparency in the textile industry by introducing stricter environmental criteria, emphasised water and energy usage requirements, and strengthened social criteria for fair labour practices.',
        'All new and renewed certifications are now assessed against the requirements outlined in GOTS 7.0. The updated standard reaffirms GOTS’ commitment to ensuring the integrity of organic textiles and promoting sustainable practices within the industry.',
        'Stakeholders, including organic textile manufacturers, brands and consumers, are encouraged to familiarise themselves with the updated standard to align with the latest sustainability benchmarks.',
        'Your client services contact can walk you through a gap assessment and help you plan the transition for each of your sites.',
      ],
    ),
    NewsArticle(
      id: 'n2',
      image: 'assets/images/news/digital_certificates.jpg',
      title: 'Digital certificates now available in CLIENTA',
      summary: 'Event certificates can now be previewed, downloaded as PDF and verified with a credential ID, right from the app.',
      published: ago(days: 1, hours: 2),
      category: 'Product',
      scope: NewsScope.global,
      art: ArtTheme.tech,
      icon: Icons.workspace_premium_rounded,
      likes: 86,
      body: const [
        'Certificates for participation and achievement are now delivered digitally inside CLIENTA. Open any event, tap Certificate and you’ll see every certificate issued to you.',
        'Each certificate includes a unique credential ID that partners can verify. Paper certificates are no longer printed for most events. It is a small step that saves thousands of sheets each year.',
      ],
    ),
    NewsArticle(
      id: 'n3',
      image: 'assets/images/news/testing_lab.jpg',
      title: 'Sri Lanka textile testing lab expands capacity',
      summary: 'New equipment doubles turnaround capacity for fibre content and chemical testing in Colombo.',
      published: ago(days: 2),
      category: 'Company',
      scope: NewsScope.country,
      country: 'Sri Lanka',
      flag: '🇱🇰',
      art: ArtTheme.ocean,
      icon: Icons.science_rounded,
      likes: 54,
      body: const [
        'The Colombo laboratory has commissioned new analytical equipment, doubling capacity for fibre content and restricted-substance testing.',
        'Clients can expect shorter turnaround times on routine tests starting next month. Sample submission remains unchanged.',
      ],
    ),
    NewsArticle(
      id: 'n4',
      image: 'assets/images/news/deforestation.jpg',
      title: 'EU deforestation rules: what exporters should prepare',
      summary: 'A practical checklist for exporters of cocoa, coffee, rubber and other covered commodities.',
      published: ago(days: 3, hours: 4),
      category: 'Regulation',
      scope: NewsScope.global,
      art: ArtTheme.agri,
      icon: Icons.forest_rounded,
      likes: 211,
      readMinutes: 6,
      body: const [
        'Exporters placing covered commodities on the EU market need geolocation data for production plots and a due-diligence statement for every shipment.',
        'Start by mapping suppliers, collecting plot coordinates and checking land-use history. The Knowledge Hub contains a step-by-step checklist and a supplier data template.',
        'Our webinars this quarter walk through real examples from coffee and rubber supply chains.',
      ],
    ),
    NewsArticle(
      id: 'n5',
      image: 'assets/images/news/webinar.jpg',
      title: 'Organic Content Standard webinar series announced',
      summary: 'Four free sessions for brands and suppliers on OCS scope, claims and transaction certificates.',
      published: ago(days: 5),
      category: 'Events',
      scope: NewsScope.country,
      country: 'Netherlands',
      flag: '🇳🇱',
      art: ArtTheme.summit,
      icon: Icons.podcasts_rounded,
      likes: 37,
      body: const [
        'A four-part webinar series will cover OCS scope, labelling claims, transaction certificates and common audit findings.',
        'Sessions are free for clients. Register from the Events tab once the series opens.',
      ],
    ),
    NewsArticle(
      id: 'n6',
      image: 'assets/images/news/climate.jpg',
      title: 'Climate Neutral Citizen programme passes 5,000 participants',
      summary: 'Employees across the apparel sector are offsetting personal emissions through certified projects.',
      published: ago(days: 8),
      category: 'Sustainability',
      scope: NewsScope.country,
      country: 'Sri Lanka',
      flag: '🇱🇰',
      art: ArtTheme.ocean,
      icon: Icons.eco_rounded,
      likes: 302,
      body: const [
        'The Climate Neutral Citizen programme has passed 5,000 participants, each offsetting estimated personal emissions through certified emission reduction projects.',
        'Participants receive a digital Statement of Achievement inside CLIENTA.',
      ],
    ),
    NewsArticle(
      id: 'n7',
      image: 'assets/images/news/regenerative.jpg',
      title: 'Regenerative agriculture pilot launches with 1,200 farmers',
      summary: 'Soil health, biodiversity and farmer income tracked over three seasons.',
      published: ago(days: 11),
      category: 'Sustainability',
      scope: NewsScope.country,
      country: 'India',
      flag: '🇮🇳',
      art: ArtTheme.agri,
      icon: Icons.grass_rounded,
      likes: 149,
      body: const [
        'A three-season pilot will measure soil organic carbon, biodiversity and farmer income across 1,200 smallholder farms.',
        'Results will inform a verification framework for regenerative claims.',
      ],
    ),
  ];

  // ───────────────────────── Chats ─────────────────────────
  static List<ChatThread> threads() => [
        ChatThread(
          id: 't1',
          title: 'Ravindu Silva',
          participantIds: ['u1'],
          eventId: 'futuretech',
          unread: 2,
          messages: [
            ChatMessage(id: 'm1', senderId: 'u1', time: ago(minutes: 58), text: 'Hi! Great to meet you at the registration desk this morning.'),
            ChatMessage(id: 'm2', senderId: 'me', time: ago(minutes: 52), text: 'Likewise! The keynote on AI in enterprise was excellent.', reactions: {'u1': '👍'}),
            ChatMessage(id: 'm3', senderId: 'u1', time: ago(minutes: 40), text: 'AI bots, huh? I’m near the entrance trying to figure out which booth to visit first. Have you seen the full company list?'),
            ChatMessage(id: 'm4', senderId: 'me', time: ago(minutes: 35), text: 'Yes, there’s a big screen near the info desk showing the layout. The networking zone is really active too.'),
            ChatMessage(
              id: 'm5',
              senderId: 'u1',
              time: ago(minutes: 12),
              type: MessageType.meeting,
              meeting: MeetingInvite(id: 'mt1', title: 'Q&A Session', description: 'Q&A session on the new AI features', start: at(0, 16, 30), end: at(0, 17), location: 'Meeting Hall'),
            ),
            ChatMessage(id: 'm6', senderId: 'u1', time: ago(minutes: 10), text: 'Does 4:30 work for you?'),
          ],
        ),
        ChatThread(
          id: 't2',
          title: 'Mei Lin Chen',
          participantIds: ['u2'],
          eventId: 'futuretech',
          messages: [
            ChatMessage(id: 'm1', senderId: 'me', time: ago(hours: 20), text: 'Hello Mei Lin, would love to discuss traceability for your mills.'),
            ChatMessage(
              id: 'm2',
              senderId: 'me',
              time: ago(hours: 20),
              type: MessageType.meeting,
              meeting: MeetingInvite(id: 'mt2', title: 'Traceability Coffee Chat', description: 'Digital traceability for certified mills', start: at(1, 10, 45), end: at(1, 11, 15), location: 'Foyer Café', status: MeetingStatus.accepted),
            ),
            ChatMessage(id: 'm3', senderId: 'u2', time: ago(hours: 19), text: 'Accepted! See you tomorrow at the café!'),
          ],
        ),
        ChatThread(
          id: 't3',
          title: 'Sustainability Assurance Team',
          participantIds: ['u3', 'u4', 'u8'],
          isGroup: true,
          unread: 4,
          subtitle: '4 members',
          messages: [
            ChatMessage(id: 'm1', senderId: 'u3', time: ago(hours: 3), text: 'Uploaded the GOTS 7.0 gap checklist to the Knowledge Hub.'),
            ChatMessage(id: 'm2', senderId: 'u4', time: ago(hours: 2, minutes: 30), text: 'Thanks Lars! Sharing it with our sites today.'),
            ChatMessage(id: 'm3', senderId: 'u8', time: ago(hours: 2), type: MessageType.attachment, attachmentName: 'Site_Readiness_Q4.xlsx'),
            ChatMessage(id: 'm4', senderId: 'u8', time: ago(hours: 1, minutes: 50), text: 'Here’s our readiness tracker for reference.'),
            ChatMessage(
              id: 'm5',
              senderId: 'u3',
              time: ago(hours: 1, minutes: 20),
              type: MessageType.meeting,
              meeting: MeetingInvite(id: 'mt3', title: 'Audit preparation sync', description: 'Walk through the GOTS 7.0 gap checklist before site audits.', start: at(1, 15), end: at(1, 15, 45), location: 'Online (Teams)', status: MeetingStatus.accepted),
            ),
          ],
        ),
        ChatThread(
          id: 't4',
          title: 'Lars Visser',
          participantIds: ['u3'],
          messages: [
            ChatMessage(id: 'm1', senderId: 'u3', time: ago(days: 2), text: 'Your audit window is confirmed for next month.'),
            ChatMessage(id: 'm2', senderId: 'me', time: ago(days: 2), text: 'Perfect, thank you!'),
            ChatMessage(
              id: 'm3',
              senderId: 'me',
              time: ago(days: 1, hours: 3),
              type: MessageType.meeting,
              meeting: MeetingInvite(id: 'mt4', title: 'Site visit planning', description: 'Agree dates and scope for the Kandy site visit.', start: at(2, 11), end: at(2, 11, 30), location: 'Meeting Hall', status: MeetingStatus.declined),
            ),
            ChatMessage(
              id: 'm4',
              senderId: 'me',
              time: ago(hours: 5),
              type: MessageType.meeting,
              meeting: MeetingInvite(id: 'mt5', title: 'Certificate verification demo', description: 'Show partners how to verify digital certificates.', start: at(3, 10), end: at(3, 10, 30), location: 'Foyer Café'),
            ),
          ],
        ),
      ];

  static Map<String, List<ChatMessage>> liveChats() => {
        'futuretech': [
          ChatMessage(id: 'l1', senderId: 'o1', time: ago(hours: 2), type: MessageType.system, text: 'Welcome to the FutureTech Connect live chat! Be kind and keep it on topic.'),
          ChatMessage(id: 'l2', senderId: 'u1', time: ago(minutes: 48), text: 'That keynote on AI in Enterprise Solutions by Dr. Anya Sharma was truly eye-opening! Especially her points on ethical AI deployment. What did everyone else think?'),
          ChatMessage(id: 'l3', senderId: 'u2', time: ago(minutes: 44), text: 'Absolutely! I was particularly interested in her discussion on predictive analytics for business strategy. It got me thinking about our sales forecasting.'),
          ChatMessage(id: 'l4', senderId: 'u6', time: ago(minutes: 30), text: 'Anyone know if the slides will be shared?'),
          ChatMessage(id: 'l5', senderId: 'o1', time: ago(minutes: 27), text: 'Yes! Keynote slides are already in Resources 📎'),
          ChatMessage(id: 'l6', senderId: 'u10', time: ago(minutes: 6), text: 'Panel on cloud-native security is live in the Main Hall now. Packed room!'),
        ],
      };

  // ───────────────────────── Groups ─────────────────────────
  static final groups = <EventGroup>[
    EventGroup(id: 'g1', eventId: 'futuretech', number: 1, name: 'Sustainability Assurance + Environment Systems', room: 'Lotus Room, Level 2', topic: 'Assurance & environmental management', color: AppColors.blue, membersByDate: {
      at(0, 0): ['me', 'u1', 'u4'],
      at(1, 0): ['me', 'u8', 'u3'],
    }),
    EventGroup(id: 'g2', eventId: 'futuretech', number: 2, name: 'Digital Transformation Leaders', room: 'Charles Room', topic: 'AI, data and digital traceability', color: AppColors.blue, membersByDate: {
      at(0, 0): ['u10', 'u2', 'u7'],
      at(1, 0): ['u10', 'u6'],
    }),
    EventGroup(id: 'g3', eventId: 'futuretech', number: 3, name: 'Supply Chain Integrity', room: 'Main Hall, Table 12', topic: 'Fraud prevention and transparency', color: AppColors.blueDeep, membersByDate: {
      at(0, 0): ['u5', 'u6', 'u9'],
    }),
    EventGroup(id: 'g4', eventId: 'asia-meeting', number: 1, name: 'Client Experience Asia', room: 'Guanlan Room 2F', topic: 'Client journeys and service quality', color: AppColors.darkBlue80, membersByDate: {
      at(5, 0): ['me', 'u2', 'u7'],
    }),
  ];

  // ───────────────────────── Notes ─────────────────────────
  static List<Note> notes() => [
        Note(id: 'nt1', eventId: 'futuretech', title: 'SRCCS: Sustainable Regenerated Cellulosics Content Standard', body: 'Ask about scope for viscose suppliers. Follow up with Lars on timelines for the new claim labels.\n\n• Chain of custody requirements\n• Transaction certificates per shipment', updated: ago(hours: 3), color: 0),
        Note(id: 'nt2', eventId: 'futuretech', title: 'Community Waste Program (CWP)', body: 'The Community Waste Program is a collaborative initiative to reduce post-industrial textile waste. Check if our Kandy site qualifies.', updated: ago(hours: 4), color: 2),
        Note(id: 'nt3', eventId: 'asia-meeting', title: 'Questions for regional leadership', body: '1. Expansion plans for lab services\n2. Digital certificate verification for partners', updated: ago(days: 1), color: 1),
      ];

  // ───────────────────────── Resources & Knowledge ─────────────────────────
  static final resources = <ResourceDoc>[
    ResourceDoc(id: 'r1', eventId: 'futuretech', title: 'Full Event Program', type: DocType.pdf, sizeMb: 2.4, category: 'Program', description: 'Two-day program with session abstracts and room plan.', updated: ago(days: 2), pages: 18),
    ResourceDoc(id: 'r2', eventId: 'futuretech', title: 'Keynote Presentation: AI in Enterprise', type: DocType.pptx, sizeMb: 8.1, category: 'Presentations', description: 'Slides from Dr. Anya Sharma’s keynote.', updated: ago(hours: 1), pages: 42),
    ResourceDoc(id: 'r3', eventId: 'futuretech', title: 'Map of Venue', type: DocType.image, sizeMb: 1.2, category: 'Venue', description: 'BMICH floor plan with session rooms and facilities.', updated: ago(days: 3), pages: 1),
    ResourceDoc(id: 'r4', eventId: 'futuretech', title: 'Workshop Materials: Cloud-Native', type: DocType.docx, sizeMb: 0.9, category: 'Workshops', description: 'Step-by-step lab guide for the technical workshop.', updated: ago(days: 1), pages: 9),
    ResourceDoc(id: 'r5', eventId: 'futuretech', title: 'Speaker Biographies', type: DocType.pdf, sizeMb: 0.6, category: 'Program', description: 'Profiles of all speakers and panellists.', updated: ago(days: 2), pages: 6),
    ResourceDoc(id: 'r6', eventId: 'asia-meeting', title: 'Asia Meeting Travel Guidebook', type: DocType.pdf, sizeMb: 3.3, category: 'Travel', description: 'Hotels, transfers, visas and city tips.', updated: ago(days: 4), pages: 22),
  ];

  static final knowledge = <ResourceDoc>[
    ResourceDoc(id: 'k1', title: 'GOTS 7.0: What’s Changed', type: DocType.pdf, sizeMb: 1.8, category: 'Standards', description: 'Summary of key changes between GOTS 6.0 and 7.0 with a gap checklist.', updated: ago(days: 3), pages: 14, image: 'assets/images/news/gots.jpg', region: 'Global', author: 'Lars Visser', views: 1284),
    ResourceDoc(id: 'k2', title: 'Organic Content Standard: Claims Guide', type: DocType.pdf, sizeMb: 1.1, category: 'Guides', description: 'How to label OCS products correctly and avoid common mistakes.', updated: ago(days: 12), pages: 10, image: 'assets/images/onboarding_sustain.jpg', region: 'Europe', author: 'Thilini Gunasekara', views: 642),
    ResourceDoc(id: 'k3', title: 'EU Deforestation Regulation Checklist', type: DocType.docx, sizeMb: 0.4, category: 'Guides', description: 'Step-by-step due-diligence checklist for exporters.', updated: ago(days: 4), pages: 6, image: 'assets/images/news/deforestation.jpg', region: 'European Union', author: 'Ravindu Silva', views: 2105),
    ResourceDoc(id: 'k4', title: 'Supplier Data Template', type: DocType.xlsx, sizeMb: 0.2, category: 'Templates', description: 'Collect plot coordinates and supplier details in one sheet.', updated: ago(days: 4), pages: 1, image: 'assets/images/news/digital_certificates.jpg', region: 'Global', author: 'Ruwan Perera', views: 388),
    ResourceDoc(id: 'k5', title: 'Audit Preparation Handbook', type: DocType.pdf, sizeMb: 2.9, category: 'Guides', description: 'Documents, records and site readiness before your audit.', updated: ago(days: 30), pages: 28, image: 'assets/images/news/testing_lab.jpg', region: 'Sri Lanka', author: 'Lars Visser', views: 951),
    ResourceDoc(id: 'k6', title: 'Recycled Claim Standard: FAQ', type: DocType.pdf, sizeMb: 0.7, category: 'Standards', description: 'Answers to the most frequent RCS / GRS questions.', updated: ago(days: 45), pages: 8, image: 'assets/images/news/regenerative.jpg', region: 'Global', author: 'Ayesha Fernando', views: 507),
    ResourceDoc(id: 'k7', title: 'Carbon Footprint Methodology Webinar', type: DocType.video, sizeMb: 148, category: 'Webinars', description: 'Recorded webinar on product carbon footprint methods (52 min).', updated: ago(days: 20), pages: 1, image: 'assets/images/news/webinar.jpg', region: 'Asia', author: 'Chamath Silva', views: 1736),
    ResourceDoc(id: 'k8', title: 'Sustainability Report Template', type: DocType.pptx, sizeMb: 5.6, category: 'Templates', description: 'Editable slide template for annual sustainability reporting.', updated: ago(days: 60), pages: 24, image: 'assets/images/news/climate.jpg', region: 'Global', author: 'Ayesha Fernando', views: 273),
  ];

  // ───────────────────────── Notifications ─────────────────────────
  static List<AppNotification> notifications() => [
        AppNotification(id: 'nf1', title: 'Panel discussion is now LIVE', body: 'Securing the Cloud-Native Enterprise has started in the Main Hall.', time: ago(minutes: 14), type: NotificationType.agenda, eventId: 'futuretech'),
        AppNotification(id: 'nf2', title: 'New meeting invitation', body: 'Ravindu Silva invited you to “Q&A Session” at 4:30 PM.', time: ago(minutes: 12), type: NotificationType.meeting),
        AppNotification(id: 'nf3', title: 'Keynote slides available', body: 'Download “AI in Enterprise” from Resources.', time: ago(hours: 1), type: NotificationType.announcement, eventId: 'futuretech'),
        AppNotification(id: 'nf4', title: '✈️ Travel Tips & Guidebook Available!', body: 'Find helpful travel tips under the Tips tab, and access the full Guidebook in the Resources section. Safe travels and see you soon!', time: ago(hours: 6), type: NotificationType.announcement, eventId: 'asia-meeting'),
        AppNotification(id: 'nf5', title: '🎟️ Badges & Meals Reminder', body: 'Please wear your Asia Meeting ID at all times during the event, including the dinner at Shanghai Tower.', time: ago(hours: 7), type: NotificationType.announcement, eventId: 'asia-meeting', read: true),
        AppNotification(id: 'nf6', title: '🎁 Asia Meeting Kit', body: 'Collect your kit starting at 2:00 PM on day one, 2nd floor outside the Grand Ballroom.', time: ago(hours: 8), type: NotificationType.announcement, eventId: 'asia-meeting', read: true),
        AppNotification(id: 'nf7', title: 'New certificate issued', body: 'Your Climate Neutral Citizen Statement of Achievement is ready.', time: ago(days: 1), type: NotificationType.certificate, eventId: 'climate-citizen', read: true),
        AppNotification(id: 'nf8', title: 'GOTS 7.0 is now fully effective', body: 'Read what this means for your certification.', time: ago(days: 1, hours: 2), type: NotificationType.news, read: true),
      ];

  // ───────────────────────── Certificates ─────────────────────────
  static final certificates = <Certificate>[
    Certificate(id: 'c1', eventId: 'climate-citizen', title: 'Climate Neutral Citizen', kind: 'Statement of Achievement', recipient: '', company: '', issued: at(-40, 0), credentialId: 'CNC-2026-04821', art: ArtTheme.ocean,
        statement: 'has actively contributed to climate action in the apparel and textile industry by participating in the Climate Neutral Citizen programme and offsetting personal-level emissions through certified emission reductions.'),
    Certificate(id: 'c2', eventId: 'futuretech', title: 'FutureTech Connect 2026', kind: 'Certificate of Participation', recipient: '', company: '', issued: at(0, 0), credentialId: 'FTC-2026-11873', art: ArtTheme.tech,
        statement: 'has participated in FutureTech Connect 2026, held at BMICH, Colombo, including keynote sessions, panel discussions and technical workshops.'),
    Certificate(id: 'c3', eventId: 'tex360', title: 'TEX360° Summit ’25', kind: 'Certificate of Attendance', recipient: '', company: '', issued: at(-320, 0), credentialId: 'TEX-2025-00342', art: ArtTheme.textile,
        statement: 'attended the TEX360° Sustainability Summit and contributed to discussions on climate action for apparel and textiles.'),
  ];

  // ───────────────────────── Evaluations ─────────────────────────
  static const surveyQuestions = <SurveyQuestion>[
    SurveyQuestion(id: 'q1', text: 'How would you rate your overall experience at FutureTech Connect?', type: QuestionType.rating),
    SurveyQuestion(id: 'q2', text: 'Which sessions did you attend?', type: QuestionType.multi, options: ['Opening & Welcome', 'AI in Enterprise keynote', 'Cloud-Native Security panel', 'Technical workshop', 'Closing & Awards']),
    SurveyQuestion(id: 'q3', text: 'How relevant was the content to your work?', type: QuestionType.single, options: ['Very relevant', 'Relevant', 'Neutral', 'Not very relevant']),
    SurveyQuestion(id: 'q4', text: 'How would you rate the venue and organisation?', type: QuestionType.rating),
    SurveyQuestion(id: 'q5', text: 'Any suggestions to improve future events?', type: QuestionType.text, required: false),
  ];

  static List<Poll> polls() => [
        Poll(id: 'p1', question: 'Which technology will impact your industry most in 2027?', options: ['AI & machine learning', 'Cybersecurity', 'Cloud-native platforms', 'Digital traceability'], votes: [142, 64, 51, 88]),
        Poll(id: 'p2', question: 'Preferred format for future events?', options: ['In person', 'Hybrid', 'Virtual'], votes: [210, 132, 27], closesIn: 'Closes tomorrow'),
      ];

  // ───────────────────────── Support AI ─────────────────────────
  static const aiSuggestions = [
    'How do I download my certificate?',
    'Where is the venue?',
    'How do I schedule a meeting?',
    'What changed in GOTS 7.0?',
    'I forgot my password',
  ];

  static String aiAnswer(String q) {
    final s = q.toLowerCase();
    if (s.contains('certif')) {
      return 'You can find all your certificates under **Profile → My Certificates**, or inside an event under **Certificate**. Tap a certificate to preview it, then use **Download PDF**. Each certificate has a credential ID that partners can verify.';
    }
    if (s.contains('venue') || s.contains('where') || s.contains('location') || s.contains('map')) {
      return 'FutureTech Connect is at **BMICH, Bauddhaloka Mawatha, Colombo 07**. Open the event and tap **Location** for an interactive map and directions. Enter via Gate 2; parking is at the east car park.';
    }
    if (s.contains('meeting') || s.contains('schedule')) {
      return 'Open **Chats**, choose a participant and tap the **+** button next to the message field. Pick a title, date, time and place, then send. They can accept or decline, and the status updates in your chat.';
    }
    if (s.contains('gots')) {
      return 'GOTS 7.0 introduces stricter environmental criteria, stronger water and energy requirements and reinforced social criteria. All new and renewed certifications are now assessed against 7.0. See **Knowledge Hub → GOTS 7.0: What’s Changed** for a gap checklist.';
    }
    if (s.contains('password') || s.contains('login') || s.contains('sign')) {
      return 'On the sign-in screen tap **Forgot password?** and enter your email. We’ll send you a reset link. PCU employees should use **Sign in with Microsoft** instead; your password is managed by your organisation.';
    }
    if (s.contains('agenda') || s.contains('session')) {
      return 'Open the event and tap **Agenda**. Sessions show as Completed, Live or Upcoming. Tap a session for details and speakers.';
    }
    if (s.contains('wifi') || s.contains('wi-fi')) {
      return 'The guest network at FutureTech Connect is **FTC-Guest**. The password is printed on your badge.';
    }
    if (s.contains('hello') || s.contains('hi')) {
      return 'Hello! 👋 I’m the CLIENTA Support assistant. I can help with events, certificates, meetings, news and your account. What would you like to know?';
    }
    return 'Thanks for your question! I can help with events, agenda, certificates, meetings, the Knowledge Hub and your account. Could you tell me a little more? If you need a person, tap **Contact support** and our team will reply by email.';
  }
}
