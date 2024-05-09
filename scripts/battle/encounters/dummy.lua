local Dummy, super = Class(Encounter)

function Dummy:init()
    super.init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* Defuse the dummy...?"

    -- Battle music ("battle" is rude buster)
    self.music = "mus_news_battle"
    -- Enables the purple grid battle background
    self.background = true

    -- Add the dummy enemy to the encounter
    self:addEnemy("dummy")

    --- Uncomment this line to add another!
    --self:addEnemy("dummy")

    self.defuser = DefuseZone(500, 128, 100, 50)
    Game.battle:addChild(self.defuser)
    self.siner = 0
end

function Dummy:update()
end

function Dummy:beforeStateChange(old, new)
    if new == "VICTORY" then
        Game.battle:setState("TRANSITIONOUT")
    elseif new == "DEFENDINGBEGIN" then
        Game.battle:setState("ACTIONSELECT")
    end
end

return Dummy