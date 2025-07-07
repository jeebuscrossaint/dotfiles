{ config, lib, pkgs, ... }:

{
  programs.nixcord = {
    enable = true;
    vesktop.enable = true;

  config = {
    frameless = true;
    plugins = {
      accountPanelServerProfile.enable = true;
      alwaysAnimate.enable = true;
      alwaysExpandRoles.enable = true;
      alwaysTrust.enable = true;
      betterFolders.enable = true;
      betterGifAltText.enable = true;
      betterGifPicker.enable = true;
      betterSessions.enable = true;
      betterSettings.enable = true;
      callTimer.enable = true;
      clearURLs.enable = true;
      colorSighted.enable = true;
      consoleJanitor.enable = true;
      copyUserURLs.enable = true;
      disableCallIdle.enable = true;
      fakeNitro.enable = true;
      fixCodeblockGap.enable = true;
      fixImagesQuality.enable = true;
      fixYoutubeEmbeds.enable = true;
      forceOwnerCrown.enable = true;
      friendsSince.enable = true;
      fullSearchContext.enable = true;
      gameActivityToggle.enable = true;
      gifPaste.enable = true;
      hideAttachments.enable = true;
      iLoveSpam.enable = true;
      imageZoom.enable = true;
      implicitRelationships.enable = true;
      loadingQuotes.enable = true;
      memberCount.enable = true;
      mentionAvatars.enable = true;
      messageClickActions.enable = true;
      messageLatency.enable = true;
      messageLinkEmbeds.enable = true;
      messageLogger.enable = true;
      moreCommands.enable = true;
      moyai.enable = true;
      mutualGroupDMs.enable = true;
      noF1.enable = true;
      noMosaic.enable = true;
      noPendingCount = {
        hideFriendRequestsCount = false;
      };
      noProfileThemes.enable = true;
      noRPC.enable = true;
      noReplyMention.enable = true;
      noServerEmojis.enable = true;
      noSystemBadge.enable = true;
      noTypingAnimation.enable = true;
      oneko.enable = true;
      permissionFreeWill.enable = true;
      permissionsViewer.enable = true;
      platformIndicators.enable = true;
      quickReply.enable = true;
      relationshipNotifier.enable = true;
      reviewDB.enable = true;
      serverInfo.enable = true;
      showHiddenChannels.enable = true;
      showHiddenThings.enable = true;
      showMeYourName.enable = true;
      silentTyping.enable = true;
      translate.enable = true;
    };
  };
};
}
