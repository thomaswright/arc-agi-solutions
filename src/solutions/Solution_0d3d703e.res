open Common

let taskName = "0d3d703e"

let data = {
  "train": [
    {"input": [[3, 1, 2], [3, 1, 2], [3, 1, 2]], "output": [[4, 5, 6], [4, 5, 6], [4, 5, 6]]},
    {"input": [[2, 3, 8], [2, 3, 8], [2, 3, 8]], "output": [[6, 4, 9], [6, 4, 9], [6, 4, 9]]},
    {"input": [[5, 8, 6], [5, 8, 6], [5, 8, 6]], "output": [[1, 9, 2], [1, 9, 2], [1, 9, 2]]},
    {"input": [[9, 4, 2], [9, 4, 2], [9, 4, 2]], "output": [[8, 3, 6], [8, 3, 6], [8, 3, 6]]},
  ],
  "test": [
    {"input": [[8, 1, 3], [8, 1, 3], [8, 1, 3]], "output": [[9, 5, 4], [9, 5, 4], [9, 5, 4]]},
  ],
}

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
  tests,
  taskName,
  main,
}
