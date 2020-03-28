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
	inInventory:set_stack( 'product', 1, ItemStack( inProduct ) )
end

local function make_craft( inInventory, inProduct )
	inInventory:set_stack( 'out', 1, ItemStack( inProduct ) )
end

local function clear_preview( inInventory )
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
			return 1
		elseif listname == 'product' then
			--TODO: If available, gives product to player and reprocess inventory after take is complete
			return 0
		end
	end,
})

if minetest.get_modpath("hopper") then
	hopper:add_container({
		{"top", "automatica:dev_autocrafter", "out"},
		{"side", "automatica:dev_autocrafter", "recipe"},
		{"bottom", "automatica:dev_autocrafter", "recipe"},
	})
end
