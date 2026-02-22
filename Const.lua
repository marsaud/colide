local CONTROL = {
	ACT3 = 1000000,
	ACT2 = 100000,
	ACT1 = 10000,
	UP = 1000,
	DOWN = 100,
	LEFT = 10,
	RIGHT = 1,
	NONE = 0
}

local MOVE = CONTROL

local COLOR = {
	WHITE = {1, 1, 1},
	BLACK = {0, 0, 0},
	RED = { 1, 0, 0 },
	GREEN = { 0, 1, 0 },
	BLUE = { 0, 0, 1 },
	MAGENTA = { 1, 0, 1 },
	YELLOW = { 1, 1, 0 },
	CYAN = { 0, 1, 1 },
	ORANGE = { 1, 0.5, 0 },
}
COLOR.DEFAULT = COLOR.WHITE

local EVENT = {
  CONTROL ='control',
  MOVE = 'resolve',
  COMMIT = 'commit',
  HIT = 'hit'
}

return function () return COLOR, CONTROL, EVENT, MOVE end