local PluginManager = {
	_initPluginManager = function (self)
		if self._pluginManagerInit then return end
		self._plugins = {}
		self._pluginManagerInit = true
	end,
	addPlugin = function (self, id, func)
		self:_initPluginManager()
		if not self._plugins[id] then
			self._plugins[id] = {}
		end
		table.insert(self._plugins[id], func)
	end,
	runPlugins = function (self, id, ...)
		self:_initPluginManager()
		for _, func in ipairs(self._plugins[id] or {}) do
			func(...)
		end
	end
}

return function () return PluginManager end