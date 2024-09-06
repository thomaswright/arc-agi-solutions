// Types

type color = Black | Blue | Red | Green | Yellow | Gray | Pink | Orange | Cyan | Brown

type block = array<array<color>>

type coord = {
  x: int,
  y: int,
  color: color,
}

type corners = TL(coord) | TR(coord) | BL(coord) | BR(coord)

// Test Types

type dataBlock = array<array<int>>

type dataPair = {"input": dataBlock, "output": dataBlock}

type data = {"train": array<dataPair>, "test": array<dataPair>}

type test = {
  input: block,
  output: block,
}

type solutionExport = {
  taskName: string,
  data: data,
  main: block => option<block>,
}
module type Puzz = {
  let solutionExport: solutionExport
}

// Main

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

let allColors = [Black, Blue, Red, Green, Yellow, Gray, Pink, Orange, Cyan, Brown]

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

let stringToColor = color =>
  switch color {
  | "Black" => Black
  | "Blue" => Blue
  | "Red" => Red
  | "Green" => Green
  | "Yellow" => Yellow
  | "Gray" => Gray
  | "Pink" => Pink
  | "Orange" => Orange
  | "Cyan" => Cyan
  | "Brown" => Brown
  | _ => Black
  }

let colorToHex = color =>
  switch color {
  | Black => "#000"
  | Blue => "#0074d9"
  | Red => "#ff4136"
  | Green => "#2ecc40"
  | Yellow => "#ffdc00"
  | Gray => "#aaa"
  | Pink => "#f012be"
  | Orange => "#ff851b"
  | Cyan => "#7fdbff"
  | Brown => "#870c25"
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

let range = max => Array.make(~length=max + 1, 0)->Array.mapWithIndex((_, i) => i)

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

let maxes = full => {
  (full->Array.length - 1, full->transpose->Array.length - 1)
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
  let (ax, ay) = a->maxes
  let (bx, by) = b->maxes
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

let isOnEdge = ((x, y), input) => {
  let (maxX, maxY) = input->maxes

  x == 0 || x == maxX || y == 0 || y == maxY
}

let keepMapAll = (input, f) => {
  input
  ->Array.mapWithIndex((row, i) => {
    row->Array.mapWithIndex((el, j) => {
      f(el, i, j)
    })
  })
  ->Belt.Array.concatMany
  ->Belt.Array.keepMap(o => o)
}

let getCoordsOfColors = (input, colors) => {
  input->keepMapAll((el, i, j) => {
    colors->Array.includes(el) ? Some({color: el, x: i, y: j}) : None
  })
}

let reduceSatAll = (arr, fs) => {
  arr
  ->Array.reduce(fs, (acc, arrEl) => {
    let break = ref(false)
    acc->Array.reduce([], (acc2, f) => {
      f(arrEl) && !break.contents
        ? {
            break := true
            acc2
          }
        : [...acc2, f]
    })
  })
  ->Array.length == 0
}

let blank = (color, x, y) => {
  range(x)->Array.map(_ => range(y)->Array.map(_ => color))
}

let adjustRow = (input, rowNum, f) => {
  input->Array.mapWithIndex((row, i) => i == rowNum ? row->Array.map(f) : row)
}

let adjustCol = (input, colNum, f) => {
  input->Array.mapWithIndex((row, _i) =>
    row->Array.mapWithIndex((el, j) => j == colNum ? f(el) : el)
  )
}

let isAt = (a, b, (x, y)) => {
  a.x - x == b.x && a.y - y == b.y
}
let isAtEvery = (coords, a, arr) => {
  arr->Array.every(v => {
    coords->Array.some(b => {
      isAt(a, b, v)
    })
  })
}

let getCorners = coords => {
  coords->Belt.Array.keepMap(a => {
    if coords->isAtEvery(a, [(0, 1), (-1, 0)]) {
      Some(BL(a))
    } else if coords->isAtEvery(a, [(0, 1), (1, 0)]) {
      Some(BR(a))
    } else if coords->isAtEvery(a, [(0, -1), (-1, 0)]) {
      Some(TL(a))
    } else if coords->isAtEvery(a, [(0, -1), (1, 0)]) {
      Some(TR(a))
    } else {
      None
    }
  })
}

let unwrapCorner = c =>
  switch c {
  | TL(c_) => c_
  | TR(c_) => c_
  | BL(c_) => c_
  | BR(c_) => c_
  }

let intMax = (a, b) => {
  a > b ? a : b
}

let dist = (a, b) => {
  intMax(a - b, b - a)
}
let getByCoord = (input, (x, y)) => {
  input
  ->Array.get(x)
  ->Option.flatMap(row => {
    row->Array.get(y)
  })
}

let stepsToNext = (input: block, color, (xCoord, yCoord), (xStep, yStep)) => {
  let (maxX, maxY) = input->maxes

  let numSteps = ref(0)
  while {
    let nextX = xCoord + xStep * numSteps.contents
    let nextY = yCoord + yStep * numSteps.contents
    let nextCoord = input->getByCoord((nextX, nextY))
    nextCoord->Option.mapOr(false, nextCoord =>
      nextX >= 0 && nextX <= maxX && nextY >= 0 && nextY <= maxY && nextCoord != color
    )
  } {
    numSteps := numSteps.contents + 1
  }
  numSteps.contents
}

let between = (v, a, b) => {
  if a > b {
    v > b && v <= a
  } else if a < b {
    v >= a && v < b
  } else {
    v == a
  }
}
let adjustRel = (input, f, (coordX, coordY), (relX, relY)) => {
  input->Array.mapWithIndex((row, i) =>
    row->Array.mapWithIndex((el, j) => {
      if i->between(coordX, coordX + relX) && j->between(coordY, coordY + relY) {
        f(el)
      } else {
        el
      }
    })
  )
}

let adjustAll = (input, f) => {
  input->Array.mapWithIndex((row, i) => {
    row->Array.mapWithIndex((el, j) => {
      f(el, i, j)
    })
  })
}

// Testing

let allTests = (data: data) => {
  Array.concat(data["train"], data["test"])->Array.map(v => {
    input: v["input"]->toColors,
    output: v["output"]->toColors,
  })
}
