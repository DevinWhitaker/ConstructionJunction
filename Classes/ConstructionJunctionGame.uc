class ConstructionJunctionGame extends GameInfo;

var() Bool bSimultaneousCarry;

var() Bool bMineWhileFull;

var() Bool bDisapearWhenDepleted;

var() float HotelSpawnOffset;

/**
  * Return whether an Resource should respawn.  Default implementation allows Resource respawning if the factory isnt depleted.
  */
function bool ShouldRespawn( PickupFactory Other )
{
	return True;
}

function HotelCompleted(PlayerReplicationInfo Winner)
{
	EndGame(Winner, "He finished his shit");
}

/**
 * Returns a pawn of the default pawn class
 *
 * @param	NewPlayer - Controller for whom this pawn is spawned
 * @param	StartSpot - PlayerStart at which to spawn pawn
 *
 * @return	pawn
 */
function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot)
{
	local Pawn ResultPawn;
	local CJPlayerStart Start;

	ResultPawn = Super.SpawnDefaultPawnFor(NewPlayer, StartSpot);

	Start = CJPlayerStart(StartSpot);

	if( Start != None)
	{
		CJVehicle(ResultPawn).Hotel = Start.Land;
		Start.Land.Landlord = CJVehicle(ResultPawn);
	}

	return ResultPawn;
}

DefaultProperties
{
	//GameInfo properties
	DefaultPawnClass=class'CJVehicle'
	PlayerControllerClass=Class'CJPlayerController'
	HUDType=Class'CJHUD'
	bDelayedStart=False
	bWaitingToStartMatch=True
	bSimultaneousCarry=True
	bMineWhileFull=False
	bDisapearWhenDepleted=True
	HotelSpawnOffset=500.0
}
