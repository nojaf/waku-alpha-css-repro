@@directive("'use client'")

open Pokedex
open TanStackVirtual

@react.component
let make = (
  ~items: array<pokemon>,
  ~loadMore: int => promise<result<array<Pokedex.pokemon>, string>>,
) => {
  let parentRef = React.useRef(Nullable.null)

  let (_isInTransition, startTransition) = React.useTransition()
  let (allItems, loadMore, isPending) = React.useActionState(async (currentItems, _) => {
    switch currentItems {
    | Error(error) => Error(error)
    | Ok(items) => {
        let skip = Math.Int.min(141, items->Array.length)
        let newItems = await loadMore(skip)
        newItems->Result.map(newItems => items->Array.concat(newItems))
      }
    }
  }, Ok(items))

  let virtualizer = TanStackVirtual.useVirtualizer({
    count: switch allItems {
    | Ok(items) => items->Array.length
    | Error(_) => 0
    },
    estimateSize: _ => 100,
    getScrollElement: () => parentRef.current,
    onChange: virtualizer => {
      switch allItems {
      | Error(_) => ()
      | Ok(items) if items->Array.length < 151 && !isPending =>
        virtualizer
        ->RowVirtualizer.getVirtualItems
        ->Array.last
        ->Option.forEach(({index}) => {
          if index > items->Array.length - 10 {
            startTransition(() => loadMore()->Promise.ignore)
          }
        })

      // We got them all!
      | Ok(_) => ()
      }
    },
    initialRect: {
      width: 100,
      height: 400,
    },
  })
  <>
    <div
      ref={ReactDOM.Ref.domRef(parentRef)}
      className="h-[400px] w-full overflow-auto border border-sky-100 content-center">
      {switch allItems {
      | Error(error) =>
        <div role="alert" className="alert alert-error mx-6">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            className="h-6 w-6 shrink-0 stroke-current"
            fill="none"
            viewBox="0 0 24 24">
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <span> {React.string(error)} </span>
        </div>
      | Ok(allItems) =>
        <div
          style={
            height: `${virtualizer->RowVirtualizer.getTotalSize->Int.toString}px`,
          }
          className="w-full relative">
          {virtualizer
          ->RowVirtualizer.getVirtualItems
          ->Array.map(item => {
            switch allItems[item.index] {
            | None => React.null
            | Some(pkmn) =>
              <div
                key={item.key}
                className="absolute"
                style={
                  top: `${item.start->Int.toString}px`,
                  height: `${item.size->Int.toString}px`,
                  left: `50%`,
                }>
                <img
                  className="h-full -translate-x-1/2"
                  src={pkmn.sprites.front_default}
                  alt={pkmn.name}
                />
              </div>
            }
          })
          ->React.array}
        </div>
      }}
    </div>
    {isPending
      ? <progress className="progress progress-primary w-56 mx-auto block mt-4"></progress>
      : React.null}
  </>
}
