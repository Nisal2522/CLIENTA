import 'package:flutter/foundation.dart';

import 'api.dart';
import 'models.dart';

/// In-memory client state. Loads collections through [ClientaApi] and keeps
/// local mutations (likes, notes, chat, RSVPs…) so the UI updates instantly.
class Store extends ChangeNotifier {
  Store(this.api);
  static final Store instance = Store(MockClientaApi());

  final ClientaApi api;
  final Set<String> _loaded = {};

  List<ClientaEvent> events = [];
  List<Speaker> speakers = [];
  List<NewsArticle> news = [];
  List<Person> people = [];
  List<ChatThread> threads = [];
  Map<String, List<ChatMessage>> liveChats = {};
  List<EventGroup> groups = [];
  List<Note> notes = [];
  List<ResourceDoc> resources = [];
  List<ResourceDoc> knowledge = [];
  List<AppNotification> notifications = [];
  List<Certificate> certificates = [];
  List<Poll> polls = [];

  final Set<String> registeredEvents = {'futuretech', 'asia-meeting', 'climate-citizen'};
  final Set<String> downloaded = {};
  final Set<String> submittedSurveys = {};
  final Set<String> savedSessions = {'s3', 's5'};

  bool isLoaded(List<String> keys) => keys.every(_loaded.contains);

  final Map<String, Future<void>> _inFlight = {};

  /// Loads [key] once. Calls made while it is already loading share that load.
  Future<void> ensure(String key, {bool refresh = false}) {
    if (_loaded.contains(key) && !refresh) return Future.value();
    if (!refresh && _inFlight[key] != null) return _inFlight[key]!;
    // Block body on purpose: `=> _inFlight.remove(key)` would return this very
    // future to whenComplete, which then waits on itself forever.
    final f = _load(key).whenComplete(() {
      _inFlight.remove(key);
    });
    _inFlight[key] = f;
    return f;
  }

  /// Loads [keys] in the background so their screens open without waiting.
  /// Errors are ignored here; the screen shows them if it still can't load.
  void prefetch(List<String> keys) {
    for (final k in keys) {
      ensure(k).catchError((_) {});
    }
  }

  Future<void> _load(String key) async {
    switch (key) {
      case 'events':
        events = await api.fetchEvents();
        speakers = await api.fetchSpeakers();
      case 'news':
        news = await api.fetchNews();
      case 'people':
        people = await api.fetchPeople();
      case 'chats':
        people = people.isEmpty ? await api.fetchPeople() : people;
        final fetched = await api.fetchThreads();
        // Keep conversations started locally before the list finished loading.
        threads = [...threads.where((t) => t.id.startsWith('t_')), ...fetched];
        liveChats = await api.fetchLiveChats();
      case 'groups':
        groups = await api.fetchGroups();
      case 'notes':
        notes = await api.fetchNotes();
      case 'resources':
        resources = await api.fetchResources();
      case 'knowledge':
        knowledge = await api.fetchKnowledge();
      case 'notifications':
        notifications = await api.fetchNotifications();
      case 'certificates':
        certificates = await api.fetchCertificates();
      case 'polls':
        polls = await api.fetchPolls();
      default:
        throw ArgumentError('Unknown collection $key');
    }
    _loaded.add(key);
    notifyListeners();
  }

  Future<void> refresh(List<String> keys) async {
    for (final k in keys) {
      await ensure(k, refresh: true);
    }
  }

  // ── Lookups ──
  ClientaEvent event(String id) => events.firstWhere((e) => e.id == id);
  Speaker? speaker(String id) => speakers.where((s) => s.id == id).firstOrNull;
  Person? person(String id) => people.where((p) => p.id == id).firstOrNull;
  List<Person> get organizers => people.where((p) => p.isOrganizer).toList();
  List<Person> get participants => people.where((p) => !p.isOrganizer).toList();

  int get unreadNotifications => notifications.where((n) => !n.read).length;
  int get unreadChats => threads.fold(0, (a, t) => a + t.unread);

  // ── News ──
  // ── News reactions ──
  static const newsReactionTypes = ['👍', '❤️', '👏', '💡', '😮'];
  static const _newsReactionShare = [0.45, 0.25, 0.15, 0.1, 0.05];

  /// Article id → the emoji you reacted with.
  final Map<String, String> newsReactions = {};

  String? myNewsReaction(String id) => newsReactions[id];
  bool isLiked(String id) => newsReactions.containsKey(id);
  int likes(NewsArticle a) => a.likes + (isLiked(a.id) ? 1 : 0);

  /// Per-emoji counts: the article's base count spread across reaction types, plus yours.
  Map<String, int> newsReactionCounts(NewsArticle a) {
    final counts = <String, int>{};
    var assigned = 0;
    for (var i = 1; i < newsReactionTypes.length; i++) {
      final n = (a.likes * _newsReactionShare[i]).floor();
      counts[newsReactionTypes[i]] = n;
      assigned += n;
    }
    counts[newsReactionTypes.first] = a.likes - assigned;
    final mine = newsReactions[a.id];
    if (mine != null) counts[mine] = (counts[mine] ?? 0) + 1;
    return counts;
  }

