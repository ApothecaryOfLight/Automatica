local function get_dir( inRelPos )
	local x = inRelPos.x
	local z = inRelPos.z
	local a = x+z > 0
	local b = x-z > 0
	if a and b then
		return 0
	elseif not a and b then
		return 1
	elseif not a and not b then
		return 2
	elseif a and not b then
		return 3
	end
end

local function do_rotation( itemstack, placer, pointed_thing )
	local dir = placer:get_look_dir()
	local p1 = pointed_thing.above
	local placer_pos = placer:get_pos()
	local param2 = minetest.dir_to_facedir(vector.subtract(p1, placer_pos))
	return minetest.item_place( itemstack, placer, pointed_thing, param2 )
end

local conveyor_collisions = {
	{ -0.4, -0.5, -0.56, .4, -0.26, .56 },
	{ -0.5, -0.5, -0.56, -0.6, 0.2, .56 },
	{ 0.5, -0.5, -0.56, .6, 0.2, .56 }
}
minetest.register_node( "automatica:dev_conveyor_belt", {
	description = "conveyor Belt (dev)",
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propogates = true,
	groups = { cracky = 3; choppy = 1; punch_operable = 1 },
	collision_box = {
		type = "fixed",
		fixed = conveyor_collisions
	},
	selection_box = {
		type = "fixed",
		fixed = conveyor_collisions
	},
	node_box = {
		type = "fixed",
		fixed = conveyor_collisions
	},
	visual_scale = "mesh",
	mesh = "dev_conveyor_mid.b3d",
	on_timer = function ( pos, elapsed )
		--print( "On Timer" )
		local newPos = { x = pos.x, y = pos.y, z = pos.z }
		local myNodeAbove = minetest.get_node( newPos )
		local myObjects = minetest.get_objects_inside_radius( newPos, .75 )
		if myObjects ~= nil and #myObjects >= 1 then
			--local myStoredObjects = {}
			for i=1, #myObjects do
				--print( dump( getmetatable( myObjects[i]:get_luaentity().object ) ) )
				--myStoredObjects[i] = myObjects[i]
				local myName = myObjects[i]:get_player_name()
				local myVelocity = myObjects[i]:get_velocity() or
					myObjects[i]:get_player_velocity()
				local myPos = myObjects[i]:get_pos()
				local myMeta = minetest.get_meta( pos )
				local myDir = myMeta:get_int( "dir" )

				--[[print( "======> BELT POS" )
				print( dump( pos ) )
				print( "======> OBJ VEL" )
				print( dump( myVelocity ) )
				print( "======> OBJ POS" )
				print( dump( myPos ) )]]

				if pos.y+.5 < myPos.y or
					pos.x+1 > myPos.x or pos.X-1 < myPos.x or
					pos.z+1 > myPos.z or pos.Z-1 < myPos.z then
					if math.abs( myVelocity.x ) + math.abs( myVelocity.z ) == 0 then
						print( "Jammed object!" )
						--if myStoredObjects[ (myPos.x*30000)+myPos.z ] ~= nil then
						myObjects[i]:set_pos( { x = pos.x, y = pos.y, z = pos.z } )
						--	myStoredObjects[ (myPos.x * 30000)+myPos.z ] = nil
						--else
						--	myStoredObjects[ (myPos.x * 30000)+myPos.z ] = myObjects[i]
						--end
					end
				end

				local myAddingVelocity = {
					x = 0,
					y = -3,
					z = 0
				}
				if myDir == 0 then
					myAddingVelocity.x = .7
				elseif myDir == 1 then
					myAddingVelocity.z = -0.7
				elseif myDir == 2 then
					myAddingVelocity.x = -0.7
				elseif myDir == 3 then
					myAddingVelocity.z = .7
				end
				if math.abs(myVelocity.z)+math.abs(myVelocity.x) < 0.5 then
					local done = myObjects[i]:add_velocity(
						myAddingVelocity
					) or myObjects[i]:add_player_velocity(
						{
							x = myAddingVelocity.x*4,
							y = -3,
							z = myAddingVelocity.z*4
						}
					)
				end
			end
		end
		minetest.get_node_timer( pos ):set( 0.1, 0 )
	end,
	after_place_node = function ( pos, placer, itemstack, pointed_thing )
		print( "After place" )

		local dir = placer:get_look_dir()
		local myDir = get_dir( dir )
		local myMeta = minetest.get_meta( pos )
		myMeta:set_int( "dir", myDir )

		minetest.get_node_timer( pos ):set( 0.1, 0 )
	end,
	on_place = function( itemstack, placer, pointed_thing )
		return do_rotation( itemstack, placer, pointed_thing )
	end,
	on_punch = function( pos, node, puncher, pointed_thing )
		print( "on_punch" )
		print( dump( node ) )
	end,
})

