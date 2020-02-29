minetest.register_node( "automatica:dev_conveyor_belt", {
	description = "conveyor Belt (dev)",
	drawtype = "drawtype",
	tiles = { {
		name = "conveyor_belt.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 0.5,
		},
	} },
	on_timer = function ( pos, elapsed )
		--print( "On Timer" )
		local newPos = { x = pos.x, y = pos.y+1, z = pos.z }
		local myNodeAbove = minetest.get_node( newPos )
		if myNodeAbove.name ~= "air" then
			print( myNodeAbove.name )
		end

		local myObjects = minetest.get_objects_inside_radius( newPos, 1 )
		if myObjects ~= nil then
			for i=1, #myObjects do
				myObjects[i]:add_velocity( { x=0, y=0, z=.2 } )
			end
		end
		--get player
		--check to see if the block below player is a conveyor belt
		--if it is get the dir and speed
		--apply those to the player, unless the player already has them
		--[[local player = minetest.get_meta()
		local playerPos = player:get_pos()
		local below = { x = playerPos.x, y = playerPos.y-1, z = playerPos.z }
		local myNodeBelow = minetest.get_node( below )
		print( dump( myNodeBelow ) )
		if myNodeBelow.name == "automatica:dev_conveyor_belt" then
			print( "Velociting" )
			player:add_player_velocity( { x=0, y=0, z=0.5 } )
		end]]

		minetest.get_node_timer( pos ):set( 1, 1 )
	end,
	after_place_node = function ( pos, placer, itemstack, pointed_thing )
		print( "After place" )
		minetest.get_node_timer( pos ):set( 1, 1 )
		local dir = placer:get_look_dir()
		print( dump( dir ) )
		local myNode = minetest.get_node( pos )
		--myNode:set_rotation( { pitch = 0, yaw = 1.5, roll = 0 } )
	end,
	on_punch = function( pos, node, puncher, pointed_thing )
		print( "on_punch" )
		print( dump( node ) )
	end,
})

local conveyor_belt_timer = 0
local conveyor_belt_timer_step = 0.1

function conveyor_belt_step( player, conveyor_belt_timer )
	local playerPos = player:get_pos()
	local below = { x = playerPos.x, y = playerPos.y-1, z = playerPos.z }
	local myNodeBelow = minetest.get_node( below )
	print( dump( myNodeBelow ) )
	if myNodeBelow.name == "automatica:dev_conveyor_belt" then
		print( "Velociting" )
		player:add_player_velocity( { x=0, y=0, z=0.5 } )
	end
end

minetest.register_globalstep( function( timeDiff )
	conveyor_belt_timer = conveyor_belt_timer + timeDiff
	if conveyor_belt_timer >= conveyor_belt_timer_step then
		for _, player in ipairs( minetest.get_connected_players() ) do
			conveyor_belt_step( player, conveyor_belt_timer )
		end
		jetpack_timer = 0
	end
end)
