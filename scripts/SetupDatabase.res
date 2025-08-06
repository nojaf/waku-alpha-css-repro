open RescriptBun.BunSqlite

let db = Database.make(
  "db.sqlite",
  ~options={
    create: true,
  },
)

db
->Database.query("
CREATE TABLE IF NOT EXISTS pokemon (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    game TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
")
->Statement.run
->ignore

let ids = Array.fromInitializer(~length=150, idx => {
  let id = idx + 1
  let exists =
    db
    ->Database.query("SELECT id FROM pokemon WHERE id = @id")
    ->Statement.getDict(
      dict{
        "@id": JSON.Number((id :> float)),
      },
    )
  switch exists {
  | Null | Undefined => Some(id)
  | Value(_) => None
  }
})->Array.filterMap(id => id)

let pkmms = await Pokedex.getPokemonByIds(ids)

let insertStatement =
  db->Database.query("INSERT INTO pokemon (id, name, game) VALUES (@id, @name, @game)")

switch pkmms {
| Error(e) => {
    Console.log(e)
    open RescriptBun
    Process.process->Process.exitWithCode(1)
  }
| Ok(pkmms) =>
  let _ = await pkmms
  ->Array.map(async pkmm => {
    let game = await Pokedex.getGame(pkmm.id)
    insertStatement->Statement.run(~params={"@id": pkmm.id, "@name": pkmm.name, "@game": game})
  })
  ->Promise.all
}

db->Database.close
