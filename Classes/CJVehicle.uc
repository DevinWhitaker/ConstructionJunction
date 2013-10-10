class CJVehicle extends SVehicle
	placeable;

//The resource factory we will try to get resources from
var CJResourceFactory TargetResource;
var CJHotel TargetHotel;

var CJHotel Hotel;

/**
 *	Calculate camera view point, when viewing this actor.
 *
 * @param	fDeltaTime	delta time seconds since last update
 * @param	out_CamLoc	Camera Location
 * @param	out_CamRot	Camera Rotation
 * @param	out_FOV		Field of View
 *
 * @return	true if Pawn should provide the camera point of view.
 */
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	out_CamLoc = Location;
	out_CamLoc += BaseOffset;
	out_CamRot = rotator( Normal(Location - out_CamLoc) );
	return true;
}

simulated event PostBeginPlay()
{
	local Float MinDist;
	local CJHotel Closest;
	local CJHotel CurHotel;

	super.PostBeginPlay();

	//set to float max
	MinDist = 9999999999999999999999999999999999999999999.0;

	ForEach WorldInfo.AllActors(Class'CJHotel', CurHotel)
	{
		if( MinDist > VSize(CurHotel.Location - Location) )
		{
			MinDist = VSize(CurHotel.Location - Location);
			Closest = CurHotel;
		}
	}

	if( Closest != None )
	{
		Hotel = Closest;
		Closest.Landlord = self;
	}
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local CJResourceFactory Fac;
	local CJHotel Hot;

	Fac = CJResourceFactory(Other);

	if( Fac != None )
	{
		TargetResource = Fac;
	}

	Hot = CJHotel(Other);

	if( Hot != None )
	{
		TargetHotel = Hot;
	}
}

event Untouch(Actor other)
{
	if( other == TargetResource )
	{
		TargetResource = None;
	}
	else if( other == TargetHotel )
	{
		TargetHotel = None;
	}
}

function TryMining()
{
	if( TargetResource != None )
	{
		if( ConstructionJunctionGame(WorldInfo.Game).bMineWhileFull )
		{
			TargetResource.Mine();
		}
		else if( CJInventoryManager(InvManager).ResourceCount < CJInventoryManager(InvManager).Capacity )
		{
			TargetResource.Mine();
		}
	}
	else if( TargetHotel != None )
	{
		TargetHotel.Deposit(self);
	}
}

/** Hook called from HUD actor. Gives access to HUD and Canvas */
simulated function DrawAIHUD( HUD H )
{
	local Vector Location2D, Forward, Side, Up;
	local Int Stock;
	local Bool FullToCapacity;

	GetAxes(Rotation, Forward, Side, Up);
	Location2D = Location + Normal(-Forward) * 100;
	Location2D = H.Canvas.Project(Location2D);

	Stock = CJInventoryManager(InvManager).ResourceCount;
	FullToCapacity = Stock >= CJInventoryManager(InvManager).Capacity;

	//Draw counter border
	if( !FullToCapacity )
	{
		H.Canvas.SetDrawColor(0xFF, 0xFF, 0xFF);
	}
	else
	{
		H.Canvas.SetDrawColor(0x00, 0x00, 0x00);
	}
	H.Canvas.SetPos(Location2D.X-13.5, Location2D.Y-13.5, Location2D.Z);
	H.Canvas.DrawRect(27, 27);

	//Draw counter rect
	if( !FullToCapacity )
	{
		H.Canvas.SetDrawColor(0x41, 0x69, 0xE1);
	}
	else
	{
		H.Canvas.SetDrawColor(0x00, 0xFF, 0x00);
	}
	H.Canvas.SetPos(Location2D.X-12.5, Location2D.Y-12.5, Location2D.Z);
	H.Canvas.DrawRect(25, 25);

	//Draw count
	if( !FullToCapacity )
	{
		H.Canvas.SetDrawColor(0xFF, 0xFF, 0xFF);
	}
	else
	{
		H.Canvas.SetDrawColor(0x00, 0x00, 0x00);
	}
	H.Canvas.SetPos(Location2D.X-6.25, Location2D.Y-6.5, Location2D.Z);
	H.Canvas.DrawText(Stock);
}

/** Hook called from HUD actor. Gives access to HUD and Canvas */
simulated function DrawHUD( HUD H )
{
	local Vector Location2D, Forward, Side, Up;
	local Int Stock;
	local Bool FullToCapacity;

	if( Hotel != None )
	{
		Hotel.DrawHUD( H );
	}

	if ( InvManager != None )
	{
		InvManager.DrawHUD( H );
	}

	if( TargetResource != None )
	{
		TargetResource.DrawHUD( H );
	}
	
	if( TargetHotel != None )
	{
		TargetHotel.DrawDeposit( H, self );
	}

	GetAxes(Rotation, Forward, Side, Up);
	Location2D = Location + Normal(-Forward) * 100;
	Location2D = H.Canvas.Project(Location2D);

	Stock = CJInventoryManager(InvManager).ResourceCount;
	FullToCapacity = Stock >= CJInventoryManager(InvManager).Capacity;

	//Draw counter border
	if( !FullToCapacity )
	{
		H.Canvas.SetDrawColor(0xFF, 0xFF, 0xFF);
	}
	else
	{
		H.Canvas.SetDrawColor(0x00, 0x00, 0x00);
	}
	H.Canvas.SetPos(Location2D.X-13.5, Location2D.Y-13.5, Location2D.Z);
	H.Canvas.DrawRect(27, 27);

	//Draw counter rect
	if( !FullToCapacity )
	{
		H.Canvas.SetDrawColor(0x41, 0x69, 0xE1);
	}
	else
	{
		H.Canvas.SetDrawColor(0x00, 0xFF, 0x00);
	}
	H.Canvas.SetPos(Location2D.X-12.5, Location2D.Y-12.5, Location2D.Z);
	H.Canvas.DrawRect(25, 25);

	//Draw count
	if( !FullToCapacity )
	{
		H.Canvas.SetDrawColor(0xFF, 0xFF, 0xFF);
	}
	else
	{
		H.Canvas.SetDrawColor(0x00, 0x00, 0x00);
	}
	H.Canvas.SetPos(Location2D.X-6.25, Location2D.Y-6.5, Location2D.Z);
	H.Canvas.DrawText(Stock);

}

DefaultProperties
{
	//Actor properties
	RotationRate=(Yaw=10)
	Physics=PHYS_Walking

	//Pawn properties
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Scorpion.Mesh.SK_VH_Scorpion_001'
		CollideActors=FALSE
	End Object
	Components.Add(SVehicleMesh)

	Begin Object Name=CollisionCylinder
		CollisionRadius=+100.0
		CollisionHeight=+78.0
	End Object

	bCanPickupInventory=True
	InventoryManagerClass=Class'CJInventoryManager'

	//Vehicle properties
	bTurnInPlace=True
	bFollowLookDir=False
	bRetryPathfindingWithDriver=False

	//SVehicle properties
	BaseOffset=(X=-500.0, Z=1000.0)
	CamDist=0.0
	bStayUpright=True

	//CJVehicle
	TargetResource=None
}
