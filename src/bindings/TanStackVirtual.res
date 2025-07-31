type px = int

type virtualItem = {
  key: string,
  index: int,
  size: px,
  start: px,
  end: px,
}

module RowVirtualizer = {
  type t

  @send
  external getVirtualItems: t => array<virtualItem> = "getVirtualItems"

  @send
  external getTotalSize: t => px = "getTotalSize"
}

type useVirtualizerInput<'scrollElement> = {
  count: int,
  getScrollElement: unit => 'scrollElement,
  estimateSize: int => px,
  overscan?: int,
  onChange?: RowVirtualizer.t => unit,
  initialRect?: {
    width: int,
    height: int,
  }
}

@module("@tanstack/react-virtual")
external useVirtualizer: useVirtualizerInput<'scrollElement> => RowVirtualizer.t = "useVirtualizer"
