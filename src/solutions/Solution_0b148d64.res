open Common

let taskName = "0b148d64"

@module("../data/training/0b148d64.json") external data: data = "default"

let main = input => {
  let blackRows = input->findLinesOfColor(Black)
  let blackColumns = input->transpose->findLinesOfColor(Black)

  let (maxX, maxY) = input->maxes

  let blockSpecs = getBlockSpecs(blackRows->converses(maxX), blackColumns->converses(maxY))

  let blocks = carve(input, blockSpecs)

  let resultBlock =
    blocksNonBlackColor(blocks)
    ->Belt.Array.keepMap(((_block, color)) => color)
    ->colorCount
    ->Belt.Map.String.findFirstBy((_k, v) => v == 1)
    ->Option.flatMap(((k, _v)) => {
      blocksNonBlackColor(blocks)
      ->Array.find(((_block, color)) => color->Option.mapOr(false, c => c->colorToString == k))
      ->Option.map(((block, _color)) => block)
    })

  resultBlock
}

let solutionExport = {
  taskName,
  data,
  main,
}
