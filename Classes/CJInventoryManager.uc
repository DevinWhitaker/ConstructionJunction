class CJInventoryManager extends InventoryManager;

/***/
var(ConstructionJunction) int Capacity;

var int ResourceCount;

simulated function bool AddInventory(Inventory NewItem, optional bool bDoNotActivate)
{
	local bool Result;

	Result = super.AddInventory(NewItem, bDoNotActivate);

	if( Result )
	{
		++ResourceCount;
		`Log("Resource:" @ ResourceCount);
	}

	return Result;
}

/**
 * Attempts to remove an item from the inventory list if it exists.
 *
 * @param	Item	Item to remove from inventory
 */
simulated function RemoveFromInventory(Inventory ItemToRemove)
{
	super.RemoveFromInventory(ItemToRemove);
	--ResourceCount;
}

/**
 * Hook called from HUD actor. Gives access to HUD and Canvas
 *
 * @param	H	HUD
 */
simulated function DrawHud( HUD H )
{

}

/**
 * Handle Pickup. Can Pawn pickup this item?
 *
 * @param	ItemClass Class of Inventory our Owner is trying to pick up
 * @param	Pickup the Actor containing that item (this may be a PickupFactory or it may be a DroppedPickup)
 *
 * @return	whether or not the Pickup actor should give its item to Other
 */
function bool HandlePickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	local Inventory	Inv;

	if( ResourceCount >= Capacity )
	{
		return FALSE;
	}

	//if can carry more than one type at once
	if( ConstructionJunctionGame(WorldInfo.Game).BSimultaneousCarry )
		return TRUE;

	// Give other Inventory Items a chance to deny this pickup
	ForEach InventoryActors(class'Inventory', Inv)
	{
		if( Inv.DenyPickupQuery(ItemClass, Pickup) )
		{
			return FALSE;
		}
	}
	return TRUE;
}

DefaultProperties
{
	Capacity=10
	ResourceCount=0
}
