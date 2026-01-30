class DatabaseMigrations {
  static Iterable<String> getMigrations({int currentVersion = 0}) {
    final migrations = _migrations.entries
        .where((e) => e.key > currentVersion)
        .toList();
    migrations.sort((a, b) => a.key.compareTo(b.key));
    return migrations.map((e) => e.value);
  }

  static const Map<int, String> _migrations = {3: _v3};

  static const String _v3 = '''
    create table config (
      field text primary key,
      val text not null
    );

    create table kategorien (
      id text primary key,
      name text not null
    );

    create table betreuer (
      id text primary key,
      name text not null,
      sex integer not null
    );

    create table identity (
      id text primary key,
      public_key text not null
    );

    create table jugendlicher (
      id text primary key,
      name text not null,
      sex integer not null,
      pass text,
      birth_date bigint not null,
      member_since bigint not null,
      exit_date bigint,
      exit_reason integer,
      replaced_by_id text references jugendlicher (id)
    );

    create table eintrag (
      id text primary key,
      start bigint not null,
      end bigint not null,
      kategorie_id text not null references kategorien (id),
      thema text not null,
      ort text,
      raum text,
      dienstverlauf text,
      besonderheiten text
    );

    create table eintrag_betreuer (
      eintrag_id text not null references eintraege (id),
      betreuer_id text not null references betreuer (id),
      primary key (eintrag_id, betreuer_id)
    );

    create table eintrag_jugendlicher (
      eintrag_id text not null references eintraege (id),
      jugendlicher_id text not null references jugendlicher (id),
      status integer not null,
      primary key (eintrag_id, jugendlicher_id)
    );

    create table signature (
      eintrag_id text not null references eintrag (id),
      identity_id text not null references identity (id),
      signature text not null,
      timestamp bigint not null,
      version integer not null,
      primary key (eintrag_id, identity_id)
    );

    PRAGMA user_version = 3;
  ''';
}
