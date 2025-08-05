type t

@module("pokedex-promise-v2") @new
external make: unit => t = "default"

type pokemon = {
  id: int,
  name: string,
  sprites: {front_default: string},
}

@send
external getPokemonByName: (t, array<int>) => promise<array<pokemon>> = "getPokemonByName"

let pokedex = make()

let stripPkmn = pkmn => {
  id: pkmn.id,
  name: pkmn.name,
  sprites: {
    front_default: pkmn.sprites.front_default,
  },
}

let getPokemonByIds = async (ids: array<int>): result<array<pokemon>, string> => {
  try {
    let pkmns = await getPokemonByName(pokedex, ids)
    if ids->Array.some(i => i > 700) {
      Error("Higher than 70")
    } else {
      Ok(pkmns->Array.map(stripPkmn))
    }
  } catch {
  | _ => Error("Unexpected error in while taking to pokemon api")
  }
}
