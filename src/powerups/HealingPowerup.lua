
HealingPowerup = Class { __includes = Powerup }

function HealingPowerup:apply(playState)
    playState.health = math.min(playState.maxHealth, playState.health + 1)
end