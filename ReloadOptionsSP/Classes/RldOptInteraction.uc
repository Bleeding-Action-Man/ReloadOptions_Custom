class RldOptInteraction extends Interaction
  config(ReloadOptionsSP_Config);

var ReloadOptionsSP Mut;
var KFPlayerController PC;
var GUI.GUITabItem ReloadOpt_Tab;
var config bool bAllowInterrupt, bDisableAuto, bNoAmmoMsg, bInterruptMsg, bNeedReloadMsg;
var config array<string> InterruptAliases;
var float timeReloaded, timeReceivedMessage;
var string ReloadOptClass_SP;

///////////////////////////
//		INTERACTION		//
/////////////////////////
function Initialize() {
  PC = KFPlayerController(ViewportOwner.Actor);
  if (PC == None)
    Master.RemoveInteraction(Self);

  if (InterruptAliases.length == 0)
    InterruptAliases = default.InterruptAliases;
}

event NotifyLevelChange() {
  Master.RemoveInteraction(Self);
}

function RegisterMutator(ReloadOptionsSP aMut) {
  Mut = aMut;
  SaveConfig();
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta) {
  local string Alias, Alias_SP, LeftPart, RigthPart;
  local MidGamePanel panel;
  local UT2K4PlayerLoginMenu escMenu;
  local int i;

  Alias_SP = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key));
  if (Action == IST_Press) {
    Alias = PC.ConsoleCommand("KEYBINDING" @ PC.ConsoleCommand("KEYNAME" @ Key));
    if (Divide(Alias, " ", LeftPart, RigthPart))
      Alias = LeftPart;

    if (Alias ~= "ReloadWeapon" || Alias ~= "ReloadMeNow") {
      SetTimeReloaded();
    }
    else {
      for (i = 0; i < InterruptAliases.length; i++) {
        if (Alias ~= InterruptAliases[i]) {
          if (Alias ~= "Fire")
            InterruptReload(true);
          else if (Alias ~= "AltFire")
            InterruptReload(, true);
          else
            InterruptReload();

          break;
        }
      }

      if (Alias ~= "Fire") {
        return ShouldDryFire();
      }
      else if (Alias ~= "AltFire") {
        ClearReloadMessages();
        return ShouldDryFire(true);
      }
      else if (Alias ~= "ShowMenu") {
        if (KFGUIController(ViewportOwner.GUIController).ActivePage == None) {
            ViewportOwner.Actor.ShowMenu();
          }
        escMenu= UT2K4PlayerLoginMenu(KFGUIController(ViewportOwner.GUIController).ActivePage);
        if (escMenu != none && escMenu.c_Main.TabIndex(ReloadOpt_Tab.caption) == -1) {
          if (escMenu.IsA('SRInvasionLoginMenu')) {
          ReloadOpt_Tab.ClassName = ReloadOptClass_SP;
          }
          panel= MidGamePanel(escMenu.c_Main.AddTabItem(ReloadOpt_Tab));
          if (panel != none) {
          panel.ModifiedChatRestriction= escMenu.UpdateChatRestriction;
          }
        }
      }
      else if (Alias ~= "SwitchModes") {
        ClearReloadMessages(true);
      }
    }
  }

  return false;
}

///////////////////////
//		WEAPON		//
/////////////////////
static function bool WeaponIsRelevant(KFWeapon aWeapon, optional bool bIncludeSingleShot, optional bool bIncludeHoldToReload) {
  return !aWeapon.default.bMeleeWeapon && aWeapon.default.bConsumesPhysicalAmmo && (aWeapon.default.magCapacity > 1 || bIncludeSingleShot) && (!aWeapon.default.bHoldToReload || bIncludeHoldToReload);
}

static function bool AltFireConsumesPrimaryAmmo(KFWeapon aWeapon) {
  return BlowerThrower(aWeapon) != None || Boomstick(aWeapon) != None || SeekerSixRocketLauncher(aWeapon) != None || ZEDGun(aWeapon) != None || ZEDMKIIWeapon(aWeapon) != None;
}

static function bool AltFireConsumesSecondaryAmmo(KFWeapon aWeapon) {
  return M4203AssaultRifle(aWeapon) != None;
}

