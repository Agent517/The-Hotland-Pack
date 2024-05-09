local Dummy, super = Class(EnemyBattler)

function Dummy:init()
    super.init(self)

    -- Enemy name
    self.name = "Dummy Bomb"
    -- Sets the actor, which handles the enemy's sprites (see scripts/data/actors/dummy.lua)
    self:setActor("dummy")

    -- Enemy health
    self.max_health = 450
    self.health = 450
    -- Enemy attack (determines bullet damage)
    self.attack = 4
    -- Enemy defense (usually 0)
    self.defense = 0
    -- Enemy reward
    self.money = 100

    -- Mercy given when sparing this enemy before its spareable (20% for basic enemies)
    self.spare_points = 0

    -- List of possible wave ids, randomly picked each turn
    self.waves = {
        --"basic",
        --"aiming",
        --"movingarena"
    }

    -- Dialogue randomly displayed in the enemy's speech bubble
    self.dialogue = {
        "[wave:3][speed:0.5]Tick... ",
        "[wave:3][speed:0.5]Tock... "
    }

    -- Check text (automatically has "ENEMY NAME - " at the start)
    self.check = "Despite the name, this one is not a dud."

    -- Text randomly displayed at the bottom of the screen each turn
    self.text = {
        "* The bomb is still active!",
    }
    -- Text displayed at the bottom of the screen when the enemy has low health
    self.low_health_text = "* The dummy looks like it's\nabout to fall over."

    self:registerAct("Defuse Bomb", "Aim for\ndefuse\nzone!", "all")

    -- Hitbox used for bomb purposes
    self:setHitbox(0,0,self.width,self.height)
    
    self.siner = 0

end

function Dummy:update()
    super.update(self)
    -- Once the battle has properly started, this enemy will move up and down in a sine motion.
    if Game.battle.state ~= "TRANSITION" and Game.battle.state ~= "INTRO" and not self.defused and not self.lock_movement then
        if not self.start_x then
            self.start_x = self.x
            self.start_y = self.y
        end
        self.siner = self.siner + DT
        self.y = self.start_y + math.sin(self.siner*2) * 120
    end    
end

function Dummy:onAct(battler, name)
    if name == "Defuse Bomb" then
        local result
        for i, defuser in ipairs(Game.world.stage:getObjects(DefuseZone)) do
            result = defuser:defuse(self)
            if result == true then break end
        end
        self:onDefuse(result)
        if result == true then
            Assets.playSound("break2")
            return "[noskip]* Bomb defused![wait:1s]"
        else
            Assets.playSound("break1")
            return "* Defuse failed![wait:5]\n* Aim for DEFUSE ZONE!"
        end
    elseif name == "Standard" then --X-Action
        return "* "..battler.chara:getName().." tried something.[wait:10] Nothing happened."
    end

    -- If the act is none of the above, run the base onAct function
    -- (this handles the Check act)
    return super.onAct(self, battler, name)
end

function Dummy:onDefuse(success)
    if success then
        self.defused = true
        self:statusMessage("msg", "defuse")
        self.color = COLORS.lime
        Game.battle.timer:after(0.5, function ()
            self:spare()
        end)
    else
        self:statusMessage("msg", "miss")
        self:mercyFlash()
    end
end

function Dummy:hurt(amount, battler, on_defeat, color, show_status, attacked)
    if amount == 0 or (amount < 0 and Game:getConfig("damageUnderflowFix")) then
        if show_status ~= false then
            self:statusMessage("msg", "miss", color or (battler and {battler.chara:getDamageColor()}))
        end

        self:onDodge(battler, attacked)
        return
    end

    -- Don't take damage
    --self.health = self.health - amount
    if show_status ~= false then
        --self:statusMessage("damage", amount, color or (battler and {battler.chara:getDamageColor()}))
    end

    if amount > 0 then
        self.hurt_timer = 1
        self:onHurt(amount, battler)
    end

    self:checkHealth(on_defeat, amount, battler)
end



return Dummy