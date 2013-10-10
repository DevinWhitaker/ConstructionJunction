class CJPlayerController extends PlayerController implements(CJHudInterface);

// smooth the rotations
 function UpdateRotation( float DeltaTime )
{
	//Do nothing for now
}

event bool NotifyLanded(vector HitNormal, Actor FloorActor)
{
	return False;
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);
    Pawn.SetMovementPhysics();
}

/**
 * Entry point function for player interactions with the world,
 * re-directs to ServerUse.
 */
exec function StarMining()
{
	GotoState('PlayerMining');
}

exec function StopMining()
{
	GotoState('PlayerDriving');
}

// Player is a vehicle, Duh.
state PlayerDriving
{
	// Set the throttle, steering etc. for the vehicle based on the input provided
	function PlayerMove( float DeltaTime )
	{
		local Vehicle CurrentVehicle;
		local Vector NewAccel, Forward, Side, Up;
		local rotator NewRotation;

		CurrentVehicle = Vehicle(Pawn);
		if (CurrentVehicle != None)
		{
			NewRotation = CurrentVehicle.Rotation;

			NewRotation.Yaw += PlayerInput.aStrafe * CurrentVehicle.RotationRate.Yaw * DeltaTime;

			CurrentVehicle.SetRotation( NewRotation );

			GetAxes(CurrentVehicle.Rotation, Forward, Side, Up);

			NewAccel = PlayerInput.aForward * Forward;
			
			NewAccel = Normal(NewAccel) * CurrentVehicle.AccelRate;

			CurrentVehicle.Acceleration = NewAccel;
			
			CurrentVehicle.SetInputs(PlayerInput.RawJoyUp, -PlayerInput.RawJoyRight, PlayerInput.aUp);
		}
	}
}

state PlayerMining
{
	event PlayerTick(float Delta)
	{
		CJVehicle(Pawn).TryMining();
	}
}

DefaultProperties
{
	InputClass=Class'CJPlayerInput'
}
