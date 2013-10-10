class CJAiController extends AIController implements(CJHudInterface);

/** Hook called from HUD actor. Gives access to HUD and Canvas */
simulated function DrawHUD( HUD H )
{
	CJVehicle(Pawn).DrawAIHUD( H );
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);
    Pawn.SetMovementPhysics();
}

auto state DecisionMaking
{
local int WantedResourceType;

	function int CheckReserves()
	{
		local CJHotel Hotel;

		Hotel = CJVehicle(Pawn).Hotel;

		if( Hotel.WoodReserves < Hotel.SteelReserves )
		{
			if( Hotel.WoodReserves < Hotel.ConcreteReserves )
			{
				return Resource_Wood;
			}
			else
			{
				return Resource_Concrete;
			}
		}
		else
		{
			if( Hotel.SteelReserves < Hotel.ConcreteReserves )
			{
				return Resource_Steel;
			}
			else
			{
				return Resource_Concrete;
			}
		}
	}

Begin:

	NavigationHandle.ClearConstraints();
	NavigationHandle.ClearCurrentEdge();

	WantedResourceType = CheckReserves();

	PushState('SeekFactory');
	PushState('Mining');
	PushState('SeekHome');
	PushState('Depositing');

	Goto'Begin';
}

state SeekFactory extends DecisionMaking
{
	local Float MinDist;
	local CJResourceFactory Closest;
	local CJResourceFactory CurFactory;

	event PushedState()
	{
		`Log("entering SeekFactory State");
	}

Begin:
	NavigationHandle.ClearConstraints();
	NavigationHandle.ClearCurrentEdge();

	//set to float max
	MinDist = 9999999999999999999999999999999999999999999.0;

	ForEach WorldInfo.AllNavigationPoints(Class'CJResourceFactory', CurFactory)
	{
		if( CurFactory.Reserve <= 0 || CurFactory.ResourceSpawnType != WantedResourceType )
			continue;
			
		`Log("Wanted resource" @ WantedResourceType);
		//TODO: check resource type to make sure aaawdsawdits what i need

		if( MinDist > VSize(CurFactory.Location - Pawn.Location) )
		{
			MinDist = VSize(CurFactory.Location - Pawn.Location);
			Closest = CurFactory;
		}
	}

	//Create goal
	Class'NavMeshGoal_At'.static.AtActor(NavigationHandle, Closest);

	//Create constraints
	Class'NavMeshPath_Toward'.static.TowardGoal(NavigationHandle, Closest);
	Class'NavMeshPath_EnforceTwoWayEdges'.static.EnforceTwoWayEdges(NavigationHandle);

	if( NavigationHandle.FindPath() )
	{
		`Log("Path found");
		PushState('Traveling');
	}
	else
	{
		`Log("Path not found");
		PopState();
	}

	PopState();
}

State SeekDroppedResource
{
	local Float MinDist;
	local CJDroppedResource Closest;
	local CJDroppedResource CurResource;

	event PushedState()
	{
		`Log("entering SeekDroppedResource State");
	}

Begin:
	NavigationHandle.ClearConstraints();
	NavigationHandle.ClearCurrentEdge();

	//set to float max
	MinDist = 9999999999999999999999999999999999999999999.0;

	ForEach WorldInfo.AllActors(Class'CJDroppedResource', CurResource)
	{
		if( MinDist > VSize(CurResource.Location - Pawn.Location) )
		{
			MinDist = VSize(CurResource.Location - Pawn.Location);
			Closest = CurResource;
		}
	}

	//Create goal
	Class'NavMeshGoal_At'.static.AtActor(NavigationHandle, Closest);

	//Create constraints
	Class'NavMeshPath_Toward'.static.TowardGoal(NavigationHandle, Closest);
	Class'NavMeshPath_EnforceTwoWayEdges'.static.EnforceTwoWayEdges(NavigationHandle);

	if( NavigationHandle.FindPath() )
	{
		`Log("Path found");
		PushState('Traveling');
	}
	else
	{
		`Log("Path not found");
		PopState();
	}

	PopState();
}

State SeekEnemy
{
	local Float MinDist;
	local CJVehicle Closest;
	local CJVehicle CurEnemy;

	event PushedState()
	{
		`Log("entering SeekEnemy State");
	}

Begin:
	NavigationHandle.ClearConstraints();
	NavigationHandle.ClearCurrentEdge();

	//set to float max
	MinDist = 9999999999999999999999999999999999999999999.0;

	ForEach WorldInfo.AllActors(Class'CJVehicle', CurEnemy)
	{
		if( CurEnemy == Pawn )
			continue;

		if( MinDist > VSize(CurEnemy.Location - Pawn.Location) )
		{
			MinDist = VSize(CurEnemy.Location - Pawn.Location);
			Closest = CurEnemy;
		}
	}

	//Create goal
	Class'NavMeshGoal_At'.static.AtActor(NavigationHandle, Closest);

	//Create constraints
	Class'NavMeshPath_Toward'.static.TowardGoal(NavigationHandle, Closest);
	Class'NavMeshPath_EnforceTwoWayEdges'.static.EnforceTwoWayEdges(NavigationHandle);

	if( NavigationHandle.FindPath() )
	{
		`Log("Path found");
		PushState('Traveling');
	}
	else
	{
		`Log("Path not found");
		PopState();
	}

	PopState();
}

