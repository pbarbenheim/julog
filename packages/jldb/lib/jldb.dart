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
export 'src/types/types.dart'
    hide AsyncResultDart, ResultDart, SuccessDart, FailureDart;
