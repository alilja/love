-- okay round two
-- we're using a graph
-- each node is an attack state — either the finished move or a null period where we wait for more input
-- moves also control how long you have to activate them
-- e.g. if you press a once, the move (node) determines that you have, say, 0.1 seconds to press another key
	-- and trigger another combo before it just triggers the a move
-- connecting each node is the lines that represent the inputs
-- steps are lines, moves are nodes
-- every time we get an input, check to see if it matches any lines coming out of the current node
-- if it matches a key on a line, check to see if the time-to-press matches
-- faster has priority over slower
-- if nothing matches, reset the system
-- keep walking the graph until you reach an end (trigger the move) or you reset


-- functionally, each combo beginning with a different keypress is a different combotree
-- this is a pretty basic implementation and is not error robust
-- please be gentle with my simple, dumb little combo machine

local inspect = require 'lib.inspect'

Move = Object:extend() -- branches
function Move:new(time)
	self.time = time or 0.2

	self.id = 0

	self.next_step = nil
	self.prev_step = nil
end


Step = Object:extend() -- nodes
function Step:new(button)
	self.button = button

	self.id = 0

	self.next_moves = {}
	self.prev_move = nil

	self.root = nil
end

ComboTree = Object:extend()
function ComboTree:new()
	self.steps = {}
	self.moves = {}
end

function ComboTree:add_step(step) -- nodes
	if type(step) == "string" then step = Step(step) end
	if self:_exists(step, self.steps) then return false end
	step.id = #self.steps + 1
	table.insert(self.steps, step)
	return step
end

-- TODO: ideally you should be able to do
-- ComboTree():button("a"):time(0.2):button("b"):time(0.2):button("a"):time(0.1)
-- work on that, okay

function ComboTree:connect_steps(step1, step2, move)
	-- take two steps (nodes, buttons) and tie them together with a move
	-- 1. check if the move already exists, and if not, add it
	if not self:_exists(move, self.moves) then
		table.insert(self.moves, move)
		move.id = #self.moves + 1
	else
		return "move " .. move.id .. " connecting " .. move.prev_step " to " .. inspect(move.next_steps) .. " already exists"
	end

	-- 2. update the steps with information about their new move
	-- step1 is closer to the root, step2 is further away
	if step2.prev_move ~= nil then
		return "step2 " .. step2.id .. " already has a previous move"
	else
		step2.prev_move = move
		self:add_step(step2)
	end
	table.insert(step1.next_moves, move)
	self:add_step(step1)

	move.prev_step = step1
	move.next_step = step2
end

function ComboTree:find_root()
	-- find the step with no prev_move
	for _, step in ipairs(self.steps) do
		if step.prev_move == nil then return step end
	end
	return nil
end

function ComboTree:render_tree(step)
	if step == nil then step = self:find_root() end -- if we aren't given a step, start from the root
	if step.next_moves == {} then return "branch ends at " .. step.button end -- if the next_move of this step is empty,
																			  -- we've reached the end of the branch
	-- if it's not empty...
	for _, next_move in ipairs(step.next_moves) do -- walk the list of all the different moves attached to this step
		next_step = next_move.next_step -- grab the step attached to that move
		print(step.button .. " connected to " .. next_step.button .. " by " .. next_move.time .. " seconds.")
		self:render_tree(next_step)
	end
end

function ComboTree:_exists(graph_item, category)
	if category == {} or category == nil then return false end
	for _, item in ipairs(category) do
		if graph_item == item then return true end
	end
	return false
end


ComboManager = Object:extend()
function ComboManager:new(combos)
	self.combos = {}
	for _, combo in ipairs(combos) do
		self.combos[combo:find_root()] = combo
	end

	self.current_step = nil
	self.completed_steps = {}
	self.time_since_last_keypress = 0

end

function ComboManager:check(key)
	-- we'll be in a certain STEP
	-- check to see if there are any attached moves with times less than the last keypress time
	-- if there are, move to the next step, reset the timer, and add this step to the list of completed ones
	-- if there are more than one, return the fastest one
	-- if there's a move that matches but no final step attached to it, we're at branch end
		-- in that case, go ahead and return the combo

	if self.current_step == nil then -- check to see if the key exists as a potential combo starter
		if self.combos[key] == nil then return nil end -- no such starting combo exists; we can safely ignore this
		self.current_step = self.combos[key][1] -- grab the first step object in the combo
	end

	self.time_since_last_keypress = 0
end

function ComboManager:update(dt)
	self.time_since_last_keypress = self.time_since_last_keypress + dt
end

