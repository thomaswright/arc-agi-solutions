let keepMapWithIndex = (arr, f) =>
  arr->Array.mapWithIndex((x, i) => (x, i))->Belt.Array.keepMap(((x, i)) => f(x, i))

let transpose = arr => {
  arr->Array.reduceWithIndex([], (acc, cur, i) => {
    if i == 0 {
      cur->Array.map(x => [x])
    } else {
      acc->Array.mapWithIndex((x, j) => {
        [...x, arr->Array.getUnsafe(i)->Array.getUnsafe(j)]
      })
    }
  })
}

let findLinesOfColor = (full, color) => {
  full->keepMapWithIndex((row, i) => row->Array.every(c => c == color) ? Some(i) : None)
}

type color = Black | Blue | Red | Green | Yellow | Gray | Pink | Orange | Cyan | Brown

let colorToString = color =>
  switch color {
  | Black => "Black"
  | Blue => "Blue"
  | Red => "Red"
  | Green => "Green"
  | Yellow => "Yellow"
  | Gray => "Gray"
  | Pink => "Pink"
  | Orange => "Orange"
  | Cyan => "Cyan"
  | Brown => "Brown"
  }

let colorToHex = color =>
  switch color {
  | Black => "#000"
  | Blue => "#00f"
  | Red => "#f00"
  | Green => "#0f0"
  | Yellow => "#ff0"
  | Gray => "#aaa"
  | Pink => "#f0f"
  | Orange => "#fa0"
  | Cyan => "#0ff"
  | Brown => "#550"
  }

let toColor = color =>
  switch color {
  | 0 => Black
  | 1 => Blue
  | 2 => Red
  | 3 => Green
  | 4 => Yellow
  | 5 => Gray
  | 6 => Pink
  | 7 => Orange
  | 8 => Cyan
  | 9 => Brown
  | _ => Black
  }
let toColors = arr => {
  arr->Array.map(x => x->Array.map(y => y->toColor))
}

let range = max => Array.make(~length=max, 0)->Array.mapWithIndex((_, i) => i)

let converses = (selects, max) => {
  range(max)->Array.filter(i => !(selects->Array.includes(i)))
}

let getLastEl = arr => arr->Array.get(arr->Array.length - 1)

let appendToLastEl = (arr, x) => {
  let lastIndex = arr->Array.length - 1
  arr->Array.mapWithIndex((e, i) => {
    i == lastIndex ? [...e, x] : e
  })
}

let groups: array<int> => array<array<int>> = rows => {
  rows->Array.reduce([], (acc, cur) => {
    acc
    ->getLastEl
    ->Option.mapOr([[cur]], lastGroup =>
      lastGroup
      ->getLastEl
      ->Option.mapOr(
        [[cur]],
        lastEl => lastEl == cur - 1 ? acc->appendToLastEl(cur) : [...acc, [cur]],
      )
    )
  })
}

let dimensions = full => {
  (full->Array.length, full->transpose->Array.length)
}

let allPairs = (x, y) => {
  x->Array.map(xv => y->Array.map(yv => (xv, yv)))->Belt.Array.concatMany
}

let subSet = (set, rows, cols) => {
  set->keepMapWithIndex((x, i) =>
    rows->Array.includes(i)
      ? Some(x->keepMapWithIndex((y, j) => cols->Array.includes(j) ? Some(y) : None))
      : None
  )
}

let getBlockSpecs = (rows, cols) => {
  let rowGroups = rows->groups
  let colGroups = cols->groups
  allPairs(rowGroups, colGroups)
}

let carve = (full, blockSpecs) => {
  blockSpecs->Array.map(((rows, cols)) => {
    full->subSet(rows, cols)
  })
}

let blocksNonBlackColor = blocks => {
  blocks->Array.map(block => (
    block,
    block
    ->Belt.Array.concatMany
    ->Array.reduce(None, (acc, cur) => {
      acc->Option.isSome ? acc : cur != Black ? Some(cur) : acc
    }),
  ))
}

let colorCount = arr =>
  arr->Array.reduce(Belt.Map.String.empty, (acc, cur) =>
    acc->Belt.Map.String.update(cur->colorToString, o =>
      switch o {
      | None => 1->Some
      | Some(x) => (x + 1)->Some
      }
    )
  )

