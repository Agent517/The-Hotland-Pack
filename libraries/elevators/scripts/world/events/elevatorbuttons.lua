local ElevatorButtons, super = Class(Event)

function ElevatorButtons:init(data)
    super.init(self, data.x, data.y, data.width, data.height)
end

function ElevatorButtons:postLoad()
    self.elevator = Game.world.map:getEvent("elevator")
end

function ElevatorButtons:onInteract(chara)
    Game.world:startCutscene(function(cutscene)
        cutscene:text("* (Where will you ride the elevator to?)")

        local names = {}
        for i, floor in ipairs(self.elevator.floors) do
            names[i] = floor.name
        end

        local incmenu
        if AbstractMenuComponent then -- If this returns anything, we can use the new UI system!
            incmenu = ElevatorMenu(self.elevator)
        else -- If not, then we're using a Kristal version from before the UI system was added, so we use this old version of the menu.
            incmenu = IncMenu({1, #self.elevator.floors}, self.elevator.current_floor)
        end
        incmenu.elevatormode = true
        Game.world:spawnObject(incmenu, "ui")
        cutscene:wait(function() return incmenu.decision end)
        local decision = incmenu.decision
        incmenu:remove()
        if decision == self.elevator.current_floor then
            if Input.pressed("cancel") or incmenu.cancel then return end
            cutscene:text("* (You're there.)")
            return
        end
        self.elevator:moveTo(decision)
    end)
    return true
end

return ElevatorButtons