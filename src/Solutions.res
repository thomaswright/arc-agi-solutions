let keepMapWithIndex = (arr, f) =>
  arr->Array.mapWithIndex((x, i) => (x, i))->Belt.Array.keepMap(((x, i)) => f(x, i))

let transpose = arr => {
  arr->Array.reduceWithIndex([], (acc, cur, i) => {
    if i == 0 {
      cur->Array.map(x => [x])
    } else {
      acc->Array.map(x => {
        [...x, cur->Array.getUnsafe(i)]
      })
    }
  })
}

let findLinesOfColor = (full, color) => {
  full->keepMapWithIndex((row, i) => row->Array.every(c => c == color) ? Some(i) : None)
}

type color = Black | Blue | Red | Green | Yellow | Gray | Pink | Orange | Cyan | Brown

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

module Main_0b148d64 = {
  let main = () => {
    let full = [[]]
    let blackRows = full->findLinesOfColor(Black)
    let blackColumns = full->transpose->findLinesOfColor(Black)

    let (numRows, numCols) = full->dimensions

    let blockSpecs = getBlockSpecs(blackRows->converses(numRows), blackColumns->converses(numCols))

    let blocks = carve(full, blockSpecs)
    // split by section
    // find rows
    // take section that's a different color
  }
}
