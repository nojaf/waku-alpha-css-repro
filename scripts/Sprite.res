module Buffer = {
  type t

  @module("node:buffer") @scope("Buffer")
  external fromArrayBuffer: ArrayBuffer.t => t = "from"
}

module Sharp = {
  type input = {
    create: {
      width: int,
      height: int,
      channels: int,
      background: {
        r: int,
        g: int,
        b: int,
        alpha: int,
      },
    },
  }

  type t

  @module("sharp")
  external sharp: input => t = "default"

  @module("sharp")
  external sharpFromBuffer: Buffer.t => t = "default"

  type resizeOption = {width: int, height: int, fit: string}

  @send
  external resize: (t, resizeOption) => t = "resize"

  @send
  external png: t => t = "png"

  @send
  external toBuffer: t => promise<Buffer.t> = "toBuffer"

  type overlayOption = {
    input: Buffer.t,
    top: int,
    left: int,
  }

  @send
  external composite: (t, array<overlayOption>) => t = "composite"

  @send
  external toFile: (t, string) => promise<unit> = "toFile"
}

module Path = {
  @module("node:path")
  external resolve: (string, string) => string = "resolve"
}

@scope("import.meta")
external dirname: string = "dirname"

let thumbnailSize = 100
let url = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"

let downloadImage = async (url: string, index: int): Sharp.overlayOption => {
  open Fetch
  let response = await fetch(url)
  let arrayBuffer = await response->Response.arrayBuffer
  let buffer = await arrayBuffer
  ->Buffer.fromArrayBuffer
  ->Sharp.sharpFromBuffer
  ->Sharp.resize({width: thumbnailSize, height: thumbnailSize, fit: "cover"})
  ->Sharp.png
  ->Sharp.toBuffer
  {input: buffer, top: 0, left: index * thumbnailSize}
}

let sources = Array.fromInitializer(~length=150, idx => {
  `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${Int.toString(
      idx + 1,
    )}.png`
})
let images = await sources->Array.mapWithIndex(downloadImage)->Promise.all
let totalWidth = thumbnailSize * sources->Array.length
await Sharp.sharp({
  create: {
    width: totalWidth,
    height: thumbnailSize,
    channels: 4,
    background: {r: 0, g: 0, b: 0, alpha: 0},
  },
})
->Sharp.composite(images)
->Sharp.png
->Sharp.toFile(Path.resolve(dirname, "../public/images/spritesheet.png"))
