local Room1, super = Class(Map)

function Room1:onEnter()
    super.onEnter(self)
    Game.world:spawnObject(FireBG(0, 0), "objects_bg")
end

return Room1