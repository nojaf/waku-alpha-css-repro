module Link = {
  @module("waku") @react.component(: ReactDOM.domProps)
  external make: ReactDOM.domProps => React.element = "Link"
}

@scope("import.meta.viteRsc")
external loadCss: unit => React.element = "loadCss"