state SeekEnemyHotel
{
	local Float MinDist;
	local CJHotel Closest;
	local CJHotel CurEnemyHotel;

	event PushedState()
	{
		`Log("entering SeekEnemyHotel State");
	}
Begin:
	NavigationHandle.ClearConstraints();
	NavigationHandle.ClearCurrentEdge();

	//set to float max
	MinDist = 9999999999999999999999999999999999999999999.0;

	ForEach WorldInfo.AllActors(Class'CJHotel', CurEnemyHotel)
	{
		if( CurEnemyHotel == CJVehicle(Pawn).Hotel )
			continue;

		if( MinDist > VSize(CurEnemyHotel.Location - Pawn.Location) )
		{
			MinDist = VSize(CurEnemyHotel.Location - Pawn.Location);
			Closest = CurEnemyHotel;
		}
	}

	//Create goal
	Class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, Closest.Location);

	//Create constraints
	Class'NavMeshPath_Toward'.static.TowardPoint(NavigationHandle, Closest.Location);
	Class'NavMeshPath_EnforceTwoWayEdges'.static.EnforceTwoWayEdges(NavigationHandle);

	if( NavigationHandle.FindPath() )
	{
		`Log("Path found");
		PushState('Traveling');
	}
	else
	{
		`Log("Path not found");
		PopState();
	}

	PopState();
}

state SeekHome
{
	event PushedState()
	{
		`Log("entering SeekHome State");
	}
Begin:
	NavigationHandle.ClearConstraints();
	NavigationHandle.ClearCurrentEdge();

	if( !Class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, CJVehicle(Pawn).Hotel.Location) )
	{
		`lOG("Failed to make goal evaluator");
		PopState();
	}

	Class'NavMeshPath_EnforceTwoWayEdges'.static.EnforceTwoWayEdges(NavigationHandle);
	IF( !Class'NavMeshPath_Toward'.static.TowardPoint(NavigationHandle, CJVehicle(Pawn).Hotel.Location) )
	{
		`Log("Failed to make path constraint");
		PopState();
	}

	if( NavigationHandle.FindPath() )
	{
		`Log("Path found");
		PushState('Traveling');
	}
	else
	{
		`Log("Path not found");
		PopState();
	}

	PopState();
}

state Depositing
{
	event Tick(Float Delta)
	{
		if( CJInventoryManager(Pawn.InvManager).ResourceCount <= 0 )
		{
			PopState();
		}

		CJVehicle(Pawn).TryMining();
	}
}

state Mining
{
	event Tick(Float Delta)
	{
		if( CJInventoryManager(Pawn.InvManager).ResourceCount >= CJInventoryManager(Pawn.InvManager).Capacity )
		{
			PopState();
		}

		CJVehicle(Pawn).TryMining();
	}
}

state Traveling
{
	simulated function Tick(Float Delta)
	{
		local Vector Point;
		local rotator NewRotation;

		super.Tick(Delta);

		if( !NavigationHandle.GetNextMoveLocation(Point, Pawn.GetCollisionRadius()) )
		{
			//This state is only for people who know where they are going
			`Log("Cant find next location");
			PopState();
			return;
		}

		DrawDebugLine(Pawn.Location, Point, 0x00, 0xFF, 0x00, false);

		Point.Z = Pawn.Location.Z;

		NewRotation = RLerp(Pawn.Rotation, Rotator(Point - Pawn.Location), Delta * Pawn.RotationRate.Yaw, True);

		Pawn.SetRotation(NewRotation);
		Pawn.Acceleration = Normal( Vector(Pawn.Rotation) ) * Pawn.AccelRate * Delta;

		if( VSize(NavigationHandle.FinalDestination.Position - Pawn.Location) <= Pawn.GetCollisionRadius() )
		{
			PopState();
		}
	}

	event PoppedState()
	{
		Pawn.Acceleration = Vect(0.0, 0.0, 0.0);
	}
}

DefaultProperties
{

	Begin Object Class=NavigationHandle Name=NavHandle
		bDebugConstraintsAndGoalEvals=True
		bUltraVerbosePathDebugging=True
		bAbleToSearch=True
	End Object
	NavigationHandle=NavHandle
}
