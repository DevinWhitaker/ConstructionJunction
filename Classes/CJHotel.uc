class CJHotel extends NavigationPoint
	placeable;

var StaticMeshComponent BuildingMesh;

var float BuildPercent;

var(ConstructionJunction) float ProgressPerSecond;
var(ConstructionJunction) int WoodUsedPerTick;
var(ConstructionJunction) int SteelUsedPerTick;
var(ConstructionJunction) int ConcreteUsedPerTick;

var int WoodReserves;
var int SteelReserves;
var int ConcreteReserves;

var CJVehicle Landlord;

event PostBeginPlay()
{
	super.PostBeginPlay();
	BuildingMesh.SetScale( BuildPercent );
	SetCollisionType(COLLIDE_TouchAll);
}

auto state Construction
{
	event Tick(float Delta)
	{
		local float TickPercent;
	
		if( BuildPercent >= 1.0 )
		{
			GotoState('Completed');
			return;
		}

		TickPercent = 0.0;

		//TODO: scale by time

		if( WoodReserves > 0 && SteelReserves > 0 &&
			ConcreteReserves > 0 )
		{
			if( WoodReserves >= WoodUsedPerTick )
			{
				WoodReserves -= WoodUsedPerTick;
				TickPercent += 0.33;
			}
			else
			{
				TickPercent += 0.33 * (float(WoodReserves) / float(WoodUsedPerTick));
				WoodReserves -= WoodReserves;
			}

			if( SteelReserves >= SteelUsedPerTick )
			{
				SteelReserves -= SteelUsedPerTick;
				TickPercent += 0.33;
			}
			else
			{
				TickPercent += 0.33 * (float(SteelReserves) / float(SteelUsedPerTick));
				SteelReserves -= SteelReserves;
			}

			if( ConcreteReserves >= ConcreteUsedPerTick )
			{
				ConcreteReserves -= ConcreteUsedPerTick;
				TickPercent += 0.33;
			}
			else
			{
				TickPercent += 0.33 * (float(ConcreteReserves) / float(ConcreteUsedPerTick));
				ConcreteReserves -= ConcreteReserves;
			}

			//get rid of the .99 repeating
			TickPercent += 0.01;
		}

		BuildPercent += ProgressPerSecond * TickPercent;

		if( BuildPercent > 1.0 )
			BuildPercent = 1.0;

		if( WoodReserves < 0 )
			WoodReserves = 0;
		if( SteelReserves < 0 )
			SteelReserves = 0;
		if( ConcreteReserves < 0 )
			ConcreteReserves = 0;

		BuildingMesh.SetScale( BuildPercent );
	}
}

state Completed
{
	ignores Tick;

	event BeginState(name PreviousStateName)
	{
		ConstructionJunctionGame(WorldInfo.Game).HotelCompleted(Landlord.PlayerReplicationInfo);
	}
}

