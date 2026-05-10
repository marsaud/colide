local IAHit = {
  hit = function(self, id, who, by, vector)
    if who ~= self then
      return false
    end
    local result = false
    if self.runPlugins then
      result = self:runPlugins("_hit", self, id, who, by, vector)
    end
    if self._hit then
      result = self:_hit(id, who, by, vector) or result
    end
    if self.health and self.health > 0 then
      local damage = by.getDamage and by:getDamage(who) or 0
      self.health = self.health - damage
      if self.health <= 0 and self.eventManager then
        self.eventManager:delete(self)
      end
    end
    return result
  end,

  getDamage = function(self, target)
    local damage = 0
    if target == self then
      return damage
    end
    if self.runPlugins then
      local _, _damage = self:runPlugins("_getDamage", self, target)
      damage = damage + _damage
    end
    if self._getDamage then
      local _damage = self:_getDamage(target)
      damage = damage + _damage
    end
    return damage
  end,
}

return function()
  return IAHit
end
