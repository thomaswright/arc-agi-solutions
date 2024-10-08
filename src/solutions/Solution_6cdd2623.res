open Common

let taskName = "6cdd2623"

@module("../data/training/6cdd2623.json") external data: data = "default"

let main = (input: Common.block) => {
  let hasOnlyFour =
    input
    ->Belt.Array.concatMany
    ->colorCount
    ->Belt.Map.String.toArray
    ->Array.filter(((_k, v)) => v == 4)

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
      colorCoords->reduceSatAll([c => c.x == 0, c => c.x == 0, c => c.x == maxX, c => c.x == maxX])
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
      colorCoords->reduceSatAll([c => c.y == 0, c => c.y == 0, c => c.y == maxY, c => c.y == maxY])
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
      colorCoords->reduceSatAll([c => c.x == 0, c => c.x == maxX, c => c.y == 0, c => c.y == maxY])
    ) {
      let left = colorCoords->Array.find(c => c.x == 0)
      let top = colorCoords->Array.find(c => c.y == 0)

      switch (left, top) {
      | (Some(l), Some(t)) => {
          let right = colorCoords->Array.find(c => c.y == l.y && c.x == maxX)
          let bottom = colorCoords->Array.find(c => c.x == t.x && c.y == maxY)

          switch (right, bottom) {
          | (Some(_), Some(_)) =>
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

let solutionExport = (
  {
    taskName,
    data,
    main,
  }: Common.solutionExport
)
