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
type block = array<array<color>>
type test = {
  input: block,
  output: block,
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

type coord = {
  x: int,
  y: int,
  color: color,
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
  input->Array.mapWithIndex((row, i) =>
    row->Array.mapWithIndex((el, j) => j == colNum ? f(el) : el)
  )
}

module type Puzz = {
  let test: test
  let output: option<block>
}

type corners = TL(coord) | TR(coord) | BL(coord) | BR(coord)

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

module Solution_4290ef0e = {
  let testRaw = {
    "input": [
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 8, 8, 8, 1, 1, 1, 4, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 8, 1, 8, 1, 1, 1, 4, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 8, 8, 8, 1, 1, 1, 4, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4, 4, 4, 4, 4, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 3, 3, 1, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 3, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 3, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 3, 3, 1, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6, 6, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 1, 1],
      [1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 1, 1],
    ],
    "output": [
      [4, 4, 4, 4, 4, 1, 4, 4, 4, 4, 4],
      [4, 2, 2, 2, 1, 1, 1, 2, 2, 2, 4],
      [4, 2, 6, 6, 1, 1, 1, 6, 6, 2, 4],
      [4, 2, 6, 3, 3, 1, 3, 3, 6, 2, 4],
      [4, 1, 1, 3, 8, 8, 8, 3, 1, 1, 4],
      [1, 1, 1, 1, 8, 1, 8, 1, 1, 1, 1],
      [4, 1, 1, 3, 8, 8, 8, 3, 1, 1, 4],
      [4, 2, 6, 3, 3, 1, 3, 3, 6, 2, 4],
      [4, 2, 6, 6, 1, 1, 1, 6, 6, 2, 4],
      [4, 2, 2, 2, 1, 1, 1, 2, 2, 2, 4],
      [4, 4, 4, 4, 4, 1, 4, 4, 4, 4, 4],
    ],
  }
  let testRaw2 = {
    "input": [
      [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
      [2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
      [3, 3, 2, 3, 3, 1, 1, 1, 3, 3, 3, 1, 1, 1, 3, 8, 8, 3],
      [3, 3, 2, 3, 3, 1, 3, 3, 3, 3, 3, 3, 3, 1, 3, 8, 3, 3],
      [3, 3, 3, 3, 3, 1, 3, 3, 3, 3, 3, 3, 3, 1, 3, 3, 3, 3],
      [3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 8, 3, 3],
      [3, 3, 2, 3, 3, 3, 3, 7, 7, 7, 3, 3, 3, 3, 3, 8, 8, 3],
      [2, 2, 2, 3, 3, 3, 3, 7, 3, 7, 3, 3, 3, 3, 3, 3, 3, 3],
      [3, 3, 3, 3, 3, 1, 3, 7, 7, 7, 3, 3, 3, 1, 3, 3, 3, 3],
      [3, 3, 3, 3, 3, 1, 3, 3, 3, 3, 3, 3, 3, 1, 3, 3, 3, 3],
      [3, 3, 3, 3, 3, 1, 1, 1, 3, 3, 3, 1, 1, 1, 3, 3, 3, 3],
      [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
      [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
      [3, 3, 3, 4, 4, 3, 3, 3, 3, 3, 3, 3, 4, 4, 3, 3, 3, 3],
      [3, 3, 3, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 3, 3, 3, 3],
      [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
      [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 6, 3],
      [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
    ],
    "output": [
      [4, 4, 3, 3, 3, 3, 3, 3, 3, 4, 4],
      [4, 1, 1, 1, 3, 3, 3, 1, 1, 1, 4],
      [3, 1, 2, 2, 2, 3, 2, 2, 2, 1, 3],
      [3, 1, 2, 8, 8, 3, 8, 8, 2, 1, 3],
      [3, 3, 2, 8, 7, 7, 7, 8, 2, 3, 3],
      [3, 3, 3, 3, 7, 6, 7, 3, 3, 3, 3],
      [3, 3, 2, 8, 7, 7, 7, 8, 2, 3, 3],
      [3, 1, 2, 8, 8, 3, 8, 8, 2, 1, 3],
      [3, 1, 2, 2, 2, 3, 2, 2, 2, 1, 3],
      [4, 1, 1, 1, 3, 3, 3, 1, 1, 1, 4],
      [4, 4, 3, 3, 3, 3, 3, 3, 3, 4, 4],
    ],
  }

  let test = {
    input: testRaw["input"]->toColors,
    output: testRaw["output"]->toColors,
  }

  let main = input => {
    // get corners
    // measure corner to corner
    // or corner to next color
    //

    let colorGroups =
      allColors
      ->Array.map(color => {
        input->getCoordsOfColors([color])
      })
      ->Array.filter(coords => coords->Array.length != 0)

    let (singleCoord, boxes) = colorGroups->Belt.Array.partition(v => v->Array.length == 1)

    // let (withCorners, bg) = boxes->Belt.Array.partition(box => {
    //   box
    //   ->getCorners
    //   ->Array.length > 0
    // })

    let sortedBoxes =
      boxes->Array.toSorted((a, b) => (b->Array.length - a->Array.length)->Int.toFloat)

    let withCorners = sortedBoxes->Array.sliceToEnd(~start=1)

    let bgColor = sortedBoxes->Array.getUnsafe(0)->Array.getUnsafe(0)->{x => x.color}

    let getSizeAndArm = (corners, c, (xStep, yStep)) => {
      let armX = input->stepsToNext(bgColor, (c.x, c.y), (xStep, 0))
      let medianX = input->stepsToNext(c.color, (c.x + armX, c.y), (xStep, 0))

      let armY = input->stepsToNext(bgColor, (c.x, c.y), (0, yStep))
      let medianY = input->stepsToNext(c.color, (c.x, c.y + armY), (0, yStep))

      if corners->Array.length > 1 {
        let size = corners->Array.reduce(0, (acc, corner) => {
          let corner_ = unwrapCorner(corner)
          intMax(intMax(dist(corner_.x, c.x), dist(corner_.y, c.y)), acc)
        })

        (size, intMax(armX, armY))
      } else if armX + medianX > armY + medianY {
        (armY * 2 + medianY, armY)
      } else {
        (armX * 2 + medianX, armX)
      }
    }

    let measures =
      withCorners
      ->Array.map(coords => {
        let corners = coords->getCorners
        let color = coords->Array.getUnsafe(0)->{x => x.color}

        corners
        ->Array.map(v => {
          switch v {
          | TL(c) => getSizeAndArm(corners, c, (1, 1))
          | TR(c) => getSizeAndArm(corners, c, (-1, 1))
          | BL(c) => getSizeAndArm(corners, c, (1, -1))
          | BR(c) => getSizeAndArm(corners, c, (-1, -1))
          }
        })
        ->Array.reduce(None, (acc, (size, arm)) => {
          switch acc {
          | None => Some((size, arm))
          | Some((s, a)) => Some(size > s ? (size, arm) : (s, a))
          }
        })
        ->Option.map(v => (color, v))
      })
      ->Belt.Array.keepMap(x => x)
      ->Array.toSorted(((_, (sizeA, _)), (_, (sizeB, _))) => (sizeB - sizeA)->Int.toFloat)

    let blankSize = measures->Array.getUnsafe(0)->{((_, (size, _))) => size}
    let adjustment = mod(blankSize, 2)

    let singleAdjustment = a => {
      singleCoord
      ->Array.get(0)
      ->Option.flatMap(v => v->Array.get(0))
      ->Option.mapOr(a, ({color}) => {
        a->adjustRel(
          _ => color,
          ((blankSize - adjustment) / 2, (blankSize - adjustment) / 2),
          (0, 0),
        )
      })
    }

    measures->Array.reduce(
      blank(bgColor, blankSize - adjustment, blankSize - adjustment)->singleAdjustment,
      (acc, (color, (size, arm))) => {
        let i = size - mod(size, 2)
        let os = (blankSize - size) / 2

        acc
        ->adjustRel(_ => color, (os, os), (arm, 0))
        ->adjustRel(_ => color, (os, os), (0, arm))
        ->adjustRel(_ => color, (os + i, os), (-arm, 0))
        ->adjustRel(_ => color, (os + i, os), (0, arm))
        ->adjustRel(_ => color, (os, os + i), (arm, 0))
        ->adjustRel(_ => color, (os, os + i), (0, -arm))
        ->adjustRel(_ => color, (os + i, os + i), (-arm, 0))
        ->adjustRel(_ => color, (os + i, os + i), (0, -arm))
      },
    )
  }

  let output = Some(main(test.input))
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

    let (maxX, maxY) = input->maxes

    let blockSpecs = getBlockSpecs(blackRows->converses(maxX), blackColumns->converses(maxY))

    let blocks = carve(input, blockSpecs)

    let resultBlock =
      blocksNonBlackColor(blocks)
      ->Belt.Array.keepMap(((block, color)) => color)
      ->colorCount
      ->Belt.Map.String.findFirstBy((k, v) => v == 1)
      ->Option.flatMap(((k, v)) => {
        blocksNonBlackColor(blocks)
        ->Array.find(((block, color)) => color->Option.mapOr(false, c => c->colorToString == k))
        ->Option.map(((block, color)) => block)
      })

    resultBlock
  }
  let output = main(test.input)
}

module Solution_6cdd2623 = {
  let testRaw = {
    "input": [
      [0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 1, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
      [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 8, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 8, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 8, 1, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [2, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 2],
      [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0],
    ],
    "output": [
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    ],
  }
  let test = {
    input: testRaw["input"]->toColors,
    output: testRaw["output"]->toColors,
  }
  let main = (input: block) => {
    let hasOnlyFour =
      input
      ->Belt.Array.concatMany
      ->colorCount
      ->Belt.Map.String.toArray
      ->Array.filter(((k, v)) => v == 4)

    let color = hasOnlyFour->Array.find(((color, _)) => {
      input
      ->getCoordsOfColors([color->stringToColor])
      ->Array.every(c => isOnEdge((c.x, c.y), input))
    })

    let (maxX, maxY) = input->maxes

    color->Option.flatMap(((color_, _)) => {
      let colorCoords = input->getCoordsOfColors([color_->stringToColor])
      if (
        // two left, two right
        colorCoords->reduceSatAll([
          c => c.x == 0,
          c => c.x == 0,
          c => c.x == maxX,
          c => c.x == maxX,
        ])
      ) {
        let lefts = colorCoords->Array.filter(c => c.x == 0)
        let rights = colorCoords->Array.filter(c => c.x == maxX)
        let left0 = lefts->Array.getUnsafe(0)
        let left1 = lefts->Array.getUnsafe(1)

        let right0 = rights->Array.find(r => r.y == left0.y)
        let right1 = rights->Array.find(r => r.y == left1.y)

        switch (right0, right1) {
        | (Some(r1), Some(r2)) =>
          blank(Black, maxX, maxY)
          ->adjustCol(r1.y, _ => r1.color)
          ->adjustCol(r2.y, _ => r2.color)
          ->Some
        | _ => None
        }
      } else if (
        // two top, two bottom
        colorCoords->reduceSatAll([
          c => c.y == 0,
          c => c.y == 0,
          c => c.y == maxY,
          c => c.y == maxY,
        ])
      ) {
        let tops = colorCoords->Array.filter(c => c.y == 0)
        let bottoms = colorCoords->Array.filter(c => c.y == maxY)
        let top0 = tops->Array.getUnsafe(0)
        let top1 = tops->Array.getUnsafe(1)

        let bottom0 = bottoms->Array.find(b => b.x == top0.x)
        let bottom1 = bottoms->Array.find(b => b.x == top1.x)

        switch (bottom0, bottom1) {
        | (Some(b1), Some(b2)) =>
          blank(Black, maxX, maxY)
          ->adjustRow(b1.x, _ => b1.color)
          ->adjustRow(b2.x, _ => b2.color)
          ->Some
        | _ => None
        }
      } else if (
        // one left, one right, one top, one bottom
        colorCoords->reduceSatAll([
          c => c.x == 0,
          c => c.x == maxX,
          c => c.y == 0,
          c => c.y == maxY,
        ])
      ) {
        let left = colorCoords->Array.find(c => c.x == 0)
        let top = colorCoords->Array.find(c => c.y == 0)

        switch (left, top) {
        | (Some(l), Some(t)) => {
            let right = colorCoords->Array.find(c => c.y == l.y && c.x == maxX)
            let bottom = colorCoords->Array.find(c => c.x == t.x && c.y == maxY)

            switch (right, bottom) {
            | (Some(r), Some(b)) =>
              blank(Black, maxX, maxY)
              ->adjustCol(l.y, _ => l.color)
              ->adjustRow(t.x, _ => t.color)
              ->Some
            | _ => None
            }
          }
        | _ => None
        }
      } else {
        None
      }
    })
  }
  let output = main(test.input)
}

module Grid = {
  @react.component
  let make = (~block) => {
    <div className="p-2 ">
      <div className="flex flex-row gap-px bg-gray-600 w-fit ">
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

module Solution = Solution_4290ef0e
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
