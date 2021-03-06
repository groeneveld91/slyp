slypApp.Views.Person = Backbone.Marionette.ItemView.extend({
  template: '#js-person-tmpl',
  className: 'item',
  attributes: {
    'rv-data-person-id' : 'person:id',
    'style'             : 'padding:1em;'
  },
  onRender: function(){
    this.state = {
      loading: false,
    }
    this.binder = rivets.bind(this.$el, {
      person: this.model,
      state: this.state
    });
  },
  events: {
    'click button.ui.icon' : 'toggleFriendship'
  },
  toggleFriendship: function(){
    this.state.loading = true;
    var context = this;
    this.model.toggleFriendship(function(){
      context.state.loading = false;
    })
  },
});
