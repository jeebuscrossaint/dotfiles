{ config, lib, pkgs, ... }:

{
  services.swayidle = {
    enable = true;
    
    timeouts = [
      # Lock screen after 2.5 minutes of inactivity
      {
        timeout = 150;
        command = "swaylock";
      }
      # Turn off displays after 10 minutes
      {
        timeout = 600;
        command = "swaymsg 'output * dpms off'";
        resumeCommand = "swaymsg 'output * dpms on'";
      }
      # Suspend system after 15 minutes
      {
        timeout = 900;
        command = "systemctl suspend";
      }
    ];
    
    events = [
      # Lock before sleep (laptop lid close, etc)
      {
        event = "before-sleep";
        command = "swaylock";
      }
      # Lock on explicit lock command
      {
        event = "lock";
        command = "swaylock";
      }
    ];
  };
}