local conveyor_turn_collisions = {
	{ -0.6, -0.5, -0.56, .6, -0.26, .56 },
	{ 0.5, -0.5, -0.56, .6, 0.2, .56 },
	{ 0.5, -0.5, 0.56, -0.6, 0.2, .4 }
}
minetest.register_node( "automatica:dev_conveyor_turn", {
	description = "conveyor Belt Turn(dev)",
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propogates = true,
	groups = { cracky = 3; choppy = 1; punch_operable = 1 },
	collision_box = {
		type = "fixed",
		fixed = conveyor_turn_collisions
	},
	selection_box = {
		type = "fixed",
		fixed = conveyor_turn_collisions
	},
	node_box = {
		type = "fixed",
		fixed = conveyor_turn_collisions
	},
	visual_scale = "mesh",
	mesh = "dev_conveyor_turn.b3d",
	on_timer = function ( pos, elapsed )
		--print( "On Timer" )
		local newPos = { x = pos.x, y = pos.y, z = pos.z }
		local myNodeAbove = minetest.get_node( newPos )
		local myObjects = minetest.get_objects_inside_radius( newPos, .75 )
		if myObjects ~= nil and #myObjects >= 1 then
			for i=1, #myObjects do
				local myName = myObjects[i]:get_player_name()
				local myVelocity = myObjects[i]:get_velocity() or
					myObjects[i]:get_player_velocity()
				local myMeta = minetest.get_meta( pos )
				local myDir = myMeta:get_int( "dir" )



				local myPos = myObjects[i]:get_pos()
				if pos.y+.5 < myPos.y or
					pos.x+1 > myPos.x or pos.X-1 < myPos.x or
					pos.z+1 > myPos.z or pos.Z-1 < myPos.z then
					if math.abs( myVelocity.x ) + math.abs( myVelocity.z ) == 0 then
						print( "Jammed object!" )
						--if myStoredObjects[ (myPos.x*30000)+myPos.z ] ~= nil then
						myObjects[i]:set_pos( { x = pos.x, y = pos.y, z = pos.z } )
						--	myStoredObjects[ (myPos.x * 30000)+myPos.z ] = nil
						--else
						--	myStoredObjects[ (myPos.x * 30000)+myPos.z ] = myObjects[i]
						--end
					end
				end


				local myAddingVelocity = {
					x = 0,
					y = -3,
					z = 0
				}
				if myDir == 1 then
					myAddingVelocity.x = .7
				elseif myDir == 2 then
					myAddingVelocity.z = -0.7
				elseif myDir == 3 then
					myAddingVelocity.x = -0.7
				elseif myDir == 0 then
					myAddingVelocity.z = .7
				end
				if math.abs(myVelocity.z)+math.abs(myVelocity.x) < 0.5 then
					local done = myObjects[i]:add_velocity(
						myAddingVelocity
					) or myObjects[i]:add_player_velocity(
						{
							x = myAddingVelocity.x*4,
							y = -3,
							z = myAddingVelocity.z*4
						}
					)
				end
			end
		end
		minetest.get_node_timer( pos ):set( 0.1, 0 )
	end,
	after_place_node = function ( pos, placer, itemstack, pointed_thing )
		print( "After place" )

		local dir = placer:get_look_dir()
		local myDir = get_dir( dir )
		local myMeta = minetest.get_meta( pos )
		myMeta:set_int( "dir", myDir )

		minetest.get_node_timer( pos ):set( 0.1, 0 )
	end,
	on_place = function( itemstack, placer, pointed_thing )
		return do_rotation( itemstack, placer, pointed_thing )
	end,
	on_punch = function( pos, node, puncher, pointed_thing )
		print( "on_punch" )
		print( dump( node ) )
	end,
})


