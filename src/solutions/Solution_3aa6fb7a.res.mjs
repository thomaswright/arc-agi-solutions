// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Common from "../Common.res.mjs";
import * as Core__Array from "@rescript/core/src/Core__Array.res.mjs";
import Aa6fb7aJson from "../data/training/3aa6fb7a.json";

var taskName = "3aa6fb7a";

var data = Aa6fb7aJson;

function main(input) {
  return Core__Array.reduce(Common.getCorners(Common.getCoordsOfColors(input, ["Cyan"])), input, (function (acc, cur) {
                return Common.adjustRel(acc, (function (param) {
                              return "Blue";
                            }), Common.insideCorner(cur), [
                            0,
                            0
                          ]);
              }));
}

var solutionExport = {
  taskName: taskName,
  data: data,
  main: main
};

export {
  taskName ,
  data ,
  main ,
  solutionExport ,
}
/* data Not a pure module */