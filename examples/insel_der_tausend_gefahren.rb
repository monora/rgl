# Die Insel der 1000 Gefahren
# https://www.amazon.de/1000-Gefahren-Die-Insel/dp/3473520225/ref=pd_sim_b?ie=UTF8&qid=1203279845&sr=8-3

require 'rgl/adjacency'
require 'rgl/implicit'
require 'rgl/dot'

g = RGL::DirectedAdjacencyGraph[
  8, 9,
  8, 10,

  9, 11,
  9, 12,

  10, 13,
  10, 14,

  11, 15,
  11, 16,

  12, 17,
  12, 18,

  13, 19,
  13, 20,

  14, 21,
  14, 22,

  15, 23,
  15, 24,

  16, 25,
  16, 26,

  17, 27,
  17, 28,

  18, 29,
  18, 30,

  18, 31,
  18, 32,

  19, 31,
  19, 32,

  20, 33,
  20, 34,

  21, 35,
  21, 36,

  22, 37,
  22, 38,

  23, 39,
  23, 40,

  24, 41,
  24, 42,

  25, 43,
  25, 44,

  26, 45,
  26, 46,

  27, 47,
  27, 48,

  28, 49,
  28, 50,

  29, 51,
  29, 52,

  30, 53,
  30, 54,

  31, 55,
  31, 56,

  32, 57,
  32, 58,

  33, 59,
  33, 60,

  34, 61,
  34, 62,

  35, 63,
  35, 64,

  36, 65,
  36, 66,

  37, 67,

  38, 13,

  39, 68,
  39, 69,

  40, 70,
  40, 71,

  42, 72,
  42, 73,

  43, 74,
  43, 75,

  44, 76,
  44, 77,

  46, 78,
  46, 79,

  47, 80,
  47, 81,

  48, 82,
  48, 83,

  50, 84,
  50, 85,

  51, 86,
  51, 87,

  53, 90,
  53, 91,

  55, 93,
  55, 94,


  57,  92,


  58, 97,
  58, 98,

  59, 99,
  99, 100,

  60, 100,


  61, 101,
  61, 102,
  61, 103,

  62, 104,
  62, 105,

  64, 88,

  65, 106,
  65, 107,

  66, 9,

  67, 108,
  67, 109,

  75, 9,

  78, 26,

  86, 30,

  88, 106,
  88, 89,

  89, 16,

  92, 95,
  92, 96,

  93, 37,

  96, 9,

  105, 9,
  105, 10]
g.dotty
