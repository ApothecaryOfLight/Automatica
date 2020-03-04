local function get_dir( inRelPos )
	local x = inRelPos.x
	local z = inRelPos.z
	local a = x+z > 0
	local b = x-z > 0
	if a and b then
		--print( "North" )
		return 0
	elseif not a and b then
		--print( "East" )
		return 1
	elseif a and not b then
		--print( "West" )
		return 3
	elseif not a and not b then
		--print( "South" )
		return 2
	end
end

local function do_rotation( itemstack, placer, pointed_thing )
	print( "This running even!?" )
	local dir = placer:get_look_dir()
	local p1 = pointed_thing.above
	local placer_pos = placer:get_pos()
	local param2 = minetest.dir_to_facedir(vector.subtract(p1, placer_pos))
	return minetest.item_place( itemstack, placer, pointed_thing, param2 )
end

minetest.register_node( "automatica:dev_conveyor_belt", {
	description = "conveyor Belt (dev)",
	drawtype = "mesh",
	paramtype2 = "facedir",
	sunlight_propogates = true,
	collision_box = {
		type = "fixed",
		fixed = {
			 { -0.5, -0.5, -0.5, .5, 0, .5 },
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			 { -0.5, -0.5, -0.5, .5, 0, .5 },
		},
	},
	--[[tiles = { {
		name = "conveyor_belt.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 0.5,
		},
	} },]]
	visual_scale = "mesh",
	mesh = "conveyor_mid.b3d",
	on_timer = function ( pos, elapsed )
		--print( "On Timer" )
		local newPos = { x = pos.x, y = pos.y, z = pos.z }
		local myNodeAbove = minetest.get_node( newPos )
		--if myNodeAbove.name == "air" then
			--print( myNodeAbove.name )
			--return
		--end

		local myObjects = minetest.get_objects_inside_radius( newPos, 1 )
		if myObjects ~= nil and #myObjects >= 1 then
			for i=1, #myObjects do
				local myName = myObjects[i]:get_player_name()
				local myVelocity = myObjects[i]:get_velocity() or
					myObjects[i]:get_player_velocity()
				local myMeta = minetest.get_meta( pos )
				local myDir = myMeta:get_int( "dir" )
				local myAddingVelocity = {
					x = 0,
					y = -3,
					z = 0
				}
				if myDir == 0 then
					myAddingVelocity.x = 1
				elseif myDir == 1 then
					myAddingVelocity.z = -1
				elseif myDir == 2 then
					myAddingVelocity.x = -1
				elseif myDir == 3 then
					myAddingVelocity.z = 1
				end
				if myVelocity.z < 2 then
					local done = myObjects[i]:add_velocity(
						myAddingVelocity
					) or myObjects[i]:add_player_velocity(
						{
							x = myAddingVelocity.x*3,
							y = -1,
							z = myAddingVelocity.z*3
						}
					)
				end
			end
		end
		local myPlayers = minetest.get_objects_inside_radius( newPos, .6 )
		--print( "[automatica] Player test." )
		--print( dump( myPlayers ) )
		--print( #myPlayers )
		if myPlayers ~= nil and #myPlayers >= 1 then
			print( "[automatica] Has players." )
			for i=1, #myPlayers do
				local myVelocity = myPlayers[i]:get_player_velocity()
				print( "myVelocity: " )
				print( myVelocity )
				if myVelocity ~= nil then
					print( "[automatica] Player to move." )
					local myMeta = minetest.get_meta( pos )
					local myDir = myMeta:get_int( "dir" )
					local myAddingVelocity = {
						x = 0,
						y = 0,
						z = 0
					}
					if myDir == 0 then
						myAddingVelocity.x = 1
					elseif myDir == 1 then
						myAddingVelocity.z = -1
					elseif myDir == 2 then
						myAddingVelocity.x = -1
					elseif myDir == 3 then
						myAddingVelocity.z = 1
					end
					if myVelocity.z+myVelocity.x < 4 then
						print( "[automatica] Adding velocity to player." )
						local done = myPlayers[i]:add_player_velocity(
							{
								x = myAddingVelocity.x*3,
								y = -1,
								z = myAddingVelocity.z*3
							}
						)
					end
				end
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

--[[local conveyor_belt_timer = 0
local conveyor_belt_timer_step = 0.1

function conveyor_belt_step( player, conveyor_belt_timer )
	local playerPos = player:get_pos()
	local below = { x = playerPos.x, y = playerPos.y-1, z = playerPos.z }
	local myNodeBelow = minetest.get_node( below )
	print( dump( myNodeBelow ) )
	if myNodeBelow.name == "automatica:dev_conveyor_belt" then
		local player_velocity = player:get_player_velocity()
		if player_velocity.z < 2 then
			print( "Velociting" )
			player:add_player_velocity( { x=0, y=0, z=1 } )
		end
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
end)]]
