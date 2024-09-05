open Common

module Grid = {
  @react.component
  let make = (~block) => {
    <div className="p-2 ">
      <div className="flex flex-col gap-px bg-gray-600 w-fit ">
        {block
        ->Array.map(row => {
          <div className="flex flex-row gap-px">
            {row
            ->Array.map(el => {
              <div
                style={{
                  backgroundColor: el->colorToHex,
                }}
                className="w-2 h-2"
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

module SolutionComp = {
  @react.component
  let make = (~tests, ~main) => {
    <div className="flex flex-col divide-y-2 divide-black">
      {tests
      ->Array.map(test => {
        <div className="flex flex-row py-2">
          <div>
            <div className="px-2 font-medium text-lg"> {"Input"->React.string} </div>
            <Grid block={test.input} />
          </div>
          {main(test.input)->Option.mapOr(React.null, output_ =>
            <div>
              <div className="px-2 font-medium text-lg"> {"Expected"->React.string} </div>
              <Grid block={test.output} />
              <div className="px-2 font-medium text-lg">
                {"Output"->React.string}
                <span className="p-2 font-black text-lg ">
                  {(compareBlocks(output_, test.output) ? "Solved!" : "Unsolved")->React.string}
                </span>
              </div>
              <Grid block={output_} />
            </div>
          )}
        </div>
      })
      ->React.array}
    </div>
  }
}

@react.component
let make = () => {
  let (selected, setSelected) = React.useState(() => Some("0b148d64"))
  let solutions = [
    Solution_0b148d64.solutionExport,
    Solution_6cdd2623.solutionExport,
    Solution_4290ef0e.solutionExport,
  ]

  <div>
    <div className="text-3xl font-black pb-4"> {"ARC (non) AGI"->React.string} </div>
    <div className="flex flex-row gap-2">
      {solutions
      ->Array.map(({taskName}) => {
        let isSelected = selected->Option.mapOr(false, s => s == taskName)
        <button
          className={[
            "px-2 rounded",
            isSelected ? "bg-blue-600 text-white" : "bg-blue-200",
          ]->Array.join(" ")}
          onClick={_ => setSelected(_ => Some(taskName))}>
          {taskName->React.string}
        </button>
      })
      ->React.array}
    </div>
    {selected
    ->Option.flatMap(v => solutions->Array.find(s => s.taskName == v))
    ->Option.mapOr(React.null, ({main, tests}) => <SolutionComp tests main />)}
  </div>
}