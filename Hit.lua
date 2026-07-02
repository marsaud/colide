local IAHit = {
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
    if self.health and self.health > 0 then
      local damage = by.getDamage and by:getDamage(who) or 0
      if damage ~= 0 then
        self.health = self.health - damage
        if self.health <= 0 then
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
}

return {
  IAHit = IAHit,
}
