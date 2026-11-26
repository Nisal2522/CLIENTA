import 'package:flutter/widgets.dart';

import '../../data/store.dart';

/// Collections the Home tab needs before it can show real content.
const homeDataKeys = ['events', 'news', 'notifications', 'chats'];

/// Loads Home's data and decodes its cover photos ahead of time, so Home shows
/// Popular Events and Recent News right after sign-in instead of a skeleton.
/// Never throws: if something fails, Home falls back to its own loading state.
Future<void> preloadHome(BuildContext context, {String? userPhoto}) async {
  final store = Store.instance;
  try {
    await Future.wait(homeDataKeys.map(store.ensure)).timeout(const Duration(seconds: 6));
  } catch (_) {
    return;
  }
  if (!context.mounted) return;
  final assets = <String>{
    for (final e in store.events) ?e.image,
    for (final n in store.news) ?n.image,
    ?userPhoto,
  }.where((p) => p.startsWith('assets/'));
  try {
    await Future.wait(assets.map((p) => precacheImage(AssetImage(p), context)))
        .timeout(const Duration(milliseconds: 1200));
  } catch (_) {
    // Slow decode: Home still opens, photos fade in when ready.
  }
}
