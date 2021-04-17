class RldOptMidGameOptions extends MidGamePanel;

var RldOptInteraction MyInteraction;
var automated GUISectionBackground i_BGCenter;
var automated moCheckbox ch_AllowInterrupt, ch_DisableAuto, ch_NoAmmoMsg, ch_InterruptMsg, ch_NeedReloadMsg;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
  Super.Initcomponent(MyController, MyOwner);

  i_BGCenter.ManageComponent(ch_AllowInterrupt);
  i_BGCenter.ManageComponent(ch_DisableAuto);
  i_BGCenter.ManageComponent(ch_NoAmmoMsg);
  i_BGCenter.ManageComponent(ch_InterruptMsg);
  i_BGCenter.ManageComponent(ch_NeedReloadMsg);
}

function ShowPanel(bool bShow) {
  Super.ShowPanel(bShow);

  if (bShow) {
    ch_AllowInterrupt.SetComponentValue(MyInteraction.bAllowInterrupt, true);
    ch_DisableAuto.SetComponentValue(MyInteraction.bDisableAuto, true);
    ch_NoAmmoMsg.SetComponentValue(MyInteraction.bNoAmmoMsg, true);
    ch_InterruptMsg.SetComponentValue(MyInteraction.bInterruptMsg, true);
    ch_NeedReloadMsg.SetComponentValue(MyInteraction.bNeedReloadMsg, true);
  }
}

function UpdateCheckboxVisibility() {
  if (ch_AllowInterrupt.IsChecked())
    ch_InterruptMsg.EnableMe();
  else
    ch_InterruptMsg.DisableMe();

  if (ch_DisableAuto.IsChecked())
    ch_NeedReloadMsg.EnableMe();
  else
    ch_NeedReloadMsg.DisableMe();
}

function InternalOnChange(GUIComponent Sender) {
  switch (Sender) {
    case ch_AllowInterrupt:
      MyInteraction.bAllowInterrupt = ch_AllowInterrupt.IsChecked();
      UpdateCheckboxVisibility();
      MyInteraction.SaveConfig();
      break;
    case ch_DisableAuto:
      MyInteraction.bDisableAuto = ch_DisableAuto.IsChecked();
      UpdateCheckboxVisibility();
      MyInteraction.SaveConfig();
      break;
    case ch_NoAmmoMsg:
      MyInteraction.bNoAmmoMsg = ch_NoAmmoMsg.IsChecked();
      MyInteraction.SaveConfig();
      break;
    case ch_InterruptMsg:
      MyInteraction.bInterruptMsg = ch_InterruptMsg.IsChecked();
      MyInteraction.SaveConfig();
      break;
    case ch_NeedReloadMsg:
      MyInteraction.bNeedReloadMsg = ch_NeedReloadMsg.IsChecked();
      MyInteraction.SaveConfig();
      break;
  }
}

defaultproperties
{
   Begin Object Class=GUISectionBackground Name=BGCenter
     // bFillClient=True
     Caption="Reload Options"
      WinTop=0.03
      WinLeft=0.25
      WinWidth=0.5
      WinHeight=0.5
   End Object
   i_BGCenter=GUISectionBackground'ReloadOptionsSP.RldOptMidGameOptions.BGCenter'

   Begin Object Class=moCheckBox Name=AllowInterrupt
     Caption="Allow to interrupt"
     OnCreateComponent=AllowInterrupt.InternalOnCreateComponent
     Hint="Allow actions to interrupt the reload animation."
     TabOrder=0
     bBoundToParent=True
     bScaleToParent=True
     OnChange=RldOptMidGameOptions.InternalOnChange
   End Object
   ch_AllowInterrupt=moCheckBox'ReloadOptionsSP.RldOptMidGameOptions.AllowInterrupt'

   Begin Object Class=moCheckBox Name=DisableAuto
     Caption="Disable auto-reload"
     OnCreateComponent=DisableAuto.InternalOnCreateComponent
     Hint="Play a dry-fire sound instead of triggering auto-reload."
     TabOrder=2
     bBoundToParent=True
     bScaleToParent=True
     OnChange=RldOptMidGameOptions.InternalOnChange
   End Object
   ch_DisableAuto=moCheckBox'ReloadOptionsSP.RldOptMidGameOptions.DisableAuto'

   Begin Object Class=moCheckBox Name=NoAmmoMsg
     Caption="'No ammo!' message"
     OnCreateComponent=NoAmmoMsg.InternalOnCreateComponent
     Hint="Show this message when you try to fire a weapon that has no ammo."
     TabOrder=4
     bBoundToParent=True
     bScaleToParent=True
     OnChange=RldOptMidGameOptions.InternalOnChange
   End Object
   ch_NoAmmoMsg=moCheckBox'ReloadOptionsSP.RldOptMidGameOptions.NoAmmoMsg'

   Begin Object Class=moCheckBox Name=InterruptMsg
     Caption="'Interrupted!' message"
     OnCreateComponent=InterruptMsg.InternalOnCreateComponent
     Hint="Show this message when the reload animation is interrupted."
     TabOrder=1
     bBoundToParent=True
     bScaleToParent=True
     OnChange=RldOptMidGameOptions.InternalOnChange
   End Object
   ch_InterruptMsg=moCheckBox'ReloadOptionsSP.RldOptMidGameOptions.InterruptMsg'

   Begin Object Class=moCheckBox Name=NeedReloadMsg
     Caption="'You need to reload!' message"
     OnCreateComponent=NeedReloadMsg.InternalOnCreateComponent
     Hint="Show this message when you need to reload."
     TabOrder=3
     bBoundToParent=True
     bScaleToParent=True
     OnChange=RldOptMidGameOptions.InternalOnChange
   End Object
   ch_NeedReloadMsg=moCheckBox'ReloadOptionsSP.RldOptMidGameOptions.NeedReloadMsg'

}
