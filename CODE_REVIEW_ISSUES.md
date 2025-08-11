## Code review issues and suggested fixes

The following items were identified during an in-depth scan. They are grouped by severity, include locations, effects, and concrete fixes.

### Critical

- [ ] AllProvider: database version not set after upgrade
  - Effect: Each startup may think the DB is outdated and re-copy from assets, causing unnecessary work and index churn.
  - Where:
    ```dart
    // lib/data/providers/all_provider.dart
    int currentVersion = await _database!.getVersion();
    if (currentVersion < _dbNewVersion) {
      await _upgradeDatabase(dbPath);
    }

    Future<void> _upgradeDatabase(String dbPath) async {
      await closeDb();
      await _copyDbFromAssets(dbPath);
      _database = await openDatabase(dbPath);
      // Missing: await _database!.setVersion(_dbNewVersion);
      await _createIndexes(_database!);
    }
    ```
  - Fix: after opening the upgraded DB, call:
    ```dart
    await _database!.setVersion(_dbNewVersion);
    ```

- [ ] Asset paths for AudioPlayer sources
  - Effect: Asset audio fails to load at runtime.
  - Details: `pubspec.yaml` declares `assets/bopomo/` and `assets/sounds/`, but code uses `AssetSource('bopomo/...')` or `AssetSource('sounds/...')`. The path should include `assets/`.
  - Where (examples):
    ```dart
    // lib/teach_word/presentation/teach_word_view.dart
    player.play(AssetSource('bopomo/$word.mp3'));

    // lib/teach_word/notifiers/speech_state_notifier.dart
    await _audioPlayer.setSource(AssetSource('sounds/short_beep.mp3'));
    ```
  - Fix: prefix with `assets/`:
    ```dart
    AssetSource('assets/bopomo/$word.mp3')
    AssetSource('assets/sounds/short_beep.mp3')
    ```

### High

- [ ] Error handling in Teach Word missing context
  - Effect: Dialogs never show; errors silently ignored.
  - Where:
    ```dart
    // lib/teach_word/controllers/word_controller.dart
    ref.read(errorHandlerProvider).handleError(...); // no context passed

    // lib/teach_word/providers/word_provider.dart
    void handleError(String message, { BuildContext? context, ... }) {
      if (context == null) return; // bails out
      ErrorUtils.showError(context, message, ...);
    }
    ```
  - Fix options:
    - Pass `context: context` in `WordController.handleError(...)` calls; or
    - Change `ErrorHandler` to read `final ctx = ref.read(contextProvider)` and use that.

- [ ] Duplicate `TeachWordView` class names
  - Effect: Confusing imports; potential for referencing the wrong widget.
  - Where: `lib/views/teach_word_view.dart` and `lib/teach_word/presentation/teach_word_view.dart`.
  - Fix: Remove or rename the legacy view in `lib/views/`, keep only the presentation one.

### Medium

- [ ] Invalid opacity in `Color.fromRGBO`
  - Effect: The fourth parameter must be a double from 0.0 to 1.0.
  - Where:
    ```dart
    // lib/views/view_utils.dart
    const Color backgroundColor = Color.fromRGBO(245, 245, 220, 100);
    ```
  - Fix:
    ```dart
    const Color backgroundColor = Color.fromRGBO(245, 245, 220, 1.0);
    ```

- [ ] Recording format/extension mismatch
  - Effect: WAV used on Android but file extension is `.m4a`; can confuse downstream logic.
  - Where:
    ```dart
    // lib/teach_word/services/speech_service.dart
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.wav, ...), path: _recordingPath!);
    ...
    return '${appDir.path}/recording_... .m4a';
    ```
  - Fix: use `.wav` when WAV is recorded on Android, or unify on AAC (`.m4a`) for both platforms.

- [ ] TabBar onTap uses stale controller index
  - Effect: Navigation logic may use the wrong index.
  - Where:
    ```dart
    // lib/teach_word/presentation/teach_word_view.dart
    onTap: (index) {
      navigateToTab(_tabController, _tabController.previousIndex, _tabController.index, wordIsLearned);
    }
    ```
  - Fix: pass the `index` provided by the callback instead of reading `_tabController.index`.

- [ ] Logger setup unused in release
  - Effect: Logger instance created but not retained; logs still printed via `debugPrint`.
  - Where: `lib/main.dart::setupLogger()`.
  - Fix: store a global/shared Logger and use it, or remove the unused setup.

### Low / cleanup

- [ ] Mixed `riverpod` and `provider` in older views; standardize on Riverpod.
- [ ] Hardcoded `noSvgList` appears in multiple places; centralize in one config/service.
- [ ] Many `debugPrint` calls; consider structured logging and reducing noise in release.
- [ ] `ScreenInfo` equality compares doubles; currently rounded to 0.1 which helps—keep an eye on future changes.

### Notes

- Dependencies are pinned for Dart 3.0.6/Flutter 3.10.6; plan staged upgrades with CI.
- Asset footprint is large; evaluate on-demand loading where possible.


