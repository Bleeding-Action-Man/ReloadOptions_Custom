class ReloadOptionsSP extends Mutator
  config(ReloadOptionsSP_Config);

const DEFAULT_DELAY = 0.3;

struct InterruptibleWeapon {
  var string WeaponClass;
  var float interruptDelay;
};

var const string ResetAmmoString;
var array<InterruptibleWeapon> RldOptWeapons;

/* The delay before the reload animation is considered interrupted and the weapon's magAmmoRemaining is set to zero. */
static function float GetInterruptDelay(KFPlayerController aPlayerController, KFWeapon aWeapon) {
  local KFPlayerReplicationInfo PRI;
  local float reloadMulti;
  local int i;

  PRI = KFPlayerReplicationInfo(aPlayerController.PlayerReplicationInfo);
  if (PRI != None && PRI.ClientVeteranSkill != None)
    reloadMulti = PRI.ClientVeteranSkill.static.GetReloadSpeedModifier(PRI, aWeapon);
  else
    reloadMulti = 1.0;

  for (i = 0; i < default.RldOptWeapons.length; i++)
    if (string(aWeapon.Class) ~= default.RldOptWeapons[i].WeaponClass)
      return default.RldOptWeapons[i].interruptDelay / reloadMulti;

  return DEFAULT_DELAY / reloadMulti;
}

/* Because replicating from an interaction is a bitch. */
function Mutate(string MutateString, PlayerController Sender) {
  if (Sender.Pawn != None && KFWeapon(Sender.Pawn.Weapon) != None && MutateString ~= default.ResetAmmoString)
    KFWeapon(Sender.Pawn.Weapon).magAmmoRemaining = 0;
  else
    Super.Mutate(MutateString, Sender);
}

/* Add the interaction. */
simulated function Tick(float DeltaTime) {
  local PlayerController PC;
  local RldOptInteraction NewInteraction;

  PC = Level.GetLocalPlayerController();
  if (PC != None && !PC.PlayerReplicationInfo.bIsSpectator) {
    NewInteraction = RldOptInteraction(PC.Player.InteractionMaster.AddInteraction("ReloadOptionsSP.RldOptInteraction", PC.Player));
    NewInteraction.RegisterMutator(Self);
    Disable('Tick');
  }
}