minetest.register_node( "automatica:dev_conveyor_end", {
	description = "Conveyor Belt End (dev)",
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propogates = true,
	groups = { cracky = 3; choppy = 1; punch_operable = 1 },
	collision_box = {
		type = "fixed",
		fixed = {
			 { -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			 { -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
		},
	},
	node_box = {
		type = "fixed",
		fixed = {
			 { -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
		},
	},
	visual_scale = "mesh",
	mesh = "dev_conveyor_end.b3d",
	on_timer = function ( pos, elapsed )
		local newPos = { x = pos.x, y = pos.y, z = pos.z }
		local myNodeAbove = minetest.get_node( newPos )
		local myObjects = minetest.get_objects_inside_radius( newPos, .75 )
		if myObjects ~= nil and #myObjects >= 1 then
			for i=1, #myObjects do
				local myName = myObjects[i]:get_player_name()
				local myVelocity = myObjects[i]:get_velocity() or
					myObjects[i]:get_player_velocity()
				local myMeta = minetest.get_meta( pos )
				local myAddingVelocity = {
					x = myVelocity.x*-1,
					y = -3,
					z = myVelocity.z*-1
				}
				local done = myObjects[i]:add_velocity(
					myAddingVelocity
				) or myObjects[i]:add_player_velocity(
					{
						x = myAddingVelocity.x,
						y = -3,
						z = myAddingVelocity.z
					}
				)
			end
		end
		minetest.get_node_timer( pos ):set( 1, 1 )
	end,
	after_place_node = function ( pos, placer, itemstack, pointed_thing )
		print( "After place" )

		local dir = placer:get_look_dir()
		local myDir = get_dir( dir )
		local myMeta = minetest.get_meta( pos )
		myMeta:set_int( "dir", myDir )

		minetest.get_node_timer( pos ):set( 1, 1 )
	end,
	on_place = function( itemstack, placer, pointed_thing )
		return do_rotation( itemstack, placer, pointed_thing )
	end,
	on_punch = function( pos, node, puncher, pointed_thing )
		print( "on_punch" )
		print( dump( node ) )
	end,
})

--local dev_conveyor_ladder_up_dimensions = { -0.5, -0.5, .25, 0.5, 0.5, .5 }
local dev_conveyor_ladder_up_dimensions = {
	{ -0.5, -0.5, -0.5, 	0.5, -0.45, -0.4 },
	{ -0.5, -0.45, -0.4, 	0.5, -0.35, -0.3 },
	{ -0.5, -0.35, -0.3, 	0.5, -0.25, -0.2 },
	{ -0.5, -0.25, -0.2, 	0.5, -0.15, -0.1 },
	{ -0.5, -0.15, -0.1, 	0.5, -0.05, 0.0 },
	{ -0.5, -0.05, 0.0, 	0.5, 0.05, 0.1 },
	{ -0.5, 0.05, 0.1, 	0.5, 0.15, 0.2 },
	{ -0.5, 0.15, 0.2, 	0.5, 0.25, 0.3 },
	{ -0.5, 0.25, 0.3, 	0.5, 0.35, 0.4 },
	{ -0.5, 0.35, 0.4, 	0.5, 0.45, 0.5 },
}
minetest.register_node( "automatica:dev_conveyor_slope_up", {
	description = "conveyor Belt Slope Up (dev)",
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propogates = true,
	groups = { cracky = 3; choppy = 1; punch_operable = 1 },
	collision_box = {
		type = "fixed",
		fixed = dev_conveyor_ladder_up_dimensions
	},
	selection_box = {
		type = "fixed",
		fixed = dev_conveyor_ladder_up_dimensions
	},
	node_box = {
		type = "fixed",
		fixed = dev_conveyor_ladder_up_dimensions
	},
	visual_scale = "mesh",
	mesh = "dev_conveyor_slope_up.b3d",
	on_timer = function ( pos, elapsed )
		local newPos = { x = pos.x, y = pos.y, z = pos.z }
		local myNodeAbove = minetest.get_node( newPos )

		local myObjects = minetest.get_objects_inside_radius( newPos, 1 )
		if myObjects ~= nil and #myObjects >= 1 then
			for i=1, #myObjects do
				--local myName = myObjects[i]:get_player_name()
				local myVelocity = myObjects[i]:get_velocity() or
					myObjects[i]:get_player_velocity()
				local myMeta = minetest.get_meta( pos )
				local myDir = myMeta:get_int( "dir" )
				local myPos = myObjects[i]:get_pos()


				local forwardPosition
				if myDir == 0 or myDir == 2 then
					forwardPosition = myPos.x-pos.x
				elseif myDir == 1 or myDir == 3 then
					forwardPosition = myPos.z-pos.z
				end
				if pos.y+.5 < myPos.y or
					pos.x+1 > myPos.x or pos.x-1 < myPos.x or
					pos.z+1 > myPos.z or pos.z-1 < myPos.z then
					if math.abs( myVelocity.x ) + math.abs( myVelocity.z ) == 0 then
						print( "Jammed object on slope!" )
						--if myStoredObjects[ (myPos.x*30000)+myPos.z ] ~= nil then
						--myObjects[i]:set_pos( { x = pos.x, y = pos.y+forwardPosition, z = pos.z } )
						--	myStoredObjects[ (myPos.x * 30000)+myPos.z ] = nil
						--else
						--	myStoredObjects[ (myPos.x * 30000)+myPos.z ] = myObjects[i]
						--end
					end
				end


				local myAddingVelocity = {
					x = 0,
					y = 2,
					z = 0
				}
				if myVelocity.y < 0 then
					myAddingVelocity.y = myAddingVelocity.y + (myVelocity.y * -1)
				end
				if myDir == 0 then
					myAddingVelocity.x = .7
				elseif myDir == 1 then
					myAddingVelocity.z = -.7
				elseif myDir == 2 then
					myAddingVelocity.x = -.7
				elseif myDir == 3 then
					myAddingVelocity.z = .7
				end
				if myVelocity.y < 5 then
					local done = myObjects[i]:add_velocity(
						myAddingVelocity
					) or myObjects[i]:add_player_velocity(
						{
							x = myAddingVelocity.x*4,
							y = 0,
							z = myAddingVelocity.z*4
						}
					)
				end
			end
		end
		local abovePos = { x = pos.x, y = pos.y+1, z = pos.z }
		--[[local myObjectsAbove = minetest.get_objects_inside_radius( abovePos, .75 )
		if myObjectsAbove ~= nil and #myObjectsAbove >= 1 then
			for i=1, #myObjectsAbove do
				local myMeta = minetest.get_meta( pos )
				local myDir = myMeta:get_int( "dir" )
				--print( myDir )
				local myAddingVelocity = {
					x = 0,
					y = 1,
					z = 0
				}
				if myDir == 0 then
					myAddingVelocity.x = 2
				elseif myDir == 1 then
					myAddingVelocity.z = -2
				elseif myDir == 2 then
					myAddingVelocity.x = -2
				elseif myDir == 3 then
					myAddingVelocity.z = 2
				end
				--if myVelocity.y < 5 then
					local done = myObjectsAbove[i]:add_velocity(
						myAddingVelocity
					) or myObjectsAbove[i]:add_player_velocity(
						{
							x = myAddingVelocity.x*4,
							y = 3,
							z = myAddingVelocity.z*4
						}
					)
				--end				
			end
		end]]
		minetest.get_node_timer( pos ):set( .1, 0 )
	end,
	after_place_node = function ( pos, placer, itemstack, pointed_thing )
		--print( "After place" )
		local dir = placer:get_look_dir()
		local myDir = get_dir( dir )
		local myMeta = minetest.get_meta( pos )
		myMeta:set_int( "dir", myDir )
		minetest.get_node_timer( pos ):set( 1, 1 )
	end,
	on_place = function( itemstack, placer, pointed_thing )
		return do_rotation( itemstack, placer, pointed_thing )
	end,
})

--TODO: Add a timer that is canceled when preview doesn't exist
--TODO: But when the preview does exist, tick towards completiong.
--TODO: Introduce faster and powered autocrafters.
--TODO: Add an invisible in slot
local myFormspec = "size[8,9;]"..
	"list[context;recipe;2,0;3,3;]"..
	"list[context;product;3,3;1,1;]"..
	"list[current_player;main;0,5;7,4;]"

local function check_recipe ( inInventory )
	local result, needed, input
	needed = inInventory:get_list( 'recipe' )
	output, input = minetest.get_craft_result( {
		method = 'normal',
		width = 3,
		items = needed
	})
	for i=1,9 do
		local myStack = inInventory:get_stack( 'recipe', i )
		if myStack then
			print( "hmmmmz" )
			local myStackCount = myStack:get_count()
			print( myStackCount )
			if myStackCount == 1 then
				print( "Down to recipe!" )
				return output.item:get_name(), 1
			end
		end
	end
	return output.item:get_name(), 2
end

local function sort_inventory( inInventory, inListName )
	print( "\n\nsort_inventory" )
	local myStacksList = {}
	for i=1,9 do
		local myStack = inInventory:get_stack( inListName, i )
		if myStack then
			local myItemName = myStack:get_name()
			local myStackCount = myStack:get_count()
			myStacksList[i] = {
				name = myItemName,
				count = myStackCount,
				list = {}
			}
			for a=1,9 do
				local myCheckStack = inInventory:get_stack( inListName, a )
				local myCheckItemName = myCheckStack:get_name()
				local myCheckStackCount = myCheckStack:get_count()
				if myItemName == myCheckItemName and a ~= i then
					table.insert( myStacksList[i].list, a )
					myStacksList[i].count = myStacksList[i].count + myCheckStackCount
				end
			end
		end
	end
--TODO: Implement remainder that gets dispersed across all available stacks.
	for b=1,9 do
		if myStacksList[b] then
			local myTotalCount = myStacksList[b].count
			local myTotalNumberOfStacks = #myStacksList[b].list + 1
			local newSize = math.floor( myTotalCount / myTotalNumberOfStacks )

			print( "myTotalCount: "..myTotalCount )
			print( "myTotalNumberOfStacks: "..myTotalNumberOfStacks )
			print( newSize )

			local myItemString = myStacksList[b].name.." "..newSize
			print( myItemString )

			if #myStacksList[b].list >= 2 and myTotalCount >= #myStacksList[b].list*2 then
				inInventory:set_stack( 'recipe', b, ItemStack( myItemString ) )
				print( "Transfering..." )
				for _,v in pairs( myStacksList[b].list ) do
					inInventory:set_stack( 'recipe', v, ItemStack( myItemString ) )
				end
			end
		end
	end

end

local function decrement_inventory( inInventory )
	for i=1,9 do
		local myStack = inInventory:get_stack('recipe',i)
		if myStack then
			local myCount = myStack:get_count()
			if myCount > 1 then
				local myName = myStack:get_name()
				local myDecrementedCount = myCount-1
				local myItemString = myName.." "..myDecrementedCount
				inInventory:set_stack( 'recipe', i, ItemStack( myItemString ) )
			end
		end	
	end
end

local function show_preview( inInventory, inProduct )
	--print( "show_preview" )
	--print( inProduct )
	inInventory:set_stack( 'product', 1, ItemStack( inProduct ) )
end

local function make_craft( inInventory, inProduct )
	--print( "make_craft" )
	--print( "Making "..inProduct )
	inInventory:set_stack( 'out', 1, ItemStack( inProduct ) )
end

local function clear_preview( inInventory )
	--print( "clear_preivew" )
	inInventory:set_stack( 'product', 1, ItemStack("") )
end

local function process_inventory( pos, listname )
	local myMeta = minetest.get_meta( pos )
	if listname == 'recipe' then
		sort_inventory( myMeta:get_inventory(), 'recipe' )
	end
	local myInventory = myMeta:get_inventory()
	local product, count = check_recipe( myInventory )
	if product == "" then
		clear_preview( myInventory )
		return
	end
	if count >= 1 then
		show_preview( myInventory, product )
	end
	if count == 2 then
		make_craft( myInventory, product )
		decrement_inventory( myInventory )
	end
end

minetest.register_node( "automatica:dev_autocrafter", {
	description = "Dev Autocrafter",
	drawtype = "normal",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propogates = true,
	groups = { cracky = 3; choppy = 1; punch_operable = 1 },
	mesh = "dev_conveyor_slope_up.b3d",
	after_place_node = function ( pos, placer, itemstack, pointed_thing )
		local myMeta = minetest.get_meta( pos )
		local myInv = myMeta:get_inventory()
		myInv:set_size( 'in', 1 )
		myInv:set_size( 'product', 1 )
		myInv:set_size( 'recipe', 9 )
		myInv:set_size( 'out', 1 )
		myMeta:set_string( "formspec", myFormspec )
	end,
	on_place = function( itemstack, placer, pointed_thing )
		return do_rotation( itemstack, placer, pointed_thing )
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		process_inventory( pos, listname )
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		process_inventory( pos, listname )
	end,
	on_metadata_inventory_move = function(pos, listname, from_index, to_list, to_index, count, player)
		process_inventory( pos, listname )
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname == 'recipe' then
			return stack:get_count()
		elseif listname == 'out' then
			--[[local myMeta = minetest.get_meta( pos )
			local myInventory = myMeta:get_inventory()
			local myStack = myInventory:get_stack( 'product', 1 )
			--print( myStack:get_count() )

			local number_of_products = myStack:get_count()
			if number_of_products ~= nil then
				if number_of_products > 1 then
					return number_of_products-1
				end
			end
			return 0
		else
			return 0]]
			return 1
		end
	end,
})

if minetest.get_modpath("hopper") then
--print( "adding hopper config" )
	hopper:add_container({
		{"top", "automatica:dev_autocrafter", "out"},
		{"side", "automatica:dev_autocrafter", "recipe"},
		{"bottom", "automatica:dev_autocrafter", "recipe"},
	})
end
