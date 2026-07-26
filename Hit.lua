local L = require("lib")

local IAHit = {
  _constructors = {
    IAHit = function(self)
      self._health = 0
      if L.x(self.health) then
        self:valHealth(self.health)
        self.health = nil
      end
    end,
  },

  hit = function(self, id, who, by, vector)
    if who ~= self then
      return false
    end
    local result = false
    if self.runPrePlugins then
      result = self:runPrePlugins("_hit", self, id, who, by, vector)
    end
    if self._hit then
      result = self:_hit(id, who, by, vector) or result
    end
    if self.runPostPlugins then
      result = self:runPostPlugins("_hit", self, id, who, by, vector) or result
    end
    local health = self:valHealth()
    if health and health > 0 then
      local damage = by.getDamage and by:getDamage(who) or 0
      if damage ~= 0 then
        health = self:valHealth(-damage)
        if health ~= nil and health <= 0 then
          if self.eventManager then
            self.eventManager:delete(self)
          end
          self:destroy(id, who, by, vector)
        end
      end
    end
    return result
  end,

  destroy = function(self, id, who, by, vector)
    if self._destroy then
      return self:_destroy(id, who, by, vector)
    end
  end,

  getDamage = function(self, target)
    local damage = 0
    if target == self then
      return damage
    end
    if self.runPrePlugins then
      local _, _damage = self:runPrePlugins("_getDamage", self, target)
      damage = damage + _damage
    end
    if self._getDamage then
      local _damage = self:_getDamage(target)
      damage = damage + _damage
    end
    if self.runPostPlugins then
      local _, _damage = self:runPostPlugins("_getDamage", self, target)
      damage = damage + _damage
    end
    return damage
  end,

  valHealth = function(self, value)
    if self._valHealth then
      return self:_valHealth(value)
    else
      if value then
        self._health = self._health + value
        return self._health
      elseif self._health <= 0 then
        return nil
      else
        return self._health
      end
    end
  end,
}

return {
  IAHit = IAHit,
}
