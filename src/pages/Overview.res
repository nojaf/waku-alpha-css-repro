%%raw(`import '../styles.css'`)

type pkmn = {
  id: int,
  name: string,
  game: Pokedex.game,
}

let getData = async () => {
  open RescriptBun.BunSqlite
  let db = Database.make("db.sqlite")
  let statement = db->Database.query("SELECT * FROM pokemon")
  let pkmns = statement->Statement.all
  db->Database.close
  pkmns->Array.filterMap(pkmn => {
    switch pkmn {
    | JSON.Object(dict{
        "id": JSON.Number(id),
        "name": JSON.String(name),
        "game": JSON.String(game),
      }) =>
      Some({id: Float.toInt(id), name, game: Pokedex.parseGame(game)})
    | _ => None
    }
  })
}

@react.component
let default = async () => {
  let pkmns = await getData()
  <div>
    {Waku.loadCss()}
    <h1> {React.string("Overview")} </h1>
    {<div className="flex flex-wrap">
      {pkmns
      ->Array.map(pkmn => {
        let bg = switch pkmn.game {
        | Pokedex.FireRed => "bg-red-400"
        | Pokedex.LeafGreen => "bg-lime-300"
        | Pokedex.Both => "bg-linear-135/hsl from-lime-300 from-49% to-red-400 to-51%"
        | Pokedex.NotSure => "bg-gray-100"
        }
        <div
          key={Int.toString(pkmn.id)}
          className={`border border-gray-200 rounded m-2 flex flex-col items-center justify-center h-[150px] w-[150px] ${bg}`}>
          <h2 className="text-lg font-semibold capitalize mb-2 flex items-center">
            <span className="text-xs italic mr-1"> {React.int(pkmn.id)} </span>
            {React.string(pkmn.name)}
          </h2>
          <div
            className="w-[100px] h-[100px] bg-no-repeat -translate-y-3"
            style={{
              backgroundImage: `url(/images/spritesheet.png)`,
              backgroundPosition: `-${Int.toString((pkmn.id - 1) * 100)}px 0`,
            }}
          />
        </div>
      })
      ->React.array}
    </div>}
  </div>
}
