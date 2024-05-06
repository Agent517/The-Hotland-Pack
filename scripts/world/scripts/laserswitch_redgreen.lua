return function (self, chara)
    -- Get every laser in the map; if it's red or green, swap it to green or red.
    local list = Game.world.map:getEvents("lasermachine")
    for i, laser in ipairs(list) do
        if laser.mode == "red" then
            laser.mode = "green"
            laser:updateLaser()
        elseif laser.mode == "green" then
            laser.mode = "red"
            laser:updateLaser()
        end
    end
    self:flip()
end