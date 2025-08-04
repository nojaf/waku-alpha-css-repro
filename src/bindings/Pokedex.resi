type rec \"pokemon.sprites" = {front_default: string}
and pokemon = {id: int, name: string, sprites: \"pokemon.sprites"}

let getPokemonByIds: array<int> => promise<result<array<pokemon>, string>>
