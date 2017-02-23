local inspect = require 'lib.inspect'
local anim8 = require 'lib.anim8'
Object = require "lib.classic"

require 'player'
require 'effects'
require 'combos'
require 'world'

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

	world = World()
	player = Player(world)

	aa_combo = Combo({Step("a", 0.5), Step("a", 0.5)})

end


function love.keypressed(key)
	player:handle_input(key)
	if key == "a" then
		print("a pressed")
	end
	if key == "s" then
		print("s pressed")
	end
end

function love.keyreleased(key)
   if aa_combo:check_key(key, 0.2) then
		print("a combo")
		slow_time = 10
	end

	if key == "space" then
   		if player.vel.y <= player.jump_cutoff then
   			player.vel.y = player.jump_cutoff
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
	love.graphics.line(0, world.ground + player.scale * 32 + 1, love.graphics.getWidth(), world.ground + player.scale * 32 + 1)
end