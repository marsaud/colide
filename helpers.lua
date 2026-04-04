local ICollapse = {
  _hit = function(self, who, by, _)
    local damage = by.getHit and by:getHit(who) or 0
    self.health = self.health - damage
    if self.health <= 0 and self.eventManager then
      self.eventManager:delete(self)
    end
  end,
}

return {
  ICollapse = ICollapse,
}
