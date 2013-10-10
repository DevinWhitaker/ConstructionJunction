class CJResourceFactory extends PickupFactory
	ClassGroup(ConstructionJunction);

/**amount of resource that can be produced from this factory*/
var(ConstructionJunction) int Reserve;

/**amount of resource dropped when mined once*/
var(ConstructionJunction) int DropAmount;

/**will drop resources between this velocity and the Max*/
var(ConstructionJunction) float MinDropSpeed;

/**will drop resources between this velocity and the Min*/
var(ConstructionJunction) float MaxDropSpeed;

/**rate at which this factory is mined per second*/
var(ConstructionJunction) float MineRate;

/**if true MineProgress will reset when reaches zero*/
var(ConstructionJunction) bool bResetMineProgress;

/**used to reset the MineProgress of this factory*/
var(ConstructionJunction) float Durability;

/**when reaches zero will drop a resource then reset*/
var float MineProgress;

enum SpawnType
{
	Spawn_Wood,
	Spawn_Steel,
	Spawn_Concrete,
	Spawn_Random
};

var(ConstructionJunction) SpawnType ResourceSpawnType;

event PostBeginPlay()
{
	super.PostBeginPlay();

	MineProgress = Durability;
}

function Mine()
{
	local int Index;

	if( MineProgress > 0.0 )
	{
		MineProgress -= MineRate;
		`Log("MineProgress:"@MineProgress);
	}
	else
	{
		for(Index = 0; Index < DropAmount; ++Index)
		{
			DropResource();
		}

		if( bResetMineProgress )
		{
			MineProgress = Durability;
		}

		`Log("Reserves:" @ Reserve);
	}
}

function DropResource()
{
	local Inventory Inv;
	local Vector DropDir;
	local float DropSpeed;

	if( Reserve <= 0 )
		return;

	Inv = spawn(InventoryType);

	if ( Inv != None )
	{
		if( ResourceSpawnType == Spawn_Random )
		{
			CJResource(Inv).ResourceType = CJResourceType(Rand(Spawn_Concrete+1));
		}
		else
		{
			CJResource(Inv).ResourceType = CJResourceType(ResourceSpawnType);
		}

		DropDir = VRand();
		DropSpeed = RandRange(MinDropSpeed, MaxDropSpeed);
		Inv.DropFrom(Location, Normal(DropDir) * DropSpeed);
		--Reserve;
	}

	if( Reserve <= 0 )
	{
		GotoState('Disabled');
		return;
	}
}

/** Hook called from HUD actor. Gives access to HUD and Canvas */
simulated function DrawHUD( HUD H )
{
	local Vector Location2D;

	if( MineProgress <= 0.0 )
		return;

	Location2D = H.Canvas.Project(Location);

	//Draw uncompleted section of progressbar
	H.Canvas.SetPos(Location2D.X, Location2D.Y, Location2D.Z);
	H.Canvas.SetDrawColor(255, 0, 0);
	H.Canvas.DrawRect(75, 25);

	//Draw completeed section of progressbar
	H.Canvas.SetPos(Location2D.X, Location2D.Y, Location2D.Z);
	H.Canvas.SetDrawColor(0, 255, 0);
	H.Canvas.DrawRect(75 * (MineProgress/Durability), 25);
}

auto state Pickup
{
	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
	}

	event BeginState(name PreviousStateName)
	{
	}
Begin:
}

state Disabled
{
	function Mine(){};

	simulated event BeginState(name PreviousStateName)
	{
		if( ConstructionJunctionGame(WorldInfo.Game).bDisapearWhenDepleted )
		{
			SetHidden( true );
		}
	}
}

DefaultProperties
{
	InventoryType=Class'CJResource'
	RespawnEffectTime=1.0

	//CJResourceFactory properties
	Begin Object Class=StaticMeshComponent Name=ViewMesh
		StaticMesh=StaticMesh'HU_Deck.SM.Meshes.S_HU_Deck_SM_BioPot'
	End Object
	Components.Add(ViewMesh);

	Begin Object NAME=CollisionCylinder
		CollisionRadius=130.0
		CollisionHeight=80.0
	End Object

	Reserve=100
	DropAmount=2
	MinDropSpeed=500.0
	MaxDropSpeed=1000.0
	MineRate=1
	bResetMineProgress=True
	Durability=100
	ResourceSpawnType=Spawn_Random
}
