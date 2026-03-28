local CONTROL = {
	ACT3 = 64,
	ACT2 = 32,
	ACT1 = 16,
	UP = 8,
	DOWN = 4,
	LEFT = 2,
	RIGHT = 1,
	NONE = 0
}

local COLOR = {
	WHITE = { 1, 1, 1 },
	BLACK = { 0, 0, 0 },
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
  HIT = 'hit',
  DRAW = 'draw'
}

local MOVE = {
	UP = 'up',
	DOWN = 'down',
	LEFT = 'left',
	RIGHT = 'right',
	NONE = 'none'
}

return function () return COLOR, CONTROL, EVENT, MOVE end