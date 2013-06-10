/**
 * ## Login button
 *
 * Allow users to log in with auth services that you have hooked on your app.
 * For a more complete widget, look at the Identity widget.
 *
 * ### Examples
 *
 *     <div data-hull-widget="login_button@hull"></div>
 *     <div data-hull-widget="login_button@hull" data-hull-provider="instagram"></div>
 *     <div data-hull-widget="login_button@hull" data-hull-provider="facebook"></div>
 *     <div data-hull-widget="login_button@hull" data-hull-provider="github"></div>
 *     <div data-hull-widget="login_button@hull" data-hull-provider="github,facebook"></div>
 *
 * ### Options
 *
 * - `provider`: Optional, One or more providers to log users in.
 *   If none specified, will show all configured providers for the app.
 *
 * ### Template
 *
 * - `login_button`: Show login buttons if the user isn't logged, logout button if he is.
 *
 */
define({
  type: 'Hull',

  templates: [
    'login_button'
  ],

  options:{
    provider:''
  },

  refreshEvents: ['model.hull.me.change'],

  initialize: function() {
    this.authServices = _.map(this.sandbox.config.services.types.auth, function(s) {
      return s.replace(/_app$/, '');
    });

    if (_.isEmpty(this.authServices)) {
      console.error('No Auth services configured. please add one to be able to authenticate users.');
    }
  },

  beforeRender: function(data) {

    // If providers are specified, then use only those. else use all configuredauthServices
    if(this.options.provider){
      data.providers = this.options.provider.replace(' ','').split(',');
    } else {
      data.providers = this.authServices || [];
    }

    // If I'm logged in, then create an array of logged In providers
    if(this.loggedIn()){
      data.loggedInProviders = _.keys(this.loggedIn());
    } else {
      data.loggedInProviders = [];
    }


    // Create an array of logged out providers.
    data.loggedOut = _.difference(data.providers, data.loggedInProviders);
    data.matchingProviders = _.intersection(data.providers, data.loggedInProviders);
    data.authServices = this.authServices;

    return data;
  }
});
