package.path = "./lib/?.lua;./lib/?/init.lua;" .. package.path

local run = require("protocol-test")
run()
