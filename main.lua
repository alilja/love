local inspect = require 'lib.inspect'
local anim8 = require 'lib.anim8'
Object = require "lib.classic"
require 'player'

function load_animation(animation_list, dir, format)
	dir = dir or "images/"
	format = format or ".png"
	animations = {}
	for i, anim_params in ipairs(animation_list) do
		name = anim_params[1]
		file = anim_params[2]
		frames = anim_params[3]
		flip = anim_params[4]
		animations[name] = {["image"] = nil, ["animation"] = nil}
		animations[name]["image"] = love.graphics.newImage(dir .. file .. format)
		local g = anim8.newGrid(32, 32, animations[name]["image"]:getWidth(), animations[name]["image"]:getHeight())
		if flip then
			animations[name]["animation"] = anim8.newAnimation(g(frames,1), 0.1):flipH()
		else
			animations[name]["animation"] = anim8.newAnimation(g(frames,1), 0.1)
		end
	end
	return animations
end

function love.load()
	love.window.setMode(1216, 760, {})
	love.graphics.setBackgroundColor(89, 86, 82)
	love.graphics.setDefaultFilter("nearest")

	decay = 0.74
	acceleration = 80 -- pixels per second
	max_velocity = 400

	jump_force = -1250
	jump_cutoff = -400 -- if your speed is below this, you are fixed to this speed
					   -- basically, the lower this number, the sooner you are fixed
					   -- to a low jump
	jump_tolerance = 20 -- how far away from the ground can you be before you can
						-- trigger a jump again; the jump happens as soon as the character
						-- touches the ground

	reactivity_percent = 1.95 -- how quickly you start moving in the opposite direction

	gravity = 60
	hang_time = 0
	max_hang_time = 0.5

	jump_tolerance_trigger = false

	-- how movement changes in the air
	air_accel_control = 2.2
	air_vel_control = 0.9
	air_reactivity = 0.6
	air_decay = 0.94

	combos = {}
	combo_time = 0
	max_combo_time = 0.5

	ground = love.graphics.getHeight() - 150

	player = Player()
end

function calculate_horizontal_speed(direction, velocity)
	reactivity = reactivity_percent
	if player.is_jumping then
		acceleration = acceleration * air_accel_control
		reactivity = air_reactivity
	end
	if direction == "left" and velocity > 0 then -- moving right and press left
		velocity = velocity - (acceleration + acceleration * reactivity_percent)
	elseif direction == "right" and velocity < 0 then -- moving left and press right
		velocity = velocity + (acceleration + acceleration * reactivity_percent)
	elseif direction == "left" then
		velocity = velocity - acceleration
	elseif direction == "right" then
		velocity = velocity + acceleration
	end

	if velocity > max_velocity then velocity = max_velocity end -- cap
	if velocity < -max_velocity then velocity = -max_velocity end -- cap

	if player.is_jumping then velocity = velocity * air_vel_control end
	return velocity
end



function love.keypressed(key)
	if key == "space" and not player.is_jumping then
		player:jump()
	elseif key == "space" and player.is_jumping then
		if player.y >= ground - jump_tolerance then
			jump_tolerance_trigger = true
			print("tolerance jump")
		end
	end
	if key == "a" then
		print("a pressed")
		table.insert(combos, "a")
	end
	if key == "s" then
		print("s pressed")
		table.insert(combos, "s")
	end
end

function love.keyreleased(key)
   if key == "space" then
   		if player.vel.y <= jump_cutoff then
   			player.vel.y = jump_cutoff
   		end
   end
end

function check_combos(combos)
	if #combos == 4 then
		if combos[1] == "a" then
			if combos[2] == "s" then
				if combos[3] == "a" then
					if combos[4] == "s" then
						return "asas"
					end
				end
			end
		end
	elseif #combos == 3 then
		if combos[1] == "a" then
			if combos[2] == "s" then
				if combos[3] == "s" then
					return "ass"
				end
			end
		end
	elseif #combos == 2 then
		if combos[1] == "a" then
			if combos[2] == "a" then
				return "double a"
			end
		end
	end
	return nil
end


function love.update(dt)
	player:update(dt)
end

function love.draw()
	player:draw()
	love.graphics.line(0, ground + player.scale * 32 + 1, love.graphics.getWidth(), ground + player.scale * 32 + 1)
end