/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
class UNO_MultiplayerGameInfo extends GameInfo;

auto State PendingMatch
{
Begin:
	StartMatch();
}

defaultproperties
{
	HUDType=class'GameFramework.MobileHUD'
	PlayerControllerClass=class'UNO_MultiplayerGame.UNO_MultiplayerPlayerController'
	DefaultPawnClass=class'UNO_MultiplayerGame.UNO_MultiplayerPawn'
	bDelayedStart=false
}


