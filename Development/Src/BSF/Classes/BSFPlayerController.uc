class BSFPlayerController extends PlayerController;

/**
 * Draw a crosshair. This function is called by the Engine.HUD class.
 */
function DrawHUD( HUD H )
{
	local float CrosshairSize;
	super.DrawHUD(H);

	H.Canvas.SetDrawColor(255,160,0,120);

	CrosshairSize = 4;

	H.Canvas.SetPos(H.CenterX - CrosshairSize, H.CenterY);
	H.Canvas.DrawRect(2 * CrosshairSize + 1, 1);

	H.Canvas.SetPos(H.CenterX, H.CenterY - CrosshairSize);
	H.Canvas.DrawRect(1, 2 * CrosshairSize + 1);
}

auto state PlayerWaiting
{
	exec function StartFire( optional byte FireModeNum )
	{
		showTargetInfo();
	}
}

function showTargetInfo()
{
	local vector loc, norm, end;
	local TraceHitInfo hitInfo;
	local Actor traceHit;

	end = Location + normal(vector(Rotation))*32768; // trace to "infinity"
	traceHit = trace(loc, norm, end, Location, true,, hitInfo);

	ClientMessage("");

	if (traceHit == none)
	{
		ClientMessage("Nothing found, try again.");
		return;
	}

	// Play a sound to confirm the information
	ClientPlaySound(SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_TargetLock');

	// By default only 4 console messages are shown at the time
 	ClientMessage("Hit: "$traceHit$"  class: "$traceHit.class.outer.name$"."$traceHit.class);
 	ClientMessage("Location: "$loc.X$","$loc.Y$","$loc.Z);
 	ClientMessage("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
	ClientMessage("Component: "$hitInfo.HitComponent);
}