static function bool AltFireSwitchesModes(KFWeapon aWeapon) {
  return !AltFireConsumesSecondaryAmmo(aWeapon) && (AA12AutoShotgun(aWeapon) != None || AK47AssaultRifle(aWeapon) != None || Bullpup(aWeapon) != None || FNFAL_ACOG_AssaultRifle(aWeapon) != None || KSGShotgun(aWeapon) != None || M4AssaultRifle(aWeapon) != None || MAC10MP(aWeapon) != None || MKb42AssaultRifle(aWeapon) != None || SCARMK17AssaultRifle(aWeapon) != None || ThompsonSMG(aWeapon) != None);
}

static function bool AltFireIsToggle(KFWeapon aWeapon) {
  return AltFireSwitchesModes(aWeapon) || M14EBRBattleRifle(aWeapon) != None || NailGun(aWeapon) != None || string(aWeapon.Class) ~= "KFMod.Single" || string(aWeapon.Class) ~= "KFMod.Dualies";
}

function bool AllowAltFire(KFWeapon aWeapon) {
  return AltFireConsumesPrimaryAmmo(aWeapon) && aWeapon.magAmmoRemaining >= aWeapon.GetFireMode(1).ammoPerFire;
}

function bool ForceAltFire(KFWeapon aWeapon) {
  return AltFireConsumesSecondaryAmmo(aWeapon) && aWeapon.AmmoAmount(1) >= 1 || KFMedicGun(aWeapon) != None && KFMedicGun(aWeapon).healAmmoCharge >= aWeapon.GetFireMode(1).ammoPerFire || SPAutoShotgun(aWeapon) != None;
}

function bool ShouldInterrupt(KFWeapon aWeapon) {
  return WeaponIsRelevant(aWeapon) && aWeapon.bIsReloading;
}

function bool ShouldDisableAuto(KFWeapon aWeapon, optional bool bAltFire) {
  return WeaponIsRelevant(aWeapon) && bDisableAuto && !aWeapon.bIsReloading && aWeapon.magAmmoRemaining < 1 && (bAltFire || HuskGun(aWeapon) == None);
}

function KFWeapon GetWeapon() {
  if (PC.Pawn != None)
    return KFWeapon(PC.Pawn.Weapon);
  else
    return None;
}

///////////////////////////
//		MESSAGES		//
/////////////////////////
/* Send an empty reload message when the player switches modes so different messages don't overlap. */
function ClearReloadMessages(optional bool bSwitchedModes) {
  local KFWeapon W;

  if (PC.Level.timeSeconds - timeReceivedMessage > class'ReloadOptionsSP.RldOptMessages'.default.lifeTime)
    return;

  W = GetWeapon();
  if (W != None && (W.ReadyToFire(0) || bSwitchedModes) && AltFireSwitchesModes(W)) {
    PC.ReceiveLocalizedMessage(class'ReloadOptionsSP.RldOptMessages', 3);
    timeReceivedMessage = 0;
  }
}

/* Send two empty messages to clear any default switch messages before sending our message. */
function SendReloadMessage(bool bShouldReceive, int aSwitch) {
  if (bShouldReceive) {
    PC.ReceiveLocalizedMessage(class'KFMod.KSGSwitchMessage', 8);
    PC.ReceiveLocalizedMessage(class'KFMod.BullpupSwitchMessage', 8);
    PC.ReceiveLocalizedMessage(class'ReloadOptionsSP.RldOptMessages', aSwitch);
    timeReceivedMessage = PC.Level.timeSeconds;
  }
}

///////////////////////////////////////
//		FIRING AND INTERRUPTING		//
/////////////////////////////////////
function SetTimeReloaded() {
  local KFWeapon W;

  W = GetWeapon();
  if (W != None && !W.bIsReloading)
    timeReloaded = PC.Level.timeSeconds;
}

/**
 * Play a dry-fire sound for empty weapons;
 * do nothing when the player selects a weapon via the inventory HUD.
 */
