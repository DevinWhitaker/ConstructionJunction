class CJDroppedResource extends DroppedPickup;

/** give pickup to player */
function GiveTo( Pawn P )
{
	if( CJResource(Inventory).ResourceType == Resource_Wood )
	{
		`Log("Picked up Wood!");
	}

	else if( CJResource(Inventory).ResourceType == Resource_Steel )
	{
		`Log("Picked up Steel!");
	}

	else if( CJResource(Inventory).ResourceType == Resource_Concrete )
	{
		`Log("Picked up Concrete!");
	}

	if( Inventory != None )
	{
		Inventory.AnnouncePickup(P);
		Inventory.GiveTo(P);
		Inventory = None;
	}
	PickedUpBy(P);
}

DefaultProperties
{
	InventoryClass=Class'CJResource'
	LifeSpan=0
}