let compareBlocks = (a, b) => {
  let (ax, ay) = a->dimensions
  let (bx, by) = b->dimensions
  if ax != bx || ay != by {
    false
  } else {
    a->Array.reduceWithIndex(true, (acc, row, i) => {
      row->Array.reduceWithIndex(acc, (acc2, el, j) => {
        acc2 ? el == b->Array.getUnsafe(i)->Array.getUnsafe(j) : false
      })
    })
  }
}
type block = array<array<color>>
type test = {
  input: block,
  output: block,
}
module type Puzz = {
  let test: test
  let output: option<block>
}

module Solution_0b148d64: Puzz = {
  let testRaw = {
    "input": [
      [1, 1, 1, 1, 0, 1, 0, 0, 3, 0, 3, 3, 3, 3, 3, 3, 0],
      [1, 0, 1, 0, 1, 1, 0, 0, 0, 3, 0, 3, 3, 3, 0, 0, 0],
      [1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 0, 0],
      [0, 0, 0, 1, 1, 1, 0, 0, 3, 3, 0, 3, 3, 0, 3, 0, 0],
      [1, 1, 1, 1, 1, 1, 0, 0, 0, 3, 0, 3, 3, 3, 0, 3, 3],
      [1, 1, 1, 1, 1, 1, 0, 0, 3, 3, 0, 0, 0, 3, 0, 0, 3],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [3, 0, 0, 0, 0, 3, 0, 0, 3, 3, 3, 0, 3, 0, 3, 0, 3],
      [0, 3, 3, 0, 0, 3, 0, 0, 0, 3, 0, 3, 3, 3, 0, 0, 0],
      [3, 3, 3, 3, 3, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 3],
      [3, 0, 3, 0, 3, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 0, 3],
      [0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 0, 3, 3, 0],
    ],
    "output": [
      [1, 1, 1, 1, 0, 1],
      [1, 0, 1, 0, 1, 1],
      [1, 1, 0, 1, 1, 0],
      [0, 0, 0, 1, 1, 1],
      [1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1],
    ],
  }
  let test = {
    input: testRaw["input"]->toColors,
    output: testRaw["output"]->toColors,
  }
  let main = input => {
    let blackRows = input->findLinesOfColor(Black)
    let blackColumns = input->transpose->findLinesOfColor(Black)

    let (numRows, numCols) = input->dimensions

    let blockSpecs = getBlockSpecs(blackRows->converses(numRows), blackColumns->converses(numCols))
    Console.log5(
      blackRows,
      blackColumns,
      blackRows->converses(numRows),
      blackColumns->converses(numCols),
      blockSpecs,
    )
    let blocks = carve(input, blockSpecs)

    let resultBlock =
      blocksNonBlackColor(blocks)
      ->Belt.Array.keepMap(((block, color)) => color)
      ->colorCount
      ->Belt.Map.String.toArray
      ->Array.find(((k, v)) => v == 1)
      ->Option.flatMap(((k, v)) => {
        blocksNonBlackColor(blocks)
        ->Array.find(((block, color)) => color->Option.mapOr(false, c => c->colorToString == k))
        ->Option.map(((block, color)) => block)
      })

    resultBlock
  }
  let output = main(test.input)
}

module Grid = {
  @react.component
  let make = (~block) => {
    <div className="p-2 ">
      <div className="flex flex-row gap-px bg-gray-500 w-fit ">
        {block
        ->Array.map(row => {
          <div className="flex flex-col gap-px">
            {row
            ->Array.map(el => {
              <div
                style={{
                  backgroundColor: el->colorToHex,
                }}
                className="w-5 h-5"
              />
            })
            ->React.array}
          </div>
        })
        ->React.array}
      </div>
    </div>
  }
}

module Solution = Solution_0b148d64
@react.component
let make = () => {
  <div className="flex flex-row">
    <Grid block={Solution.test.input} />
    {Solution.output->Option.mapOr(React.null, output_ =>
      <div>
        <Grid block={output_} />
        <Grid block={Solution.test.output} />
        <div className="p-2 font-black text-xl">
          {(compareBlocks(output_, Solution.test.output) ? "Solved!" : "Unsolved")->React.string}
        </div>
      </div>
    )}
  </div>
}
