import '../core/app_state.dart';
import 'models.dart';
import 'sample_data.dart';

class OfflineException implements Exception {
  const OfflineException();
  @override
  String toString() => 'No internet connection';
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Contract for the CLIENTA backend. The prototype uses [MockClientaApi];
/// a real HTTP implementation can be dropped in without touching the UI.
abstract class ClientaApi {
  Future<List<ClientaEvent>> fetchEvents();
  Future<List<Speaker>> fetchSpeakers();
  Future<List<NewsArticle>> fetchNews();
  Future<List<Person>> fetchPeople();
  Future<List<ChatThread>> fetchThreads();
  Future<Map<String, List<ChatMessage>>> fetchLiveChats();
  Future<List<EventGroup>> fetchGroups();
  Future<List<Note>> fetchNotes();
  Future<List<ResourceDoc>> fetchResources();
  Future<List<ResourceDoc>> fetchKnowledge();
  Future<List<AppNotification>> fetchNotifications();
  Future<List<Certificate>> fetchCertificates();
  Future<List<Poll>> fetchPolls();
  Future<String> askSupportAi(String question);
}

class MockClientaApi implements ClientaApi {
  Future<T> _respond<T>(T Function() data, {int ms = 650}) async {
    await Future.delayed(Duration(milliseconds: ms));
    final app = AppState.instance;
    if (app.offline) throw const OfflineException();
    if (app.simulateErrors) throw const ApiException('Server error (simulated)');
    return data();
  }

  @override
  Future<List<ClientaEvent>> fetchEvents() => _respond(() => SampleData.events, ms: 900);
  @override
  Future<List<Speaker>> fetchSpeakers() => _respond(() => SampleData.speakers, ms: 300);
  @override
  Future<List<NewsArticle>> fetchNews() => _respond(() => SampleData.news, ms: 800);
  @override
  Future<List<Person>> fetchPeople() => _respond(() => SampleData.people, ms: 400);
  @override
  Future<List<ChatThread>> fetchThreads() => _respond(SampleData.threads);
  @override
  Future<Map<String, List<ChatMessage>>> fetchLiveChats() => _respond(SampleData.liveChats);
  @override
  Future<List<EventGroup>> fetchGroups() => _respond(() => SampleData.groups);
  @override
  Future<List<Note>> fetchNotes() => _respond(SampleData.notes, ms: 400);
  @override
  Future<List<ResourceDoc>> fetchResources() => _respond(() => SampleData.resources);
  @override
  Future<List<ResourceDoc>> fetchKnowledge() => _respond(() => SampleData.knowledge);
  @override
  Future<List<AppNotification>> fetchNotifications() => _respond(SampleData.notifications, ms: 500);
  @override
  Future<List<Certificate>> fetchCertificates() => _respond(() => SampleData.certificates);
  @override
  Future<List<Poll>> fetchPolls() => _respond(SampleData.polls);
  @override
  Future<String> askSupportAi(String question) =>
      _respond(() => SampleData.aiAnswer(question), ms: 1400);
}
