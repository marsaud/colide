local ffi = require("ffi")

ffi.cdef([[
typedef struct {
    long tv_sec;
    long tv_nsec;
} timespec;

int clock_gettime(int clk_id, timespec *tp);
]])

local CLOCK_MONOTONIC = 1
local ts = ffi.new("timespec")

local function monotime()
  assert(ffi.C.clock_gettime(CLOCK_MONOTONIC, ts) == 0)
  return tonumber(ts.tv_sec) + tonumber(ts.tv_nsec) * 1e-9
end

return {
  monotime = monotime,
}