function Deposit(CJVehicle Giver)
{
	local CJInventoryManager InvMan;
	local CJResource Resource;
	local int Count;

	if(Giver != Landlord)
		return;

	InvMan = CJInventoryManager(Giver.InvManager);
	Count = 1;

	foreach InvMan.InventoryActors(Class'CJResource', Resource)
	{
		switch(Resource.ResourceType)
		{
		case Resource_Wood:
				++WoodReserves;
				break;
		case Resource_Steel:
				++SteelReserves;
				break;
		case Resource_Concrete:
				++ConcreteReserves;
				break;
		}

		InvMan.RemoveFromInventory(Resource);
		Resource.Destroy();

		--Count;
		`Log("Deposited; \nWood:" @ WoodReserves @ "Steel:" @ SteelReserves @ "Concrete:" @ ConcreteReserves);

		if(Count <= 0)
		{
			break;
		}
	}
}

/** Hook called from HUD actor. Gives access to HUD and Canvas */
simulated function DrawHUD( HUD H )
{
	local float HotelWindowSize;
	local float HigherBarY, LowerBarY;
	local Color Black;

	HotelWindowSize = 100.0;
	HigherBarY = H.SizeY - 40;
	LowerBarY = H.SizeY - 20;

	Black.R = 0;
	Black.G = 0;
	Black.B = 0;
	Black.A = 255;

	//TODO: make sizes a ratio of the screen instead of hard coded

	//Draw hotel icon
	H.Canvas.SetDrawColor(0, 0, 0);
	H.Canvas.SetPos(0.0, H.SizeY-HotelWindowSize, 0.0);
	H.Canvas.DrawRect(HotelWindowSize, HotelWindowSize);//TODO: replace this rect with a real-time view of the hotel model
	H.Canvas.SetPos(0.0, H.SizeY-HotelWindowSize, 0.0);
	H.Canvas.SetDrawColor(255, 255, 255);
	H.Canvas.DrawText("Real-time\n" $ "view of\n" $ "hotel\n" $ "goes\n" $ "here");

	//Draw uncompleted section of progressbar
	H.Canvas.SetDrawColor(255, 0, 0);
	H.Canvas.SetPos(HotelWindowSize, LowerBarY, 0.0);
	H.Canvas.DrawRect(H.SizeX-HotelWindowSize, 20.0);

	//Draw completeed section of progressbar
	H.Canvas.SetDrawColor(0, 255, 0);
	H.Canvas.SetPos(HotelWindowSize, LowerBarY, 0.0);
	H.Canvas.DrawRect((H.SizeX-HotelWindowSize) *  BuildPercent, 20.0);

	//Draw completion percent
	H.Canvas.SetDrawColor(0, 0, 255);
	H.Canvas.SetPos(H.SizeX * 0.5, LowerBarY, 0.0);
	H.Canvas.DrawText( Int(100 * BuildPercent) $ "%");

	//Draw reserves bar
	H.Canvas.SetDrawColor(0xEE, 0xE8, 0xAA);
	H.Canvas.SetPos(HotelWindowSize, HigherBarY, 0.0);
	H.Canvas.DrawRect(H.SizeX-HotelWindowSize, 20.0);
	H.Draw2DLine(HotelWindowSize, HigherBarY, H.SizeX, HigherBarY, Black);
	H.Draw2DLine(HotelWindowSize, LowerBarY, H.SizeX, LowerBarY, Black);

	//Draw wood icon
	H.Canvas.SetPos(5.0 + HotelWindowSize, 5.0 + HigherBarY, 0.0);
	H.Canvas.SetDrawColor(0x6F, 0x37, 0x0F);
	H.Canvas.DrawRect(10.0, 10.0);

	//Draw wood count
	H.Canvas.SetPos(20.0 + HotelWindowSize, 0.0 + HigherBarY, 0.0);
	H.Canvas.SetDrawColor(0, 0, 0);
	H.Canvas.DrawText("Wood:" @ WoodReserves);

	//Draw steel icon
	H.Canvas.SetPos(100.0 + HotelWindowSize, 5.0 + HigherBarY, 0.0);
	H.Canvas.SetDrawColor(0x66, 0x66, 0x66);
	H.Canvas.DrawRect(10.0, 10.0);

	//Draw steel count
	H.Canvas.SetPos(120.0 + HotelWindowSize, 0.0 + HigherBarY, 0.0);
	H.Canvas.SetDrawColor(0, 0, 0);
	H.Canvas.DrawText("Steel:" @ SteelReserves);

	//Draw concrete icon
	H.Canvas.SetPos(200.0 + HotelWindowSize, 5.0 + HigherBarY, 0.0);
	H.Canvas.SetDrawColor(0x5F, 0x9E, 0xA0);
	H.Canvas.DrawRect(10.0, 10.0);

	//Draw concrete count
	H.Canvas.SetPos(220.0 + HotelWindowSize, 0.0 + HigherBarY, 0.0);
	H.Canvas.SetDrawColor(0, 0, 0);
	H.Canvas.DrawText("Concrete:" @ ConcreteReserves);
}

simulated function DrawDeposit( HUD H, Pawn Giver )
{
	local Vector Location2D;
	local CJInventoryManager DriversInventory;

	DriversInventory = CJInventoryManager(Giver.InvManager);

	if( DriversInventory.ResourceCount <= 0.0 )
		return;

	Location2D = H.Canvas.Project(Giver.Location);

	//Draw uncompleted section of progressbar
	H.Canvas.SetPos(Location2D.X, Location2D.Y, Location2D.Z);
	H.Canvas.SetDrawColor(0, 0, 0);
	H.Canvas.DrawRect(75, 25);

	//Draw completeed section of progressbar
	H.Canvas.SetPos(Location2D.X, Location2D.Y, Location2D.Z);
	H.Canvas.SetDrawColor(0x41, 0x69, 0xE1);
	H.Canvas.DrawRect(75 * (DriversInventory.ResourceCount/DriversInventory.Capacity), 25);
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=Mesh
		StaticMesh=StaticMesh'Castle_Assets.Meshes.SM_CAS_Window_01'
	End Object
	BuildingMesh=Mesh
	Components.Add(Mesh);

	Begin Object Class=CylinderComponent Name=CollideComponent
		CollideActors=True
		CollisionRadius=500.0
		CollisionHeight=500.0
	End Object
	CollisionComponent=CollideComponent
	Components.Add(CollideComponent);

	Begin Object Class=StaticMeshComponent Name=FoundationMesh
		StaticMesh=StaticMesh'Eat3DCinematicUDK_Content.ToBeUsed.Base'
		Scale3D=(X=1.5, Y=1.5, Z=0.5)
		HiddenGame=False
	End Object
	Components.Add(FoundationMesh);


	BuildPercent=0.0

	ProgressPerSecond=0.01
	WoodUsedPerTick=1
	SteelUsedPerTick=1
	ConcreteUsedPerTick=1

	WoodReserves=0
	SteelReserves=0
	ConcreteReserves=0
}
