ExpandPaddlePowerup = Class { __include = Powerup }

function ExpandPaddlePowerup:apply(playState)
    playState.paddle.size = math.min(4, playState.paddle.size + 1)
end
