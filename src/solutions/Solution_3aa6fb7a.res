open Common

let taskName = "3aa6fb7a"

@module("../data/training/3aa6fb7a.json") external data: data = "default"

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
