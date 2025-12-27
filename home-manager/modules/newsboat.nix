{
  config,
  pkgs,
  ...
}:
{
  programs.newsboat = {
    enable = true;
    # # package = pkgs.emptyDirectory;

    urls = [
      # YouTube Channels
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCrqM0Ym_NbK1fqeQG2VIohg";
        title = "Tsoding Daily";
      }
      {
        url = "https://videos.lukesmith.xyz/feeds/videos.xml?accountName=luke";
        title = "Luke Smith (PeerTube)";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC22BdTgxefuvUivrjesETjg";
        title = "History Matters";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCld68syR8Wi-GY_n4CaoJGA";
        title = "Brodie Robertson";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC1D3yD4wlPMico0dss264XA";
        title = "NileBlue";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCpp3cHR9TWVyXqL1AVw4XkA";
        title = "Mike Okay";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC_62yC0A7f1LnH4R8cEa8Lw";
        title = "ironic.";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC8xo16miz2Jjji93BhE9Yug";
        title = "RubenSim";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCEbYhDd6c6vngsF5PQpFVWg";
        title = "Tsoding";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCWAKxzKNvdbbGGwBVkZR31Q";
        title = "Chessed Gamon";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCJVnko6tQ56PYB5BNNChPGg";
        title = "ibx2cat";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCwHwDuNd9lCdA7chyyquDXw";
        title = "BreadOnPenguins";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCti74Totvg_9KJHV1mCkKoA";
        title = "Drew_Irl";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCUyeluBRhGPCW4rPe_UvBZQ";
        title = "The PrimeTime";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCR-DXc1voovS8nhAvccRZhg";
        title = "Jeff Geerling";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCRYOj4DmyxhBVrdvbsUwmAA";
        title = "optimumtech";
      }
      {
        url = "https://odysee.com/$/rss/@AlphaNerd:8";
        title = "Mental Outlaw (Odysee)";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC6biysICWOJ-C3P4Tyeggzg";
        title = "Low Level";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC_slDWTPHflhuZqbGc8u4yA";
        title = "Rainbolt";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCgsCiwJ88up-YyMHo7hL5-A";
        title = "CivDiv";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCOT2iLov0V7Re7ku_3UBtcQ";
        title = "Hank Green";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCSMdqIt75LUIEiDDMFV37vg";
        title = "neokCS";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC2PcEPhxydGmXaAhd3pAwuA";
        title = "MuYe";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC6IxnFzHofFJ5X2PycSMsww";
        title = "xkcd's what if";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCmmPgObSUPw1HL2lq6H4ffA";
        title = "GeographyNow";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCN17Z31n_ionhzAjyV7pmXw";
        title = "Nano";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC6AezzO5v1aFTEEyzcCJdyQ";
        title = "Dario Tringali";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCSnqXeK94-iNmwqGO__eJ5g";
        title = "Steve Wallis";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC8iPVSFr42KUFf8DKsmnvSw";
        title = "GIFGAS";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UC2C_jShtL725hvbm1arSV9w";
        title = "CGPGrey";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCszl3gAXAVFfCZGxnURvGIg";
        title = "Core Dumped";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCl2mFZoRqjw_ELax4Yisf6w";
        title = "Louis Rossman";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCJDIGW0ywWw9Kh9_vtwqxXA";
        title = "William Spaniel";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCBJycsmduvYEL83R_U4JriQ";
        title = "Marques Brownlee";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCr3cBLTYmIK9kY0F_OdFWFQ";
        title = "Casually Explained";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCEcrRXW3oEYfUctetZTAWLw";
        title = "Waveform";
      }
      {
        url = "https://drewdevault.com/blog/index.xml";
        title = "Drew DeVault's Blog";
      }
      {
        url = "https://cheapskatesguide.org/cheapskates-guide-rss-feed.xml";
        title = "Cheapskate's Guide to the Internet";
      }
      {
        url = "https://jcs.org/rss";
        title = "joshua stein";
      }
      {
        url = "https://jcs.org/notes/rss";
        title = "joshua stein - notes";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCYO_jab_esuFRV4b17AJtAw";
        title = "3Blue1Brown";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UChHxJaKDqH4bOs0pX3hkKnA";
        title = "BasicallyHomeless";
      }
      {
        url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCshObcm-nLhbu8MY50EZ5Ng";
        title = "Benn Jordan";
      }
    ];

    # Configuration options
    maxItems = 500;
    reloadThreads = 8;
    autoReload = true;
    reloadTime = 30;

    # Queries for filtering
    queries = {
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
      notify-program "notify-send"

      # HTML renderer
      html-renderer "${pkgs.w3m}/bin/w3m -T text/html -dump"

      # Podboat (podcast) settings
      podcast-auto-enqueue yes
      player "mpv"
    '';
  };
}
