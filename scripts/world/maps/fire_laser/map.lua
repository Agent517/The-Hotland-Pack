local FireLaser, super = Class(Map)

-- PLEASE redo this later, it genuinely sucks.
function FireLaser:onEnter()
    super.onEnter(self)
    --self:goLeft()
end
function FireLaser:goLeft()
    Game.world.map:getEvent(32):slideTo(1160, 400, 2)
end

function FireLaser:goRight()
    Game.world.map:getEvent(32):slideTo(1520, 400, 2)
end

return FireLaser