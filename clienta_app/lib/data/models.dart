import 'package:flutter/material.dart';

import '../core/widgets/media.dart';

enum SessionStatus { completed, live, upcoming }

class Sponsor {
  const Sponsor(this.name, this.tier, this.color, this.tagline);
  final String name;
  final String tier;
  final Color color;
  final String tagline;
}

class Speaker {
  const Speaker({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    required this.bio,
    this.photoUrl,
    this.topics = const [],
  });
  final String id;
  final String name;
  final String title;
  final String company;
  final String bio;
  final String? photoUrl;
  final List<String> topics;
}

class Session {
  const Session({
    required this.id,
    required this.start,
    required this.end,
    required this.title,
    required this.description,
    this.speakerIds = const [],
    this.room = 'Main Hall',
    this.status = SessionStatus.upcoming,
    this.type = 'Session',
  });
  final String id;
  final DateTime start;
  final DateTime end;
  final String title;
  final String description;
  final List<String> speakerIds;
  final String room;
  final SessionStatus status;
  final String type;
}

class EventTip {
  const EventTip(this.title, this.body, this.icon, this.color);
  final String title;
  final String body;
  final IconData icon;
  final Color color;
}

class Venue {
  const Venue({required this.name, required this.address, required this.city, required this.country, required this.flag, this.directions = ''});
  final String name;
  final String address;
  final String city;
  final String country;
  final String flag;
  final String directions;
}

class ClientaEvent {
  const ClientaEvent({
    required this.id,
    required this.title,
    required this.tagline,
    required this.category,
    required this.description,
    required this.start,
    required this.end,
    required this.venue,
    required this.art,
    this.inviteOnly = false,
    this.disclaimers = const [],
    this.sponsors = const [],
    this.sessions = const [],
    this.speakerIds = const [],
    this.tips = const [],
    this.gallery = const [],
    this.attendees = 0,
    this.registered = false,
    this.dressCode = 'Business casual',
    this.image,
  });

  final String id;
  final String title;
  final String tagline;
  final String category;
  final String description;
  final DateTime start;
  final DateTime end;
  final Venue venue;
  final ArtTheme art;
  final bool inviteOnly;
  final List<String> disclaimers;
  final List<Sponsor> sponsors;
  final List<Session> sessions;
  final List<String> speakerIds;
  final List<EventTip> tips;
  final List<String> gallery;
  final int attendees;
  final bool registered;
  final String dressCode;

  /// Optional cover photo asset; falls back to generative artwork when null.
  final String? image;

  bool get isPast => end.isBefore(DateTime.now());
  bool get isLive => sessions.any((s) => s.status == SessionStatus.live);
}

enum NewsScope { global, country }

class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.published,
    required this.category,
    required this.scope,
    required this.art,
    this.country = 'Global',
    this.flag = '🌍',
    this.likes = 0,
    this.author = 'PCU Communications',
    this.readMinutes = 3,
    this.icon = Icons.article_rounded,
    this.image,
  });
  final String id;
  final String title;
  final String summary;
  final List<String> body;
  final DateTime published;
  final String category;
  final NewsScope scope;
  final ArtTheme art;
  final String country;
  final String flag;
  final int likes;
  final String author;
  final int readMinutes;
  final IconData icon;

  /// Optional photo asset; falls back to generative artwork when null.
  final String? image;
}

class Person {
  const Person({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    required this.department,
    required this.email,
    required this.country,
    required this.flag,
    this.photoUrl,
    this.online = false,
    this.bio = '',
    this.phone = '',
    this.isOrganizer = false,
  });
  final String id;
  final String name;
  final String title;
  final String company;
  final String department;
  final String email;
  final String country;
  final String flag;
  final String? photoUrl;
  final bool online;
  final String bio;
  final String phone;
  final bool isOrganizer;
}

enum MeetingStatus { pending, accepted, declined }

class MeetingInvite {
  MeetingInvite({
    required this.id,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.location,
    this.status = MeetingStatus.pending,
  });
  final String id;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final String location;
  MeetingStatus status;
}

enum MessageType { text, meeting, attachment, system }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.time,
    this.text = '',
    this.type = MessageType.text,
    this.meeting,
    this.attachmentName,
    this.replyTo,
    Map<String, String>? reactions,
  }) : reactions = reactions ?? {};
  final String id;
  final String senderId;
  final DateTime time;
  final String text;
  final MessageType type;
  final MeetingInvite? meeting;
  final String? attachmentName;

  /// The message this one replies to (shown as a quote in the bubble).
  final ChatMessage? replyTo;

  /// Person id → emoji. One reaction per person, like WhatsApp.
  final Map<String, String> reactions;
}

class ChatThread {
  ChatThread({
    required this.id,
    required this.title,
    required this.participantIds,
    required this.messages,
    this.isGroup = false,
    this.eventId,
    this.unread = 0,
    this.subtitle,
  });
  final String id;
  final String title;
  final List<String> participantIds;
  final List<ChatMessage> messages;
  final bool isGroup;
  final String? eventId;
  int unread;
  final String? subtitle;

  ChatMessage? get last => messages.isEmpty ? null : messages.last;
}

class EventGroup {
  const EventGroup({required this.id, required this.eventId, required this.number, required this.name, required this.room, required this.topic, required this.membersByDate, required this.color});
  final String id;
  final String eventId;
  final int number;
  final String name;
  final String room;
  final String topic;
  final Map<DateTime, List<String>> membersByDate;
  final Color color;
}

class Note {
  Note({required this.id, required this.eventId, required this.title, required this.body, required this.updated, this.color = 0});
  final String id;
  String eventId;
  String title;
  String body;
  DateTime updated;
  int color;
}

enum DocType { pdf, pptx, docx, xlsx, image, video }

class ResourceDoc {
  const ResourceDoc({
    required this.id,
    required this.title,
    required this.type,
    required this.sizeMb,
    required this.category,
    required this.description,
    required this.updated,
    this.eventId,
    this.pages = 12,
  });
  final String id;
  final String title;
  final DocType type;
  final double sizeMb;
  final String category;
  final String description;
  final DateTime updated;
  final String? eventId;
  final int pages;
}

enum NotificationType { announcement, agenda, news, chat, meeting, certificate, system }

class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.read = false,
    this.eventId,
  });
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final NotificationType type;
  bool read;
  final String? eventId;
}

class Certificate {
  const Certificate({
    required this.id,
    required this.eventId,
    required this.title,
    required this.kind,
    required this.recipient,
    required this.company,
    required this.issued,
    required this.statement,
    required this.credentialId,
    this.art = ArtTheme.ocean,
  });
  final String id;
  final String eventId;
  final String title;
  final String kind;
  final String recipient;
  final String company;
  final DateTime issued;
  final String statement;
  final String credentialId;
  final ArtTheme art;
}

enum QuestionType { rating, single, multi, text }

class SurveyQuestion {
  const SurveyQuestion({required this.id, required this.text, required this.type, this.options = const [], this.required = true});
  final String id;
  final String text;
  final QuestionType type;
  final List<String> options;
  final bool required;
}

class Poll {
  Poll({required this.id, required this.question, required this.options, required this.votes, this.closesIn = 'Closes in 2h'});
  final String id;
  final String question;
  final List<String> options;
  final List<int> votes;
  final String closesIn;
  int? votedIndex;

  int get total => votes.fold(0, (a, b) => a + b);
}
