NAGE = exports['nage']:getSharedCode()

Crouched = false
CrouchedForce = false
Aimed = false
CoolDown = false
PlayerInfo = {
	playerPed = NAGE.PlayerPedID(),
	playerID = GetPlayerIndex(),
	nextCheck = GetGameTimer() + 1500
}
CoolDownTime = 1000

RefreshPlayerInfo = function(force)
	local now = GetGameTimer()
	if force or now >= PlayerInfo.nextCheck then
		PlayerInfo.playerPed = NAGE.PlayerPedID()
		PlayerInfo.playerID = GetPlayerIndex()
		PlayerInfo.nextCheck = now + 1500
	end
end

NormalWalk = function()
	SetPedMaxMoveBlendRatio(PlayerInfo.playerPed, 1.0)
	ResetPedMovementClipset(PlayerInfo.playerPed, 0.55)
	ResetPedStrafeClipset(PlayerInfo.playerPed)
	SetPedCanPlayAmbientAnims(PlayerInfo.playerPed, true)
	SetPedCanPlayAmbientBaseAnims(PlayerInfo.playerPed, true)
	ResetPedWeaponMovementClipset(PlayerInfo.playerPed)
	Crouched = false
end

SetupCrouch = function()
	while not HasAnimSetLoaded('move_ped_crouched') do
		Wait(5)
		RequestAnimSet('move_ped_crouched')
	end
end

RemoveCrouchAnim = function()
	RemoveAnimDict('move_ped_crouched')
end

CanCrouch = function()
	if IsPedOnFoot(PlayerInfo.playerPed) and not IsPedInAnyVehicle(PlayerInfo.playerPed, false) and not IsPedJumping(PlayerInfo.playerPed)
	and not IsPedFalling(PlayerInfo.playerPed) and not IsPedDeadOrDying(PlayerInfo.playerPed) then
		return true
	else
		return false
	end
end

CrouchPlayer = function()
	SetPedUsingActionMode(PlayerInfo.playerPed, false, -1, "DEFAULT_ACTION")
	SetPedMovementClipset(PlayerInfo.playerPed, 'move_ped_crouched', 0.55)
	SetPedStrafeClipset(PlayerInfo.playerPed, 'move_ped_crouched_strafing')
	SetWeaponAnimationOverride(PlayerInfo.playerPed, "Ballistic")
	Crouched = true
	Aimed = false
end

SetPlayerAimSpeed = function()
	SetPedMaxMoveBlendRatio(PlayerInfo.playerPed, 0.2)
	Aimed = true
end

IsPlayerFreeAimed = function()
	if IsPlayerFreeAiming(PlayerInfo.playerID) or IsAimCamActive() or IsAimCamThirdPersonActive() then
		return true
	else
		return false
	end
end

CrouchLoop = function()
	SetupCrouch()
	while CrouchedForce do
		DisableFirstPersonCamThisFrame()

		RefreshPlayerInfo()

		local CanDo = CanCrouch()
		if CanDo and Crouched and IsPlayerFreeAimed() then
			SetPlayerAimSpeed()
		elseif CanDo and (not Crouched or Aimed) then
			CrouchPlayer()
		elseif not CanDo and Crouched then
			CrouchedForce = false
			NormalWalk()
		end

		Wait(5)
	end
	NormalWalk()
	RemoveCrouchAnim()
end

RegisterCommand('crouch', function()
	DisableControlAction(0, 36, true)
	if not CoolDown then
		RefreshPlayerInfo(true)

		local CanDo = CanCrouch()
		CrouchedForce = CanDo and not CrouchedForce or false

		if CrouchedForce then
			CreateThread(CrouchLoop)
		end

		if CoolDownTime and CoolDownTime ~= 0 then
			CoolDown = true
			SetTimeout(CoolDownTime, function()
				CoolDown = false
			end)
		end
	end
end, false)

RegisterKeyMapping('crouch', 'Crouch', 'keyboard', 'LCONTROL')

IsCrouched = function()
	return Crouched
end

exports("IsCrouched", IsCrouched)