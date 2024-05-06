return function (self, chara)
    local list = Game.world.map:getEvents("lasermachine")
    for i, laser in ipairs(list) do
        if laser.mode == "blue" or laser.mode == "orange" then laser.on = not laser.on end
        laser:updateLaser()
    end
    self:flip()
end