defaultproperties
{
   ResetAmmoString="RldOpt_RstAmmRmnng"
   RldOptWeapons(0)=(WeaponClass="KFMod.MP7MMedicGun",interruptDelay=0.280000)
   RldOptWeapons(1)=(WeaponClass="KFMod.MP5MMedicGun",interruptDelay=0.520000)
   RldOptWeapons(2)=(WeaponClass="KFMod.M7A3MMedicGun",interruptDelay=0.440000)
   RldOptWeapons(3)=(WeaponClass="KFMod.KrissMMedicGun",interruptDelay=0.520000)
   RldOptWeapons(4)=(WeaponClass="KFMod.KSGShotgun",interruptDelay=0.480000)
   RldOptWeapons(5)=(WeaponClass="KFMod.NailGun",interruptDelay=0.560000)
   RldOptWeapons(6)=(WeaponClass="KFMod.SPAutoShotgun",interruptDelay=0.450000)
   RldOptWeapons(7)=(WeaponClass="KFMod.AA12AutoShotgun",interruptDelay=0.460000)
   RldOptWeapons(8)=(WeaponClass="KFMod.GoldenAA12AutoShotgun",interruptDelay=0.460000)
   RldOptWeapons(9)=(WeaponClass="KFMod.Single",interruptDelay=0.290000)
   RldOptWeapons(10)=(WeaponClass="KFMod.Dualies",interruptDelay=0.380000)
   RldOptWeapons(11)=(WeaponClass="KFMod.Magnum44Pistol",interruptDelay=0.300000)
   RldOptWeapons(12)=(WeaponClass="KFMod.Deagle",interruptDelay=0.430000)
   RldOptWeapons(13)=(WeaponClass="KFMod.GoldenDeagle",interruptDelay=0.430000)
   RldOptWeapons(14)=(WeaponClass="KFMod.MK23Pistol",interruptDelay=0.430000)
   RldOptWeapons(15)=(WeaponClass="KFMod.Dual44Magnum",interruptDelay=0.260000)
   RldOptWeapons(16)=(WeaponClass="KFMod.DualMK23Pistol",interruptDelay=0.360000)
   RldOptWeapons(17)=(WeaponClass="KFMod.DualDeagle",interruptDelay=0.360000)
   RldOptWeapons(18)=(WeaponClass="KFMod.GoldenDualDeagle",interruptDelay=0.360000)
   RldOptWeapons(19)=(WeaponClass="KFMod.SPSniperRifle",interruptDelay=0.490000)
   RldOptWeapons(20)=(WeaponClass="KFMod.M14EBRBattleRifle",interruptDelay=0.450000)
   RldOptWeapons(21)=(WeaponClass="KFMod.Bullpup",interruptDelay=0.580000)
   RldOptWeapons(22)=(WeaponClass="KFMod.ThompsonSMG",interruptDelay=0.500000)
   RldOptWeapons(23)=(WeaponClass="KFMod.SPThompsonSMG",interruptDelay=0.560000)
   RldOptWeapons(24)=(WeaponClass="KFMod.ThompsonDrumSMG",interruptDelay=0.560000)
   RldOptWeapons(25)=(WeaponClass="KFMod.AK47AssaultRifle",interruptDelay=0.470000)
   RldOptWeapons(26)=(WeaponClass="KFMod.GoldenAK47AssaultRifle",interruptDelay=0.470000)
   RldOptWeapons(27)=(WeaponClass="KFMod.M4AssaultRifle",interruptDelay=0.570000)
   RldOptWeapons(28)=(WeaponClass="KFMod.MKb42AssaultRifle",interruptDelay=0.400000)
   RldOptWeapons(29)=(WeaponClass="KFMod.SCARMK17AssaultRifle",interruptDelay=0.480000)
   RldOptWeapons(30)=(WeaponClass="KFMod.FNFAL_ACOG_AssaultRifle",interruptDelay=0.640000)
   RldOptWeapons(31)=(WeaponClass="KFMod.MAC10MP",interruptDelay=0.460000)
   RldOptWeapons(32)=(WeaponClass="KFMod.FlareRevolver",interruptDelay=0.580000)
   RldOptWeapons(33)=(WeaponClass="KFMod.FlameThrower",interruptDelay=0.400000)
   RldOptWeapons(34)=(WeaponClass="KFMod.GoldenFlamethrower",interruptDelay=0.400000)
   RldOptWeapons(35)=(WeaponClass="KFMod.DualFlareRevolver",interruptDelay=0.410000)
   RldOptWeapons(36)=(WeaponClass="KFMod.M4203AssaultRifle",interruptDelay=0.570000)
   RldOptWeapons(37)=(WeaponClass="KFMod.ZEDGun",interruptDelay=0.570000)
   RldOptWeapons(38)=(WeaponClass="KFMod.BlowerThrower",interruptDelay=0.730000)
   RldOptWeapons(39)=(WeaponClass="KFMod.SealSquealHarpoonBomber",interruptDelay=0.700000)
   RldOptWeapons(40)=(WeaponClass="KFMod.SeekerSixRocketLauncher",interruptDelay=0.530000)
   RldOptWeapons(41)=(WeaponClass="KFMod.ZEDMKIIWeapon",interruptDelay=0.450000)
   RldOptWeapons(42)=(WeaponClass="KFMod.CamoM4AssaultRifle",interruptDelay=0.570000)
   RldOptWeapons(43)=(WeaponClass="KFMod.CamoMP5MMedicGun",interruptDelay=0.520000)
   bAddToServerPackages=True
   GroupName="KF-ReloadOptions"
   FriendlyName="Reload Options - v1.0"
   Description="Adds options to customize reload; Modified by Vel-San to support ServerPerks."
   bAlwaysRelevant=True
   RemoteRole=ROLE_SimulatedProxy
}
