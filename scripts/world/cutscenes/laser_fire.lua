return {
    detachparty = function (cutscene, event)
        local p2 = cutscene:getCharacter(Game.party[2].actor.id)
        local p3 = cutscene:getCharacter(Game.party[3].actor.id)
        if not p2.following then return end
        cutscene:detachFollowers()
        cutscene:walkTo(p2, "p2", 0.5)
        cutscene:walkTo(p3, "p3", 0.5)
        cutscene:wait(0.5)
        p2:setFacing("down")
        p3:setFacing("down")
    end,

    attachparty = function (cutscene,event)
        cutscene:attachFollowers()
    end
}