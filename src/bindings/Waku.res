module Link = {
  @module("waku") @react.component(: ReactDOM.domProps)
  external make: ReactDOM.domProps => React.element = "Link"
}

type renderMode =
  | @as("static") Static
  | @as("dynamic") Dynamic

type createRootInput<'props> = {
  render: renderMode,
  component: React.component<'props>,
}

type createLayoutInput<'props> = {
  render: renderMode,
  component: React.component<'props>,
  path?: string,
}

type createPageInput<'props> = {
  render: renderMode,
  path: string,
  component: React.component<'props>,
}

module CreatePages = {
  type t

  @send
  external createRoot: (t, createRootInput<'props>) => unit = "createRoot"

  @send
  external createLayout: (t, createLayoutInput<'props>) => unit = "createLayout"

  @send
  external createPage: (t, createPageInput<'props>) => unit = "createPage"
}

type pages

@module("waku")
external createPages: (CreatePages.t => promise<unit>) => pages = "createPages"
