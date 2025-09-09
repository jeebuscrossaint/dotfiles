{
  config,
  pkgs,
  ...
}: {
  programs.newsboat = {
    enable = true;

    urls = [
      # YouTube Channels
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCrqM0Ym_NbK1fqeQG2VIohg";
        title = "Tsoding Daily";
        tags = ["programming" "youtube" "streams"];
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC2eYFnH61tmytImy1mTYvhA";
        title = "Luke Smith";
        tags = ["linux" "youtube" "suckless"];
      }
    ];

    # Configuration options
    maxItems = 100;
    reloadThreads = 8;
    autoReload = true;
    reloadTime = 5; # 30 minutes

    # Queries for filtering
    queries = {
      "programming" = ''tags # "programming"'';
      "youtube" = ''tags # "youtube"'';
      "linux" = ''tags # "linux"'';
      "unread" = ''unread = "yes"'';
    };

    extraConfig = ''
      # Key bindings (vim-like)
      bind-key j down
      bind-key k up
      bind-key J next-feed articlelist
      bind-key K prev-feed articlelist
      bind-key G end
      bind-key g home
      bind-key d pagedown
      bind-key u pageup
      bind-key l open
      bind-key h quit
      bind-key a toggle-article-read
      bind-key n next-unread
      bind-key N prev-unread
      bind-key D pb-download
      bind-key U show-urls
      bind-key x pb-delete

      # Formatting
      articlelist-format "%4i %f %D  %?T?|%-17T|  ?%t"
      feedlist-format    "%4i %n %11u %t"
      datetime-format    "%b %d"

      # Misc settings
      auto-reload yes
      external-url-viewer "${pkgs.urlscan}/bin/urlscan -dc -r 'linkhandler {}'"

      # Download path for podcasts
      download-path "~/Downloads/podcasts/%n"

      # Show read articles
      show-read-feeds yes
      show-read-articles yes

      # Cleanup
      cleanup-on-quit yes
      delete-read-articles-on-quit no

      # Performance
      cache-file ~/.cache/newsboat/cache.db

      # Notifications
      notify-always yes
      notify-format "Newsboat: %n unread articles within %f unread feeds"
      notify-program "${pkgs.libnotify}/bin/notify-send"

      # HTML renderer
      html-renderer "${pkgs.w3m}/bin/w3m -T text/html -dump"

      # Podboat (podcast) settings
      podcast-auto-enqueue yes
      player "${pkgs.mpv}/bin/mpv"
    '';
  };
}
