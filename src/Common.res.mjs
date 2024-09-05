// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Array from "@rescript/core/src/Core__Array.res.mjs";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as Belt_MapString from "rescript/lib/es6/belt_MapString.js";

function keepMapWithIndex(arr, f) {
  return Belt_Array.keepMap(arr.map(function (x, i) {
                  return [
                          x,
                          i
                        ];
                }), (function (param) {
                return f(param[0], param[1]);
              }));
}

function transpose(arr) {
  return Core__Array.reduceWithIndex(arr, [], (function (acc, cur, i) {
                if (i === 0) {
                  return cur.map(function (x) {
                              return [x];
                            });
                } else {
                  return acc.map(function (x, j) {
                              return Belt_Array.concatMany([
                                          x,
                                          [arr[i][j]]
                                        ]);
                            });
                }
              }));
}

function findLinesOfColor(full, color) {
  return keepMapWithIndex(full, (function (row, i) {
                if (row.every(function (c) {
                        return Caml_obj.equal(c, color);
                      })) {
                  return i;
                }
                
              }));
}

var allColors = [
  "Black",
  "Blue",
  "Red",
  "Green",
  "Yellow",
  "Gray",
  "Pink",
  "Orange",
  "Cyan",
  "Brown"
];

function colorToString(color) {
  switch (color) {
    case "Black" :
        return "Black";
    case "Blue" :
        return "Blue";
    case "Red" :
        return "Red";
    case "Green" :
        return "Green";
    case "Yellow" :
        return "Yellow";
    case "Gray" :
        return "Gray";
    case "Pink" :
        return "Pink";
    case "Orange" :
        return "Orange";
    case "Cyan" :
        return "Cyan";
    case "Brown" :
        return "Brown";
    
  }
}

function stringToColor(color) {
  switch (color) {
    case "Blue" :
        return "Blue";
    case "Brown" :
        return "Brown";
    case "Cyan" :
        return "Cyan";
    case "Gray" :
        return "Gray";
    case "Green" :
        return "Green";
    case "Orange" :
        return "Orange";
    case "Pink" :
        return "Pink";
    case "Red" :
        return "Red";
    case "Yellow" :
        return "Yellow";
    default:
      return "Black";
  }
}

function colorToHex(color) {
  switch (color) {
    case "Black" :
        return "#000";
    case "Blue" :
        return "#0074d9";
    case "Red" :
        return "#ff4136";
    case "Green" :
        return "#2ecc40";
    case "Yellow" :
        return "#ffdc00";
    case "Gray" :
        return "#aaa";
    case "Pink" :
        return "#f012be";
    case "Orange" :
        return "#ff851b";
    case "Cyan" :
        return "#7fdbff";
    case "Brown" :
        return "#870c25";
    
  }
}

function toColor(color) {
  switch (color) {
    case 1 :
        return "Blue";
    case 2 :
        return "Red";
    case 3 :
        return "Green";
    case 4 :
        return "Yellow";
    case 5 :
        return "Gray";
    case 6 :
        return "Pink";
    case 7 :
        return "Orange";
    case 8 :
        return "Cyan";
    case 9 :
        return "Brown";
    default:
      return "Black";
  }
}

function toColors(arr) {
  return arr.map(function (x) {
              return x.map(function (y) {
                          return toColor(y);
                        });
            });
}

function range(max) {
  return Core__Array.make(max + 1 | 0, 0).map(function (param, i) {
              return i;
            });
}

function converses(selects, max) {
  return range(max).filter(function (i) {
              return !selects.includes(i);
            });
}

function getLastEl(arr) {
  return arr[arr.length - 1 | 0];
}

function appendToLastEl(arr, x) {
  var lastIndex = arr.length - 1 | 0;
  return arr.map(function (e, i) {
              if (i === lastIndex) {
                return Belt_Array.concatMany([
                            e,
                            [x]
                          ]);
              } else {
                return e;
              }
            });
}

function groups(rows) {
  return Core__Array.reduce(rows, [], (function (acc, cur) {
                return Core__Option.mapOr(getLastEl(acc), [[cur]], (function (lastGroup) {
                              return Core__Option.mapOr(getLastEl(lastGroup), [[cur]], (function (lastEl) {
                                            if (lastEl === (cur - 1 | 0)) {
                                              return appendToLastEl(acc, cur);
                                            } else {
                                              return Belt_Array.concatMany([
                                                          acc,
                                                          [[cur]]
                                                        ]);
                                            }
                                          }));
                            }));
              }));
}

