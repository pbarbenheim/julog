class DatabaseMigrations {
  static Iterable<String> getMigrations({int currentVersion = 0}) {
    final migrations = _migrations.entries
        .where(
          (e) => e.key > currentVersion,
        )
        .toList();
    migrations.sort(
      (a, b) => a.key.compareTo(b.key),
    );
    return migrations.map((e) => e.value);
  }

  // Migrations
  static const Map<int, String> _migrations = {
    2: _v2,
  };

  static const String _v2 = """
    create table info (
      field text primary key,
      value text not null
    );

    create table kategorien (
      id integer primary key autoincrement,
      name text not null
    );

    create table eintrag (
      id integer primary key autoincrement,
      beginn integer not null,
      ende integer not null,
      kategorie_id integer not null references kategorien (id),
      thema text,
      ort text,
      raum text,
      dienstverlauf text,
      besonderheiten text
    );

    create table identities (
      userid text primary key,
      public_key text
    );

    create table signatures (
      eintrag_id integer references eintrag (id),
      userid text references identities (userid),
      signature text not null,
      signed_at int not null,
      sign_version integer not null default 2,
      primary key (eintrag_id, userid),
      unique (eintrag_id, signed_at)
    );

    create table betreuer (
      id integer primary key autoincrement,
      name text not null,
      geschlecht integer not null
    );

    create table eintrag_zu_betreuer (
      eintrag_id integer references eintrag (id),
      betreuer_id integer references betreuer (id)
    );

    create table jugendlicher (
      id integer primary key autoincrement,
      name text not null,
      geschlecht integer not null,
      passnummer text,
      geburtstag integer not null,
      eintrittsdatum integer not null,
      austrittsdatum integer,
      austrittsgrund integer,
      ersetzt_durch integer references jugendlicher (id)
    );

    create table eintrag_zu_jugendlicher (
      eintrag_id integer references eintrag (id),
      jugendlicher_id integer references jugendlicher (id),
      anwesenheit integer
    );

    pragma application_id = 448493213;
    pragma user_version = 2;
  """;
}
