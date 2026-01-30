const signV4Query = '''
select json_object(
  'id', e.id,
  'start', e.start,
  'end', e.end,
  'kategorie', json_object(
    'id', k.id,
    'name', k.name
  ),
  'thema', e.thema,
  'ort', e.ort,
  'raum', e.raum,
  'dienstverlauf', e.dienstverlauf,
  'besonderheiten', e.besonderheiten,
  'betreuer', json(json_betreuer.b),
  'jugendliche', json(json_jugend.json_jugend),
  'version', 4
)
from
  eintrag as e,
  kategorien as k,
  (
    select 
      json_group_array(
        json_object(
          'id', j.id,
          'name', j.name,
          'anwesend', 
            case 
              when ej.status = 1 then 1
              else 0
            end,
          'entschuldigt', 
            case 
              when ej.status = 2 then 1
              else 0
            end
        )
      ) as json_jugend,
      ej.eintrag_id
    from
      jugendlicher as j,
      eintrag_jugendlicher as ej
    where j.id = ej.jugendlicher_id
    group by ej.eintrag_id
  ) as json_jugend,
  (
    select 
      json_group_array(
        json_object(
          'id', b.id,
          'name', b.name
        )
      ) as b,
      eb.eintrag_id
    from
      betreuer as b,
      eintrag_betreuer as eb
    where b.id = eb.betreuer_id
    group by eb.eintrag_id
  ) as json_betreuer
where e.kategorie_id = k.id
  and json_betreuer.eintrag_id = e.id
  and json_jugend.eintrag_id = e.id
  and e.id = ?;
''';
