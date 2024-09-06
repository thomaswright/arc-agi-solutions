open Common

let taskName = "4290ef0e"

@module("../data/training/4290ef0e.json") external data: data = "default"

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
      a->adjustRel(_ => color, ((blankSize - adjustment) / 2, (blankSize - adjustment) / 2), (0, 0))
    })
  }

  measures
  ->Array.reduce(blank(bgColor, blankSize - adjustment, blankSize - adjustment)->singleAdjustment, (
    acc,
    (color, (size, arm)),
  ) => {
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
  })
  ->Some
}

let solutionExport = {
  taskName,
  data,
  main,
}
