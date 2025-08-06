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

type game =
  | FireRed
  | LeafGreen
  | Both
  | NotSure

let parseGame = (game: string): game => {
  switch String.toLocaleLowerCase(game) {
  | "firered" => FireRed
  | "leafgreen" => LeafGreen
  | "both" => Both
  | _ => NotSure
  }
}

let filterFireredLeafGreen = (versionDetails: array<JSON.t>) => {
  versionDetails->Array.filterMap(json => {
    switch json {
    | JSON.Object(dict{"version": JSON.Object(dict{"name": JSON.String(name)})}) =>
      switch name {
      | "firered" | "leafgreen" => Some(name)
      | _ => None
      }
    | _ => None
    }
  })
}

let getGame = async (id: int): game => {
  open Fetch
  let encounters = await fetch(
    `https://pokeapi.co/api/v2/pokemon/${Int.toString(id)}/encounters`,
  )->Promise.then(Response.json)
  let inGameLocations = switch encounters {
  | JSON.Array(encounters) =>
    encounters
    ->Array.flatMap(json => {
      switch json {
      | JSON.Object(dict{
          //
          "location_area": JSON.Object(dict{"name": JSON.String(_name)}),
          "version_details": JSON.Array(versionDetails),
        }) =>
        versionDetails->filterFireredLeafGreen
      | _ => []
      }
    })
    ->Set.fromArray
  | _ => Set.make()
  }

  let inLeaf = inGameLocations->Set.has("leafgreen")
  let inFirered = inGameLocations->Set.has("firered")

  switch (inLeaf, inFirered) {
  | (true, true) => Both
  | (true, false) => LeafGreen
  | (false, true) => FireRed
  | _ => NotSure
  }
}
