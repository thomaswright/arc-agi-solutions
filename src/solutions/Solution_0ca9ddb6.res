open Common

let taskName = "0ca9ddb6"

@module("../data/training/0ca9ddb6.json") external data: data = "default"

let main = input => {
  let redFlower =
    input
    ->getCoordsOfColors([Red])
    ->Array.reduce(input, (acc, cur) => {
      acc
      ->adjustRel(_ => Yellow, (cur.x + 1, cur.y + 1), (0, 0))
      ->adjustRel(_ => Yellow, (cur.x - 1, cur.y + 1), (0, 0))
      ->adjustRel(_ => Yellow, (cur.x + 1, cur.y - 1), (0, 0))
      ->adjustRel(_ => Yellow, (cur.x - 1, cur.y - 1), (0, 0))
    })

  redFlower
  ->getCoordsOfColors([Blue])
  ->Array.reduce(redFlower, (acc, cur) => {
    acc
    ->adjustRel(_ => Orange, (cur.x + 1, cur.y), (0, 0))
    ->adjustRel(_ => Orange, (cur.x - 1, cur.y), (0, 0))
    ->adjustRel(_ => Orange, (cur.x, cur.y + 1), (0, 0))
    ->adjustRel(_ => Orange, (cur.x, cur.y - 1), (0, 0))
  })
  ->Some
}

let solutionExport = {
  taskName,
  data,
  main,
}