function maxes(full) {
  return [
          full.length - 1 | 0,
          transpose(full).length - 1 | 0
        ];
}

function allPairs(x, y) {
  return Belt_Array.concatMany(x.map(function (xv) {
                  return y.map(function (yv) {
                              return [
                                      xv,
                                      yv
                                    ];
                            });
                }));
}

function subSet(set, rows, cols) {
  return keepMapWithIndex(set, (function (x, i) {
                if (rows.includes(i)) {
                  return keepMapWithIndex(x, (function (y, j) {
                                if (cols.includes(j)) {
                                  return Caml_option.some(y);
                                }
                                
                              }));
                }
                
              }));
}

function getBlockSpecs(rows, cols) {
  var rowGroups = groups(rows);
  var colGroups = groups(cols);
  return allPairs(rowGroups, colGroups);
}

function carve(full, blockSpecs) {
  return blockSpecs.map(function (param) {
              return subSet(full, param[0], param[1]);
            });
}

function blocksNonBlackColor(blocks) {
  return blocks.map(function (block) {
              return [
                      block,
                      Core__Array.reduce(Belt_Array.concatMany(block), undefined, (function (acc, cur) {
                              if (Core__Option.isSome(acc) || cur === "Black") {
                                return acc;
                              } else {
                                return cur;
                              }
                            }))
                    ];
            });
}

function colorCount(arr) {
  return Core__Array.reduce(arr, undefined, (function (acc, cur) {
                return Belt_MapString.update(acc, colorToString(cur), (function (o) {
                              if (o !== undefined) {
                                return o + 1 | 0;
                              } else {
                                return 1;
                              }
                            }));
              }));
}

function compareBlocks(a, b) {
  var match = maxes(a);
  var match$1 = maxes(b);
  if (match[0] !== match$1[0] || match[1] !== match$1[1]) {
    return false;
  } else {
    return Core__Array.reduceWithIndex(a, true, (function (acc, row, i) {
                  return Core__Array.reduceWithIndex(row, acc, (function (acc2, el, j) {
                                if (acc2) {
                                  return Caml_obj.equal(el, b[i][j]);
                                } else {
                                  return false;
                                }
                              }));
                }));
  }
}

function isOnEdge(param, input) {
  var y = param[1];
  var x = param[0];
  var match = maxes(input);
  if (x === 0 || x === match[0] || y === 0) {
    return true;
  } else {
    return y === match[1];
  }
}

function keepMapAll(input, f) {
  return Belt_Array.keepMap(Belt_Array.concatMany(input.map(function (row, i) {
                      return row.map(function (el, j) {
                                  return f(el, i, j);
                                });
                    })), (function (o) {
                return o;
              }));
}

function getCoordsOfColors(input, colors) {
  return keepMapAll(input, (function (el, i, j) {
                if (colors.includes(el)) {
                  return {
                          x: i,
                          y: j,
                          color: el
                        };
                }
                
              }));
}

function reduceSatAll(arr, fs) {
  return Core__Array.reduce(arr, fs, (function (acc, arrEl) {
                var $$break = {
                  contents: false
                };
                return Core__Array.reduce(acc, [], (function (acc2, f) {
                              if (f(arrEl) && !$$break.contents) {
                                $$break.contents = true;
                                return acc2;
                              } else {
                                return Belt_Array.concatMany([
                                            acc2,
                                            [f]
                                          ]);
                              }
                            }));
              })).length === 0;
}

function blank(color, x, y) {
  return range(x).map(function (param) {
              return range(y).map(function (param) {
                          return color;
                        });
            });
}

function adjustRow(input, rowNum, f) {
  return input.map(function (row, i) {
              if (i === rowNum) {
                return row.map(f);
              } else {
                return row;
              }
            });
}

function adjustCol(input, colNum, f) {
  return input.map(function (row, _i) {
              return row.map(function (el, j) {
                          if (j === colNum) {
                            return f(el);
                          } else {
                            return el;
                          }
                        });
            });
}

function isAt(a, b, param) {
  if ((a.x - param[0] | 0) === b.x) {
    return (a.y - param[1] | 0) === b.y;
  } else {
    return false;
  }
}

function isAtEvery(coords, a, arr) {
  return arr.every(function (v) {
              return coords.some(function (b) {
                          return isAt(a, b, v);
                        });
            });
}

