slypApp.Views.UserSlyp = Backbone.Marionette.CompositeView.extend({
  template: '#js-slyp-card-tmpl',
  className: 'ui card',
  attributes: {
    'rv-fade-hide' : 'userSlyp.hideArchived < :archived',
    'rv-class-red' : 'userSlyp.needsAttention < :unseen_replies :unseen_activity :unseen',
    'style'        : 'background-color:white;',
    'rv-id'        : 'state.id'
  },
  initialize: function(options){
    var context = this;
    var setId = function(){
      context.state.id = 'card-' + context.model.index();
    }
    this.state = {
      canReslyp         : false,
      gotAttention      : !this.model.hasConversations() || slypApp.state.isMobile(),
      reslyping         : false,
      comment           : '',
      moreResults       : false,
      intendingToReply  : false,
      quickReplyText    : '',
      loadingQuickReply : false
    }
    setId();
    this.state.hasComment = function(){
      return $.trim(context.state.comment).length > 0;
    }
    this.state.hasQuickReplyText = function(){
      return $.trim(context.state.quickReplyText).length > 0
    }
    this.listenTo(slypApp.persons, 'change:friendship_id update', function(){
      this.model.trigger('change:friends', this.model);
    }, this);
    this.listenTo(slypApp.userSlyps, 'update', function(){
      setId();
    }, this);
  },
  onRender: function(){
    var context = this;
    this.binder = rivets.bind(this.$el, {
      userSlyp : this.model,
      state    : this.state,
      appState : slypApp.state
    });
    if (typeof this.model.get('url') !== 'undefined'){
      this.$('a[href^="' + this.model.get('url') + '"]').on('click', function(){
        if (context.model.get('unseen')){
          context.model.save({ unseen: false });
        }
      });
    }
  },
  onShow: function(){
    var context = this;
    setTimeout(function(){
      var isViewVisible = context.$el.is(':visible')
      if (isViewVisible){
        context.initializeSemanticElements();
      }
    }, 50);

    this.$('textarea').each(function () {
      this.setAttribute('style', 'height:' + (this.scrollHeight+50) + 'px;overflow-y:hidden;');
    }).on('input', function () {
      this.style.height = 'auto';
      this.style.height = (this.scrollHeight) + 'px';
    });

    var hotPreviewId = getParameterByName('preview_user_slyp_id');
    if (hotPreviewId != null && hotPreviewId == this.model.get('id')){
      window.history.pushState({}, document.title, window.location.pathname); // requires HTML5
      this.showPreview();
    }
  },
  onDestroy: function(){
    if (this.binder) this.binder.unbind();
  },
  events: {
    'click #conversations'        : 'showConversationsSidebar',
    'click #reslyp-button'        : 'sendSlyp',
    'keypress #reslyp-comment'    : 'sendSlypIfValid',
    'click #archive-action'       : 'toggleArchive',
    'click #favorite-action'      : 'toggleStar',
    'mouseleaveintent'            : 'takeAttention',
    'click #card-preview'         : 'showPreview',
    'click #preview-button'       : 'showPreview',
    'click #title'                : 'showPreview',
    'click #send-button'          : 'reslypAttention',
    'click #conversations-button' : 'showConversationsSidebar',
    'click #comment-label'        : 'intendToReply',
    'click #reslyp-dropdown'      : 'handleDropdownSelect',
    'click #see-more'             : 'seeMoreResults',
    'focusout #quick-reply-input' : 'noReply',
    'keypress #quick-reply-input' : 'sendQuickReplyIfValid',
    'click #quick-reply-button'   : 'sendQuickReply',
    'click #explore-us'           : function(){ notImplemented('Explore'); }
  },

  // Event functions
  showConversationsSidebar: function(){
    this.model.save({ unseen_activity: false });
    slypApp.sidebarRegion.show(new slypApp.Views.Sidebar({ model: this.model }));
    $('.ui.right.sidebar').sidebar('toggle');
  },
  sendSlyp: function(e){
    if (this.state.hasComment()){
      var emails = this.$('#recipient-emails').val().split(',');

      if (emails.length > 0){
        var validatedEmails = _.filter(emails, function(email) { return validateEmail(email) });
        this.reslyp(validatedEmails);
      } else {
        _toastr('error', 'I don\'t see any valid emails to send this slyp to!');
      }
    } else {
      _toastr('error', 'your "why this is shareworthy" comment can\'t be empty, sorry!');
    }
  },
  sendSlypIfValid: function(e){
    if (e.keyCode==13 && this.state.hasComment() && !e.shiftKey){
      e.preventDefault();
      this.$('#reslyp-button').click();
    }
  },
  toggleArchive: function(e){
    var context = this;
    this.model.save({ archived: !this.model.get('archived') },
    {
      success: function() {
        var toastrOptions = {
          'positionClass': 'toast-bottom-left',
          'onclick': function() {
            context.model.save({archived: !context.model.get('archived')});
          },
          'fadeIn': 300,
          'fadeOut': 1000,
          'timeOut': 5000,
          'extendedTimeOut': 1000
        }
        if (context.model.get('archived')){
          _toastr('success', 'Marked as done. Click to Undo.', toastrOptions);
        } else {
          _toastr('success', 'Moved to reading list. Click to Undo.', toastrOptions);
        }
      },
      error: function() { _toastr('error') }
    });
  },
  toggleStar: function(e){
    var context = this;
    this.model.save({ favourite: !this.model.get('favourite') },
    {
      error: function() { _toastr('error') }
    });
  },
  takeAttention: function(){
    if (!this.state.canReslyp && this.$('#reslyp-dropdown').dropdown('is hidden') && this.model.hasConversations()){
      this.state.gotAttention = false;
    }
  },
  showPreview: function(){
    if (this.model.get('unseen')){
      this.model.save({ unseen: false });
    }
    if (slypApp.state.isMobile()){
      this.showModalPreview();
    } else {
      this.showSidebarPreview();
    }
  },
  reslypAttention: function(){
    this.giveAttention();
    this.$('#reslyp-dropdown').click();
  },
  intendToReply: function(){
    if (this.state.intendingToReply){
      this.state.intendingToReply = false;
      this.showConversationsSidebar();
    } else {
      this.state.intendingToReply = true;
      this.$('#quick-reply-input').focus();
    }
  },
  handleDropdownSelect: function(e){
    if (this.model.reslypableFriends().length == 0){
      this.state.moreResults = true;
      var context = this;
      setTimeout(function(){
        context.$('#reslyp-dropdown input.search').focus();
      }, 200);
    }
  },
  seeMoreResults: function(){
    this.state.moreResults = true;
  },
  noReply: function(){
    var context = this;
    setTimeout(function(){ // Gives time to click quick-reply-button event, if applicable.
      context.state.intendingToReply = false;
    }, 200);
  },
  sendQuickReplyIfValid: function(e){
    if (e.keyCode == 13 && this.state.hasQuickReplyText()){
      e.preventDefault();
      this.$('#quick-reply-button').click();
    }
  },
  sendQuickReply: function(){
    var quickReplyText = this.state.quickReplyText;
    this.state.quickReplyText = '';
    this.state.loadingQuickReply = true;
    var context = this;
    Backbone.ajax({
      url: '/replies',
      method: 'POST',
      accepts: {
        json: 'application/json'
      },
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify({
        reslyp_id: context.model.get('latest_conversation').reslyp_id,
        text: quickReplyText
      }),
      success: function(response) {
        context.state.intendingToReply = false;
        context.state.loadingQuickReply = false;
        context.model.save({ unseen_activity: false });
        context.model.fetch();
      },
      error: function(status, err) {
        context.state.quickReplyText = quickReplyText;
        context.state.intendingToReply = true;
        context.state.loadingQuickReply = false;
        _toastr('error', 'I couldn\'t add that reply for some reason :(')
      }
    });
  },

  // Helper functions
  giveAttention: function(){
    this.state.gotAttention = true;
  },
  showModalPreview: function(){
    if (this.model.get('html') == null){
      var context = this;
      this.model.fetch().done(function(){
        slypApp.modalsRegion.show(new slypApp.Views.PreviewModal({ model: context.model }));
      });
    } else {
      slypApp.modalsRegion.show(new slypApp.Views.PreviewModal({ model: this.model }));
    }
  },
  showSidebarPreview: function(){
    slypApp.previewSidebarRegion.show(new slypApp.Views.PreviewSidebar({ model: this.model }));
    $('#js-preview-sidebar-region').sidebar('toggle');
  },
  reslyp: function(emails){
    var comment = this.state.comment;
    this.state.comment = '';
    this.state.reslyping = true;
    var selfReslyp = emails.length == 1 && emails[0] == slypApp.user.get('email');

    var context = this;
    Backbone.ajax({
      url: '/reslyps',
      method: 'POST',
      accepts: {
        json: 'application/json'
      },
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify({
        emails: emails,
        slyp_id: this.model.get('slyp_id'),
        comment: comment
      }),
      success: function(response) {
        if (selfReslyp){
          _toastr('success', 'you saved a personal note.');
        } else{
          _toastr('success', 'you started ' + 'conversation'.pluralize(emails.length));
        }

        // Analytics
        analytics.track('Reslyp', {
          num_emails: emails.length,
          slyp_id: context.model.get('slyp_id'),
          slyp_title: context.model.get('title'),
          slyp_url: context.model.get('url')
        });

        // Onboarder
        context.refreshAfterReslyp(function(){
          mediator.trigger('proceedTo', '5 label')
        });
      },
      error: function(status, err) {
        _toastr('error', 'I couldn\'t send it to some of your friends');
        context.state.comment = comment;
        context.refreshAfterReslyp();
      }
    });
  },
  refreshAfterReslyp: function(callback){
    if (callback == null){
      callback = function(){};
    }
    this.state.reslyping = false;
    this.state.canReslyp = false;
    this.model.fetch().done(callback);
    slypApp.persons.fetch();
    this.refreshDropdown();
  },
  refreshDropdown: function(){
    this.$('#reslyp-dropdown').dropdown('restore defaults');
    this.$('#reslyp-dropdown .text').replaceWith('<div class="default text">send to friends</div>');
  },
  initializeSemanticElements: function(){
    var context = this;
    // User actions
    this.$('#archive-action').popup({
      position: 'bottom left',
      delay: {
        show: 500,
        hide: 0
      }
    });

    this.$('#favorite-action').popup({
      position: 'bottom left',
      delay: {
        show: 500,
        hide: 0
      }
    });

    this.$('#explore-us').popup({
      position: 'bottom left',
      delay: {
        show: 500,
        hide: 0
      }
    });

    // // Misc UI
    this.$('#card-image').error(function () {
        $(this).attr('src', '/assets/blank-image.png');
    });

    this.$('#card-image')
      .visibility({
        'type'       : 'image',
        'transition' : 'fade in',
        'duration'   : 750
    });

    this.$('.blurring.dimmable.image').dimmer({
      on: 'hover'
    });

    // Reslyp dropdown
    this.$('#reslyp-dropdown')
      .dropdown({
        allowAdditions : true,
        direction      : 'upward',
        message        : {
          addResult : 'Send to <b style="font-weight: bold;">{term}</b>',
        }
      });

    this.$('#reslyp-dropdown').dropdown('setting', 'onAdd', function(addedValue, addedText, addedChoice) {
      if (context.model.alreadyExchangedWith(addedValue)){
        _toastr('error', 'it seems as though you have already exchanged this slyp with ' + addedValue);
        return false
      } else {
        context.state.reslyping = false;
        context.state.canReslyp = true;
        if (context.$('#reslyp-dropdown').dropdown('get value') == ''){
          setTimeout(function(){
            context.$('#reslyp-comment').focus();
          }, 100);
        }
      }
      return true
    });

    this.$('#reslyp-dropdown').dropdown('setting', 'onLabelCreate', function(value, text) {
      $(this).find('span').detach();
      if (!validateEmail(value)){
        this.addClass('red');
      }

      // Onboarder
      setTimeout(function(){
        mediator.trigger('proceedTo', '4 send');
      }, 250);
      return this
    });

    this.$('#reslyp-dropdown').dropdown('setting', 'onRemove', function(removedValue, removedText, removedChoice) {
      if (context.$el.find('#reslyp-dropdown a.label').length <= 1){
        context.state.reslyping = false;
        context.state.canReslyp = false;
      }
    });

    this.$('#reslyp-dropdown').dropdown('setting', 'onShow', function(){
      setTimeout(function(){
        var scrollTop     = $(window).scrollTop(),
            elementOffset = context.$('#reslyp-dropdown').offset().top,
            distance      = (elementOffset - scrollTop);
        context.$('#reslyp-dropdown .menu').css('min-height', distance-100);
        context.$('.menu').first().animate({ scrollTop: '0px' });
      }, 250);
    });

    this.$('#reslyp-dropdown').dropdown('setting', 'onHide', function(){
      context.state.moreResults = false;
      context.takeAttention();
    });

    this.$('#reslyp-dropdown').dropdown('setting', 'onLabelRemove', function(value){
      this.popup('destroy');
    });

    this.$('#reslyp-dropdown').dropdown('save defaults');
  }
});