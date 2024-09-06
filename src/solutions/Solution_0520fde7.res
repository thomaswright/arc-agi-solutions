open Common

let taskName = "0520fde7"

@module("../data/training/0520fde7.json") external data: data = "default"

let main = input => {
  let superimposedBlues =
    input
    ->getCoordsOfColors([Blue])
    ->Array.map(c => c.y > 3 ? {...c, y: c.y - 4} : c)

  let doubleBlues =
    superimposedBlues->Array.filter(c =>
      superimposedBlues->Array.filter(c2 => c2.x == c.x && c2.y == c.y)->Array.length > 1
    )

  doubleBlues
  ->Array.reduce(blank(Black, 2, 2), (acc, cur) => {
    acc->adjustRel(_ => Red, (cur.x, cur.y), (0, 0))
  })
  ->Some
}

let solutionExport = {
  taskName,
  data,
  main,
}
