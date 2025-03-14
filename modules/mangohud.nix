{ config, lib, pkgs, ... }:

{
  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
    settings = {
      # Performance metrics
      fps = true;
      frametime = true;
      frame_count = true;
      
      # Hardware monitoring
      cpu_stats = true;
      cpu_temp = true;
      cpu_power = true;
      cpu_mhz = true;
      
      gpu_stats = true;
      gpu_temp = true;
      gpu_core_clock = true;
      gpu_mem_clock = true;
      gpu_power = true;
      gpu_load_change = true;
      
      ram = true;
      vram = true;
      
      # Display options
      position = "top-left";
      legacy_layout = false;
      horizontal = false;
      
      
      # Frame timing graph
      frame_timing = true;
      histogram = true;
      
      # Logging and benchmarking
      log_interval = 500;         # logging interval in milliseconds
      output_folder = "$HOME/mangohud_logs";
      
      # Toggle options
      toggle_hud = "Shift_R+F12";  # Toggle the HUD display
      toggle_logging = "Shift_R+F2";  # Toggle logging
      
      # Control options
      reload_cfg = "Shift_R+F4";  # Reload the configuration
      upload_log = "Shift_R+F5";  # Upload the current log
    };
    
    # Application specific configs
    settingsPerApplication = {
      # Example for Steam games - reduce info for better performance
      steam_games = {
        fps = true;
        frametime = true;
        cpu_stats = true;
        gpu_stats = true;
        gpu_temp = true;
        ram = true;
        # Less details for better game performance
        legacy_layout = true;
        position = "top-right";
        background_alpha = 0.3;
      };
      
      # Benchmark mode for specific games
      "benchmarkgame.exe" = {
        fps = true;
        frame_timing = true;
        cpu_stats = true;
        gpu_stats = true;
        gpu_temp = true;
        gpu_power = true;
        log_interval = 100;
        benchmark_percentiles = true;
        output_file = "$HOME/mangohud_logs/benchmark_results.csv";
        autostart_log = true;
      };
      
      # Media players - minimal overlay to not interfere with viewing
      mpv = {
        position = "top-right";
        fps = true;
        frametime = false;
        background_alpha = 0.2;
        font_size = 16;
        toggle_hud = "Shift_R+F10"; # Different toggle key
      };
    };
  };
}