  /// Sets your reaction; picking the same one again (or null) removes it.
  void reactToNews(String id, String? emoji) {
    if (emoji == null || newsReactions[id] == emoji) {
      newsReactions.remove(id);
    } else {
      newsReactions[id] = emoji;
    }
    notifyListeners();
  }

  // ── Events ──
  bool isRegistered(String id) => registeredEvents.contains(id);
  void toggleRegistration(String id) {
    registeredEvents.contains(id) ? registeredEvents.remove(id) : registeredEvents.add(id);
    notifyListeners();
  }

  // ── Knowledge Hub ──
  final Set<String> savedDocs = {};
  final Map<String, int> _docViews = {};

  void toggleSavedDoc(String id) {
    savedDocs.contains(id) ? savedDocs.remove(id) : savedDocs.add(id);
    notifyListeners();
  }

  int docViews(ResourceDoc d) => d.views + (_docViews[d.id] ?? 0);

  void markDocViewed(ResourceDoc d) {
    _docViews[d.id] = (_docViews[d.id] ?? 0) + 1;
    notifyListeners();
  }

  void toggleSavedSession(String id) {
    savedSessions.contains(id) ? savedSessions.remove(id) : savedSessions.add(id);
    notifyListeners();
  }

  // ── Notifications ──
  void markRead(AppNotification n, [bool read = true]) {
    n.read = read;
    notifyListeners();
  }

  void markAllRead() {
    for (final n in notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  void removeNotification(AppNotification n) {
    notifications.remove(n);
    notifyListeners();
  }

  void addNotification(AppNotification n) {
    notifications.insert(0, n);
    notifyListeners();
  }

  // ── Notes ──
  void saveNote(Note note) {
    final i = notes.indexWhere((n) => n.id == note.id);
    note.updated = DateTime.now();
    if (i >= 0) {
      notes[i] = note;
    } else {
      notes.insert(0, note);
    }
    notifyListeners();
  }

  void deleteNote(Note note) {
    notes.remove(note);
    notifyListeners();
  }

  void restoreNote(Note note, int index) {
    notes.insert(index.clamp(0, notes.length), note);
    notifyListeners();
  }

  // ── Chat ──
  ChatThread threadWith(String personId) {
    final existing = threads.where((t) => !t.isGroup && t.participantIds.length == 1 && t.participantIds.first == personId).firstOrNull;
    if (existing != null) return existing;
    final p = person(personId)!;
    final t = ChatThread(id: 't_${DateTime.now().microsecondsSinceEpoch}', title: p.name, participantIds: [personId], messages: []);
    threads.insert(0, t);
    notifyListeners();
    return t;
  }

  /// Group chat with exactly [personIds] (plus you). Reuses an existing one.
  ChatThread groupWith(List<String> personIds) {
    final ids = personIds.toSet();
    final existing = threads
        .where((t) => t.isGroup && t.eventId == null && t.participantIds.length == ids.length && ids.containsAll(t.participantIds))
        .firstOrNull;
    if (existing != null) return existing;
    final names = [for (final id in ids) person(id)?.name.split(' ').first ?? ''];
    final t = ChatThread(
      id: 't_${DateTime.now().microsecondsSinceEpoch}',
      title: names.join(', '),
      participantIds: ids.toList(),
      messages: [],
      isGroup: true,
      subtitle: '${ids.length + 1} members',
    );
    threads.insert(0, t);
    notifyListeners();
    return t;
  }

  static const maxPinnedThreads = 3;
  final Set<String> pinnedThreads = {};

  bool isPinned(ChatThread t) => pinnedThreads.contains(t.id);

  /// Pins or unpins [t]. Returns false if the pin limit is reached.
  bool togglePin(ChatThread t) {
    if (!pinnedThreads.remove(t.id)) {
      if (pinnedThreads.length >= maxPinnedThreads) return false;
      pinnedThreads.add(t.id);
    }
    notifyListeners();
    return true;
  }

  /// Sets [by]'s reaction on [m]; reacting again with the same emoji removes it.
  void react(ChatMessage m, String emoji, {String by = 'me'}) {
    if (m.reactions[by] == emoji) {
      m.reactions.remove(by);
    } else {
      m.reactions[by] = emoji;
    }
    notifyListeners();
  }

  void sendMessage(List<ChatMessage> messages, ChatMessage m) {
    messages.add(m);
    notifyListeners();
  }

  void markThreadRead(ChatThread t) {
    if (t.unread == 0) return;
    t.unread = 0;
    notifyListeners();
  }

  void setMeetingStatus(MeetingInvite m, MeetingStatus s) {
    m.status = s;
    notifyListeners();
  }

  // ── Downloads / evaluations ──
  void markDownloaded(String id) {
    downloaded.add(id);
    notifyListeners();
  }

  void submitSurvey(String eventId) {
    submittedSurveys.add(eventId);
    notifyListeners();
  }

  void vote(Poll p, int index) {
    if (p.votedIndex != null) return;
    p.votedIndex = index;
    p.votes[index]++;
    notifyListeners();
  }
}
