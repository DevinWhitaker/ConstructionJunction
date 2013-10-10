class CJResource extends Inventory;

enum CJResourceType
{
	Resource_Wood,
	Resource_Steel,
	Resource_Concrete
};

var CJResourceType ResourceType;

/** DenyPickupQuery
	Function which lets existing items in a pawn's inventory
	prevent the pawn from picking something up.
 * @param ItemClass Class of Inventory our Owner is trying to pick up
 * @param Pickup the Actor containing that item (this may be a PickupFactory or it may be a DroppedPickup)
 * @return true to abort pickup or if item handles pickup
 */
function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	local CJResourceFactory PFactory;
	local CJDroppedResource Dropped;

	PFactory = CJResourceFactory(Pickup);

	if( PFactory != None )
	{
		//  you can only carry items of a single resource type.
		if( !ConstructionJunctionGame(WorldInfo.Game).bSimultaneousCarry && CJResourceType(PFactory.ResourceSpawnType) == ResourceType )
		{
			return false;
		}
	}

	Dropped = CJDroppedResource(Pickup);

	if( Dropped != None )
	{
		//  you can only carry items of a single resource type.
		if ( !ConstructionJunctionGame(WorldInfo.Game).bSimultaneousCarry && CJResource(Dropped.Inventory).ResourceType == ResourceType )
		{
			return false;
		}
	}

	return true;
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=S_Mesh
		StaticMesh=StaticMesh'Chapter_06_Functions.ClownFish'
	End Object
	DroppedPickupMesh=S_Mesh
	Components.Add(S_Mesh);
	
	DroppedPickupClass=Class'CJDroppedResource'
	Begin Object Class=CylinderComponent Name=PickupMesh
		Bounds=(BoxExtent=(X=10.0, Y=10.0, Z=10.0))
	End Object
	PickupFactoryMesh=PickupMesh
	Components.Add(PickupMesh);
	
}
