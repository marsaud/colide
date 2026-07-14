local HEALTH_BASE = 40

local ID = {
  BALL = "ball",
  BAT = "bat",
  BRICK = "brick",
  BRICKFALL = "brickfall",
  BOUND_CLOSE = "boundclose",
  BOUND_OUT = "boundout",
}

return {
  ID = ID,
  HEALTH = {
    BASE = HEALTH_BASE,
  },
  DAMAGE = {
    LETHAL = 1024 * HEALTH_BASE,
  },
}
