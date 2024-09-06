open Common

let taskName = "3aa6fb7a"

@module("../data/training/3aa6fb7a.json") external data: data = "default"

let insideCorner = corner => {
  switch corner {
  | TR(c) => (c.x - 1, c.y + 1)
  | TL(c) => (c.x + 1, c.y + 1)
  | BR(c) => (c.x - 1, c.y - 1)
  | BL(c) => (c.x + 1, c.y - 1)
  }
}

let main = input => {
  input
  ->getCoordsOfColors([Cyan])
  ->getCorners
  ->Array.reduce(input, (acc, cur) => {
    acc->adjustRel(_ => Blue, cur->insideCorner, (0, 0))
  })
  ->Some
}

let solutionExport = {
  taskName,
  data,
  main,
}
