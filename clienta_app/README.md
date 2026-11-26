# CLIENTA — Flutter prototype

**A Smarter Way to Collaborate with Clients.** CLIENTA is an event-management and client-collaboration app for Peterson & Control Union (PCU). This repository holds a working prototype with every screen built. It runs on Android, iOS and web, in light and dark mode. All data is local sample data.

> All people, companies, addresses, news items and figures in `lib/data/sample_data.dart` are fictional placeholders. Event photos and avatars load from `picsum.photos` / `randomuser.me` when online. When offline, the app falls back to built-in generative artwork and initials.

## Run it

```bash
flutter pub get
flutter run                 # connected phone / emulator
flutter run -d chrome       # web preview (shown inside a phone frame on wide screens)
flutter test                # smoke test that walks through every screen in both themes
```

There are no third-party packages. The app uses only the Flutter SDK.

## Demo sign-in

| Path | What happens |
|---|---|
| **PCU employee sign-in** | Shows a short loading state, then signs in a demo *employee* directly. Employees can also send event notifications. |
| **Already a client? Sign in** | Any valid email and an 8+ character password signs in a demo *client*. |
| **Register as Client** | A 3-step form with validation that creates a client from the details you enter. |

The prototype never collects real credentials. Employee SSO is meant to be wired to Microsoft Entra ID (MSAL).

## What's included

- **Onboarding:** animated splash, 3-page onboarding, welcome, client registration, sign-in, forgot password, one-tap employee sign-in, terms & privacy, and a QR badge screen, and permission primers for the camera and venue map (location).
- **Home:** greeting, region flag, theme toggle, notification badge, QR badge, global search, an animated weekly date strip with your sessions for the selected day, a popular-events carousel, recent news and Discover (Contacts, Knowledge Hub).
- **Event experience** (16 features per event): About (disclaimers, sponsors), Tips, Agenda (Completed / Live / Upcoming states, personal agenda), Speakers, Location (pan & zoom venue map), Gallery (grid + full-screen viewer + download), Certificates (preview + PDF download), Evaluations (survey + live polls), Live Chat, Chats & Schedule Meeting (accept / reject invites), Groups, My Notes (create / edit / swipe-delete + undo), Contact Us, Resources (preview + download), Notifications (employees can send updates) and Participants.
- **News:** For you / Global / Country scopes, category filters, featured article, likes, full article view and related news.
- **Chats:** 1:1 and group threads, meetings strip with status, event live chat, attachments, typing indicators and simulated replies.
- **Profile & services:** profile card with stats, edit profile, certificates, notes, settings (theme, notifications), language, privacy, account management, Contacts, Knowledge Hub, Support AI (suggestions, history, typewriter answers).
- **System states:** skeleton loaders, empty, error, offline banner + offline state, and success animations. *Settings → Prototype tools* can simulate offline mode and server errors, and opens a UI-states gallery.

## Architecture

```
lib/
  main.dart, app.dart        App entry, themes, phone frame for wide screens
  core/
    theme.dart               Brand colours, light/dark palettes, ThemeData
    app_state.dart           Session, preferences, ThemeController
    nav.dart                 Page transitions, sheets, toasts, dialogs
    format.dart              Date/time helpers
    widgets/                 Reusable components (cards, buttons, animations, media, states)
  data/
    models.dart              Domain models
    api.dart                 ClientaApi interface + MockClientaApi
    store.dart               ChangeNotifier cache + local mutations
    sample_data.dart         Fictional sample content
  features/                  auth, shell, home, events, news, chats, services, profile, common
```

**Connecting a real backend:** implement `ClientaApi` (for example an `HttpClientaApi` that calls your REST/GraphQL endpoints). Then construct `Store` with it in `lib/data/store.dart`:

```dart
static final Store instance = Store(HttpClientaApi(baseUrl: ...));
```

Screens load data through `AsyncView(keys: [...])`. It shows a skeleton while loading, an error or offline state with retry if loading fails, and rebuilds whenever the store changes. No UI code needs to change when you swap the API.
