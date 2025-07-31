type pokemon = {id: int, name: string, sprites: {front_default: string}}

let getPokemonByIds: array<int> => promise<result<array<pokemon>, string>>
