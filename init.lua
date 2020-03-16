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
	{ -0.4, -0.5, -0.56, .4, -0.12, .56 },
	{ -0.5, -0.5, -0.56, -0.4, 0, .56 },
	{ 0.5, -0.5, -0.56, .4, 0, .56 }
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
		local myObjects = minetest.get_objects_inside_radius( newPos, .5 )
		if myObjects ~= nil and #myObjects >= .5 then
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
		local myObjects = minetest.get_objects_inside_radius( newPos, .5 )
		if myObjects ~= nil and #myObjects >= .5 then
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

local dev_conveyor_ladder_up_dimensions = { -0.5, -0.5, .25, 0.5, 0.5, .5 }
minetest.register_node( "automatica:dev_conveyor_ladder_up", {
	description = "conveyor Belt Ladder Up (dev)",
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propogates = true,
	groups = { cracky = 3; choppy = 1; punch_operable = 1 },
	collision_box = {
		type = "fixed",
		fixed = {
			 dev_conveyor_ladder_up_dimensions,
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			 dev_conveyor_ladder_up_dimensions,
		},
	},
	node_box = {
		type = "fixed",
		fixed = {
			 dev_conveyor_ladder_up_dimensions,
		},
	},
	visual_scale = "mesh",
	mesh = "dev_conveyor_ladder_up.b3d",
	on_timer = function ( pos, elapsed )
		local newPos = { x = pos.x, y = pos.y, z = pos.z }
		local myNodeAbove = minetest.get_node( newPos )

		local myObjects = minetest.get_objects_inside_radius( newPos, .5 )
		if myObjects ~= nil and #myObjects >= 1 then
			for i=1, #myObjects do
				--local myName = myObjects[i]:get_player_name()
				local myVelocity = myObjects[i]:get_velocity() or
					myObjects[i]:get_player_velocity()
				local myMeta = minetest.get_meta( pos )
				local myDir = myMeta:get_int( "dir" )
				local myAddingVelocity = {
					x = 0,
					y = 5,
					z = 0
				}
				if myVelocity.y < 0 then
					myAddingVelocity.y = myAddingVelocity.y + (myVelocity.y * -1)
				end
				if myDir == 0 then
					myAddingVelocity.x = 20
				elseif myDir == 1 then
					myAddingVelocity.z = -20
				elseif myDir == 2 then
					myAddingVelocity.x = -20
				elseif myDir == 3 then
					myAddingVelocity.z = 20
				end
				if myVelocity.y < 5 then
					local done = myObjects[i]:add_velocity(
						myAddingVelocity
					) or myObjects[i]:add_player_velocity(
						{
							x = myAddingVelocity.x*4,
							y = 3,
							z = myAddingVelocity.z*4
						}
					)
				end
			end
		end
		local abovePos = { x = pos.x, y = pos.y+1, z = pos.z }
		local myObjectsAbove = minetest.get_objects_inside_radius( abovePos, .5 )
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
		end
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
