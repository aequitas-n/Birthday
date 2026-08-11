/// Thin re-export so the Journal audio module keeps importing one path.
///
/// Storage lives in data/ so the repository can purge files on soft-delete
/// without depending on features/.
library;

export 'package:kin/data/local/files/audio_store.dart';
