%%raw(`import '../styles.css'`)

@react.component
let default = async () => {
  let initial = await Pokedex.getPokemonByIds(Array.fromInitializer(~length=10, idx => idx + 1))

  let loadMore =
    @directive("'use server'")
    async (skip: int): result<array<Pokedex.pokemon>, string> => {
      let ids = Array.fromInitializer(~length=10, idx => skip + idx)
      // You never ever want to throw an error in a server function

      await Pokedex.getPokemonByIds(ids)
    }

  <div>
    <h1> {React.string("Infinite Scroll")} </h1>
    {switch initial {
    | Ok(items) => <InfiniteScroll items={items} loadMore={loadMore} />
    | Error(error) => React.string(error)
    }}
  </div>
}

let getConfig = async () => {
  {"render": "dynamic"}
}