function getCorners(coords) {
  return Belt_Array.keepMap(coords, (function (a) {
                if (isAtEvery(coords, a, [
                        [
                          0,
                          1
                        ],
                        [
                          -1,
                          0
                        ]
                      ])) {
                  return {
                          TAG: "BL",
                          _0: a
                        };
                } else if (isAtEvery(coords, a, [
                        [
                          0,
                          1
                        ],
                        [
                          1,
                          0
                        ]
                      ])) {
                  return {
                          TAG: "BR",
                          _0: a
                        };
                } else if (isAtEvery(coords, a, [
                        [
                          0,
                          -1
                        ],
                        [
                          -1,
                          0
                        ]
                      ])) {
                  return {
                          TAG: "TL",
                          _0: a
                        };
                } else if (isAtEvery(coords, a, [
                        [
                          0,
                          -1
                        ],
                        [
                          1,
                          0
                        ]
                      ])) {
                  return {
                          TAG: "TR",
                          _0: a
                        };
                } else {
                  return ;
                }
              }));
}

function unwrapCorner(c) {
  return c._0;
}

function intMax(a, b) {
  if (Caml_obj.greaterthan(a, b)) {
    return a;
  } else {
    return b;
  }
}

function dist(a, b) {
  return intMax(a - b | 0, b - a | 0);
}

function getByCoord(input, param) {
  var y = param[1];
  return Core__Option.flatMap(input[param[0]], (function (row) {
                return row[y];
              }));
}

function stepsToNext(input, color, param, param$1) {
  var yStep = param$1[1];
  var xStep = param$1[0];
  var yCoord = param[1];
  var xCoord = param[0];
  var match = maxes(input);
  var maxY = match[1];
  var maxX = match[0];
  var numSteps = 0;
  while((function () {
          var nextX = xCoord + Math.imul(xStep, numSteps) | 0;
          var nextY = yCoord + Math.imul(yStep, numSteps) | 0;
          var nextCoord = getByCoord(input, [
                nextX,
                nextY
              ]);
          return Core__Option.mapOr(nextCoord, false, (function (nextCoord) {
                        if (nextX >= 0 && nextX <= maxX && nextY >= 0 && nextY <= maxY) {
                          return nextCoord !== color;
                        } else {
                          return false;
                        }
                      }));
        })()) {
    numSteps = numSteps + 1 | 0;
  };
  return numSteps;
}

function between(v, a, b) {
  if (Caml_obj.greaterthan(a, b)) {
    if (Caml_obj.greaterthan(v, b)) {
      return Caml_obj.lessequal(v, a);
    } else {
      return false;
    }
  } else if (Caml_obj.lessthan(a, b)) {
    if (Caml_obj.greaterequal(v, a)) {
      return Caml_obj.lessthan(v, b);
    } else {
      return false;
    }
  } else {
    return Caml_obj.equal(v, a);
  }
}

function adjustRel(input, f, param, param$1) {
  var relY = param$1[1];
  var relX = param$1[0];
  var coordY = param[1];
  var coordX = param[0];
  return input.map(function (row, i) {
              return row.map(function (el, j) {
                          if (between(i, coordX, coordX + relX | 0) && between(j, coordY, coordY + relY | 0)) {
                            return f(el);
                          } else {
                            return el;
                          }
                        });
            });
}

function allTests(data) {
  return data.train.concat(data.test).map(function (v) {
              return {
                      input: toColors(v.input),
                      output: toColors(v.output)
                    };
            });
}

export {
  keepMapWithIndex ,
  transpose ,
  findLinesOfColor ,
  allColors ,
  colorToString ,
  stringToColor ,
  colorToHex ,
  toColor ,
  toColors ,
  range ,
  converses ,
  getLastEl ,
  appendToLastEl ,
  groups ,
  maxes ,
  allPairs ,
  subSet ,
  getBlockSpecs ,
  carve ,
  blocksNonBlackColor ,
  colorCount ,
  compareBlocks ,
  isOnEdge ,
  keepMapAll ,
  getCoordsOfColors ,
  reduceSatAll ,
  blank ,
  adjustRow ,
  adjustCol ,
  isAt ,
  isAtEvery ,
  getCorners ,
  unwrapCorner ,
  intMax ,
  dist ,
  getByCoord ,
  stepsToNext ,
  between ,
  adjustRel ,
  allTests ,
}
/* No side effect */