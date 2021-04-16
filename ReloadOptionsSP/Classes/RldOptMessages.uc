class RldOptMessages extends CriticalEventPlus;

var array<string> ReloadMessage[4];

static function string GetString (optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject) {
  if (Switch >= 0 && Switch <= 3)
    return default.ReloadMessage[Switch];
}

defaultproperties
{
  ReloadMessage(0)="No ammo!"
  ReloadMessage(1)="You need to reload!"
  ReloadMessage(2)="Interrupted!"
  DrawColor=(B=0,G=0,R=220)
  FontSize=-2
}
