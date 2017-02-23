Effect = Object:extend()
function Effect:new(duration)
	self.duration = duration
	self.life = 0
	self.percent = 0

	FX_STATE_IN = 0
	FX_STATE_MID = 1
	FX_STATE_OUT = 2
	FX_STATE_DEAD = -1
	self.state = FX_STATE_IN
end

function Effect:update(dt)
	self.life = self.life + dt
	self.percent = self.life / self.duration
	if self.life >= self.duration then self.state = FX_STATE_DEAD end
end

--virtual function
function Effect:draw()
	return false
end

function Effect:limit(value, top, bottom)
	if top ~= nil and value > top then value = top end
	if bottom ~= nil and value < bottom then value = bottom end
	return value
end

-- easing functions from Pedro Medeiros: https://www.patreon.com/posts/animation-easing-8030922
function Effect:ease_in(t)
	return t * t * t
end

function Effect:ease_in_out(t)
	if t <= .5 then
		return t * t * t * 4
	else
		t = t - 1
		return 1 + t * t * t * 4
	end
end

function Effect:ease_out(t)
	t = t - 1
	return 1 + t * t * t
end

function Effect:ease_back_in(t)
	return t * t * (2.70158 * t - 1.70158)
end

function Effect:ease_back_out(t)
	t = t - 1
	return (1 - t * t * (-2.70158 * t - 1.70158))
end

function Effect:ease_back_in_out(t)
	t = t * 2

    if (t < 1) then
    	return t * t * (2.70158 * t - 1.70158) / 2
    else
	    t = t - 2;
	    return (1 - t * t * (-2.70158 * t - 1.70158)) / 2 + .5
	end
end

function Effect:ease_elastic_in(t)
	return math.sin(13 * (math.pi/2) * t) * math.pow(2, 10 * (t - 1))
end

function Effect:ease_elastic_out(t)
	return math.sin(-13 * (math.pi/2) * (t + 1)) * math.pow(2, -10 * t) + 1
end

function Effect:ease_elastic_in_out(t)
	if (t < 0.5) then
        return 0.5 * (math.sin(13 * (math.pi/2) * (2 * t)) * math.pow(2, 10 * ((2 * t) - 1)))
    else
    	return 0.5 * (math.sin(-13 * (math.pi/2) * ((2 * t - 1) + 1)) * math.pow(2, -10 * (2 * t - 1)) + 2)
    end
end


EffectManager = Object:extend()
function EffectManager:new()
	self.effects = {}
end

function EffectManager:update(dt)
	-- iterate backwards to avoid skipping effects
	-- see http://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating
	for i = #self.effects, 1, -1 do
		--cull dead effects
		effect = self.effects[i]
		if effect.state == FX_STATE_DEAD then
			table.remove(self.effects, i)
		else
			effect:update(dt)
		end
	end
end

function EffectManager:add(effect)
	table.insert(self.effects, effect)
end

function EffectManager:draw()
	for _, effect in ipairs(self.effects) do
		effect:draw()
	end
end