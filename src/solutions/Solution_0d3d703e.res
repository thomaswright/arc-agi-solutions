open Common

let taskName = "0d3d703e"

@module("../data/training/0d3d703e.json") external data: data = "default"

let newColor = color =>
  switch color {
  | Black => Orange
  | Blue => Gray
  | Red => Pink
  | Green => Yellow
  | Yellow => Green
  | Gray => Blue
  | Pink => Red
  | Orange => Black
  | Cyan => Brown
  | Brown => Cyan
  }

let tests = data->allTests

let main = input => {
  input
  ->adjustAll((color, _, _) => {
    color->newColor
  })
  ->Some
}

let solutionExport = {
  data,
  taskName,
  main,
}
