module Response = {
  type t

  @send
  external arrayBuffer: t => promise<ArrayBuffer.t> = "arrayBuffer"

  @send
  external json: t => promise<JSON.t> = "json"
}

external fetch: string => promise<Response.t> = "fetch"
