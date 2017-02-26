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

	combos = ComboTree()
	a = combos:add_step("a")
	b = combos:add_step("b")
	combos:connect_steps(a, b, Move(0.3))
	combos:connect_steps(a, combos:add_step("c"), Move(0.1))
	combos:connect_steps(b, combos:add_step("d"), Move(0.5))
	print("walking...")
	combos:render_tree()
end


function love.keypressed(key)
	player:handle_input(key)
end

function love.keyreleased(key)
	if key == "space" then
   		if player.vel.y <= player.jump_cutoff then
   			player.vel.y = player.jump_cutoff
   		end
   end
   if key == "s" then
   	world:slow(5, 5, 1)
   end
	active_combo = combos:check(key)
	print(active_combo)
end

function love.update(dt)
	player:update(world:calculate_slow_time(dt))
end

function love.draw()
	player:draw()
	love.graphics.line(0, world.ground + player.scale * 32 + 1, love.graphics.getWidth(), world.ground + player.scale * 32 + 1)
end