function bool ShouldDryFire(optional bool bAltFire) {
  local HUDKillingFloor HUD;
  local KFWeapon W;

  HUD = HUDKillingFloor(PC.MyHUD);
  W = GetWeapon();
  if (!bAltFire && HUD != None && HUD.bDisplayInventory || W == None)
    return false;

  if (!bAltFire) {
    if (W.AmmoAmount(0) == 0 && WeaponIsRelevant(W, true, true)) {
      W.PlayOwnedSound(W.GetFireMode(0).NoAmmoSound, SLOT_None, 2.0,,,, false);
      SendReloadMessage(bNoAmmoMsg, 0);
      return true;
    }
    else if (ShouldDisableAuto(W)) {
      W.PlayOwnedSound(W.GetFireMode(0).NoAmmoSound, SLOT_None, 2.0,,,, false);
      SendReloadMessage(bNeedReloadMsg, 1);
      return true;
    }
  }
  else {
    if (AltFireConsumesPrimaryAmmo(W)) {
      if (W.AmmoAmount(0) == 0) {
        W.PlayOwnedSound(W.GetFireMode(0).NoAmmoSound, SLOT_None, 2.0,,,, false);
        SendReloadMessage(bNoAmmoMsg, 0);
        return true;
      }
      else if (ShouldDisableAuto(W, true)) {
        W.PlayOwnedSound(W.GetFireMode(0).NoAmmoSound, SLOT_None, 2.0,,,, false);
        SendReloadMessage(bNeedReloadMsg, 1);
        return true;
      }
    }
    else if (W.AmmoAmount(1) == 0 && AltFireConsumesSecondaryAmmo(W)) {
      W.PlayOwnedSound(W.GetFireMode(1).NoAmmoSound, SLOT_None, 2.0,,,, false);
      SendReloadMessage(bNoAmmoMsg, 0);
      return true;
    }
  }

  return false;
}

/**
 * Interrupt the reloading animation, which may reset the weapon's magAmmoRemaining;
 * don't allow Fire() and AltFire() to interrupt if magAmmoRemaining will be reset,
 * but make an exception either if the player uses Fire() to select a weapon via the inventory HUD
 * or if the player uses AltFire() and the weapon has a separate alt-fire mode that can fire right now.
 */
function InterruptReload(optional bool bFireAlias, optional bool bAltFireAlias) {
  local KFWeapon W;
  local HUDKillingFloor HUD;
  local bool bDelayExceeded, bDisplayInventory, bWeReallyShould;

  W = GetWeapon();
  if (W == None)
    return;

  HUD = HUDKillingFloor(PC.MyHUD);
  bDisplayInventory = HUD != None && HUD.bDisplayInventory;

  bDelayExceeded = PC.Level.timeSeconds - timeReloaded > Mut.static.GetInterruptDelay(PC, W);

  if (bFireAlias)
    bWeReallyShould = bDisplayInventory || W.magAmmoRemaining >= W.GetFireMode(0).ammoPerFire && !bDelayExceeded;
  else if (bAltFireAlias)
    bWeReallyShould = ForceAltFire(W) || !bDelayExceeded && (AllowAltFire(W) || AltFireIsToggle(W));
  else
    bWeReallyShould = true;

  if (bAllowInterrupt && ShouldInterrupt(W) && bWeReallyShould) {
    W.ServerInterruptReload();
    if (PC.Level.NetMode != NM_StandAlone && (PC.Level.NetMode != NM_ListenServer || !PC.Pawn.IsLocallyControlled()))
      W.ClientInterruptReload();

    if (W.magAmmoRemaining > 0 && bDelayExceeded) {
      PC.ServerMutate(Mut.default.ResetAmmoString);
      SendReloadMessage(bInterruptMsg, 2);
    }
  }
}

defaultproperties
{
   ReloadOptClass_SP="ReloadOptionsSP.RldOptMidGameOptions_SP"
   ReloadOpt_Tab=(ClassName="ReloadOptionsSP.RldOptMidGameOptions",Caption="Reload Options",Hint="Options to customize reload.")
   InterruptAliases(0)="Fire"
   InterruptAliases(1)="AltFire"
   InterruptAliases(2)="ThrowNade"
   InterruptAliases(3)="ThrowGrenade"
   InterruptAliases(4)="GetWeapon"
   InterruptAliases(5)="SwitchWeapon"
   InterruptAliases(6)="SwitchToLastWeapon"
}
