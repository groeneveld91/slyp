var slypApp = window.slypApp || {};

slypApp.Controller = Marionette.Object.extend({
  initialize: function() {
    slypApp.userSlyps = new slypApp.Collections.UserSlyps([{},{},{},{},{},{},{},{},{}]);
    slypApp.user = new slypApp.Models.User();
    slypApp.persons = new slypApp.Collections.Persons();
    slypApp.persons.fetch().done(function(){
      slypApp.feedRegion.show(new slypApp.Views.FeedLayout({
        model     : slypApp.user,
        collection: slypApp.userSlyps
      }));
    });
    slypApp.navBarRegion.show(new slypApp.Views.NavBar());

    // TODO: find a better place for this
    slypApp.binder = rivets.bind($('body, html'), {
      appState: slypApp.state,
      user: slypApp.user
    });
  }
});