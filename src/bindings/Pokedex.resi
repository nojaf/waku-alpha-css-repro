type rec \"pokemon.sprites" = {front_default: string}
and pokemon = {id: int, name: string, sprites: \"pokemon.sprites"}

let getPokemonByIds: array<int> => promise<result<array<pokemon>, string>>

type game =
  | FireRed
  | LeafGreen
  | Both
  | NotSure

let parseGame: string => game

let getGame: int => promise<game>
