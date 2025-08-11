## Project overview

Flutter app to learn Traditional Chinese, focusing on Bopomofo, stroke order, listening/speaking, and vocabulary practice. Multi-platform (Android, iOS, macOS, Windows, Linux, Web). Uses Riverpod 2.x plus some Provider. Material 3 theme, custom Chinese fonts, large asset set (images, stroke JSON, audio).

## Bootstrapping and app structure

- Orientation set based on device type (phones: portrait; tablets: all orientations).
- Pre-initializes local databases and polyphonic data; initializes core services (TTS, audio player, speech-to-text, recorder) and injects via Riverpod overrides.
- Global screen metrics captured via a notifier and used app-wide.

Key entry: `lib/main.dart`.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // orientation, DBs, polyphonic data
  final serviceInitializer = ServiceInitializer();
  final providers = await serviceInitializer.initializeServices();
  final container = ProviderContainer(overrides: providers);
  runApp(ProviderScope(child: UncontrolledProviderScope(container: container, child: const MyApp())));
}
```

## Routing and navigation

- Central route map in `lib/constants/routes.dart` (`AppRoutes`): login, main page, units, teach word, settings, bopomo quizzes, zhuyin tests, etc.
- `teachWord` route wraps a scoped `ProviderScope` to override `contextProvider` and build a `WordController` with injected dependencies, then renders `TeachWordView` with arguments.

## State management and services

- Riverpod state for grade/semester/publisher, account, counts, toggles; `screenInfoProvider` for device metrics.
- Service providers: `FlutterTts`, `AudioPlayer`, `SpeechToText`, `AudioRecorder` created once and reused; speech error handling via providers.
- Some legacy `provider` usages remain in older views.

Providers hub: `lib/providers.dart`.

## Teach Word module (core learning)

- `lib/teach_word/presentation/teach_word_view.dart` drives a 5-tab flow: Look, Listen, Write, Use, Speak.
- Loads stroke data from `lib/assets/svg/<char>.json` with a fallback list for missing characters; creates and wires `StrokeOrderAnimationController`.
- Audio behavior: Bopomofo plays bundled mp3; Chinese characters use TTS.
- `WordController` (`StateNotifier`) coordinates stroke state, quiz progress, error surfacing, and learned state transitions.

```dart
void onPlayAudio() {
  final WordState wordState = ref.read(wordControllerProvider);
  final String word = wordState.currentWord;
  if (wordState.isBpmf) {
    player.play(AssetSource('bopomo/$word.mp3'));
  } else {
    ftts.speak(word);
  }
}
```

## Data and persistence

- Two local SQLite DBs shipped as assets (`assets/data_files/`):
  - `all.sqlite`: textbooks, words, phrase/sentence relations; accessed via `AllProvider`, `UnitProvider`, etc.
  - `users.sqlite`: users and per-user wordStatus; accessed via `UserProvider`, `WordStatusProvider`.
- First-run copy from assets; on version increase, DB is overwritten from assets (for `all.sqlite`) or upgraded with scripted changes (for `users.sqlite`). Indexes created on hot columns.

Key providers:
- `lib/data/providers/all_provider.dart` (versioned copy/upgrade + indexes)
- `lib/data/providers/user_provider.dart` (user CRUD, wordStatus maintenance, upgrade seeding + indexes)
- `lib/data/providers/unit_provider.dart` (queries `TextBooks`, computes counts)

`shared_preferences` is used in login helpers.

## Assets

- Stroke JSONs: `lib/assets/svg/` (~9.5k files).
- Vocabulary/word images: `lib/assets/img/`.
- Bopomofo and UI sounds: `assets/bopomo/`, `assets/sounds/`.
- Databases: `assets/data_files/`.
- Fonts: `lib/assets/fonts/` (Iansui, Bpmf).

## UI/theming and device handling

- Material 3 with custom colors; font family switches by grade (`BpmfIansui` for lower grades, `Iansui` otherwise).
- Global text scale fixed to 1.0.
- `ScreenInfo` abstraction computes `fontSize`, orientation, `isTablet`, etc., updated on metrics change and used throughout.

## Dependencies (pinned for compatibility)

- Riverpod 2.4.9, Provider 6.0.5
- sqflite 2.3.0, shared_preferences 2.2.0
- audioplayers 5.2.0, flutter_tts 3.8.3, speech_to_text 6.3.0, record 5.0.0
- path_provider 2.0.15, intl 0.18.1
- Dart SDK `>=3.0.6 <4.0.0`, Flutter 3.10.6; several packages intentionally downgraded.

## Strengths

- Clear modularization across views, providers, services, and models.
- Deterministic, asset-backed data with indexing for performance.
- Robust device/orientation handling and centralized screen metrics.
- Riverpod-based state for the core, with good separation in Teach Word flow.

## Risks / cleanup opportunities

- Mixed state management (Riverpod + Provider); consolidate to Riverpod where feasible.
- Duplicated provider concepts in teach-word area (e.g., multiple error handlers, provider files); unify responsibilities.
- Dialog error handling requires `BuildContext` from providers; consider a navigator-key or top-level presenter for safer decoupling.
- `all.sqlite` upgrade replaces the DB; ensure no user-modifiable data resides there or consider migration tooling.
- Hardcoded lists (e.g., missing stroke `noSvgList`) and scattered fallbacks; centralize configuration.
- Large asset footprint; consider on-demand/lazy loading or compression where viable.
- Many debug prints; adopt structured logging with levels, and minimize noise in release builds.
- Pinned older dependencies limit upgrades; plan staged updates and CI coverage.

## Suggested next steps

- Standardize on Riverpod; remove remaining `provider` usages in views.
- Consolidate teach-word providers and error handling into a single, well-named module.
- Add integration tests for login → main → units → teach-word flow, including stroke quiz success path.
- Introduce CI, raise `flutter_lints`, and plan a dependency upgrade path (Flutter/Dart + plugins).
- Evaluate asset loading strategies for stroke JSON and images to reduce app size and memory.


