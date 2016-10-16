/**
 * Module dependencies.
 */
var InternalOAuthError, OAuth2Strategy, Strategy, util;

util = require('util');
OAuth2Strategy = require('passport-oauth').OAuth2Strategy;
InternalOAuthError = require('passport-oauth').InternalOAuthError;

/**
 * `Strategy` constructor
 */
Strategy = function(options, verify) {
	options = options || {};
	options.authorizationURL = options.authorizationURL || 'https://nid.naver.com/oauth2.0/authorize?response_type=code';
	if (options.svcType !== undefined) {
		options.authorizationURL += '&svctype=' + options.svcType;
	}
	if (options.authType !== undefined) {
		options.authorizationURL += '&auth_type=' + options.authType;
	}
	options.tokenURL = options.tokenURL || 'https://nid.naver.com/oauth2.0/token';
	OAuth2Strategy.call(this, options, verify);
	this.name = 'naver';
	this._oauth2.setAccessTokenName('access_token');
};

/**
 * Inherit from `OAuthStrategy`.
 */
util.inherits(Strategy, OAuth2Strategy);

/**
 * Retrieve user profile from Naver.
 */
Strategy.prototype.userProfile = function(accessToken, done) {
	this._oauth2.useAuthorizationHeaderforGET(true);
	this._oauth2.get('https://apis.naver.com/nidlogin/nid/getUserProfile.xml', accessToken, function(err, body, res) {
		var e, parser, parser_options, result, xml2js;
		if (err) {
			return done(new InternalOAuthError('failed to fetch user profile', err));
		}
		try {
			parser_options = {
				explicitArray: false
			};
			xml2js = require('xml2js');
			parser = new xml2js.Parser(body, parser_options);
			result = parser.parseString(body, function(err, result) {
				var json, profile;
				json = result.data.response[0];
				profile = {
					provider: 'naver'
				};
				profile.id = json.id[0];
				profile.displayName = json.nickname[0];
				profile.emails = [{
					value: json.email[0]
				}];
				profile._json = {
					email: json.email[0],
					nickname: json.nickname[0],
					enc_id: json.enc_id[0],
					profile_image: json.profile_image[0],
					age: json.age[0],
					birthday: json.birthday[0],
					id: json.id[0]
				};
				profile._raw = body;
				done(null, profile);
			});
		} catch (_error) {
			e = _error;
			done(e);
		}
	});
};


/**
 * Expose `Strategy`.
 */
module.exports = Strategy;