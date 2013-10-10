class CJHUD extends HUD;

/**
 * The Main Draw loop for the hud.  Gets called before any messaging.  Should be subclassed
 */
function DrawHUD()
{
	//super.DrawHUD();

	local vector ViewPoint;
	local rotator ViewRotation;
	local Controller OutController;

	if ( bShowOverlays && (PlayerOwner != None) )
	{
		Canvas.Font = GetFontSizeIndex(0);
		PlayerOwner.GetPlayerViewPoint(ViewPoint, ViewRotation);
		DrawActorOverlays(Viewpoint, ViewRotation);
	}

	ForEach WorldInfo.Game.AllActors(Class'Controller', OutController, Class'CJHudInterface')
	{
		CJHudInterface(OutController).DrawHUD( self );
	}
}

DefaultProperties
{
}
