%%raw(`import '../styles.css'`)

@react.component
let default = async () => {
  let pkmns = await Pokedex.getPokemonByIds(Array.fromInitializer(~length=150, idx => idx + 1))

  <div>
    {Waku.loadCss()}
    <h1> {React.string("Overview")} </h1>
    {switch pkmns {
    | Error(error) => React.string(error)
    | Ok(pkmns) =>
      <div className="flex flex-wrap">
        {pkmns
        ->Array.map(pkmn => {
          <div key={Int.toString(pkmn.id)} className="border m-2 flex flex-col">
            <h2 className="text-center"> {React.string(pkmn.name)} </h2>
            <div
              className="w-[100px] h-[100px] bg-no-repeat"
              style={{
                backgroundImage: `url(/images/spritesheet.png)`,
                backgroundPosition: `-${Int.toString((pkmn.id - 1) * 100)}px 0`,
              }}
            />
          </div>
        })
        ->React.array}
      </div>
    }}
  </div>
}
