PlusHealthPowerup = Class { __includes = Powerup }

function PlusHealthPowerup:init(spawnTime)
    self:init(s)
end

function PlusHealthPowerup:apply(playState)
    playState.maxHealth = math.min(5, playState.maxHealth + 1)
end