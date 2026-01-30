/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

export 'src/jldb.dart' show Jldb, jldbCompatibleSinceVersion;
export 'src/models/models.dart'
    hide
        eintragApiModelFromDbArray,
        eintragStatusAnwesend,
        eintragStatusEntschuldigt,
        UUIDExtension;
export 'src/types/result.dart' hide AsyncResultDart, ResultDart;
export 'src/types/optional.dart' show None, Some, Optional, OptionalExtension;
export 'src/types/result_optional.dart';
