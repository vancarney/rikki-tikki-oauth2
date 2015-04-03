passport      = require 'passport'
oauth2orize   = require 'oauth2orize'
# RikkiTikkiAPI = module.parent.exports.RikkiTikkiAPI
class OAuthModule
  serialize: (client, done)->
    done null, client.id
  deserialize: (id, done)->
    @api.getCollectionManager().getCollection 'Clients', (e,col)=>
      col.findOne id, (e, client)=>
        done?.apply @, unless e then [null, client] else [e,null]
  grant:(client, redirectURI, user, ares, done)->
    code = utils.uid 16
    grant = new Grant code, client.id, redirectURI, user.id, ares.scope
    .on 'save', (e)=>
      done?.apply @, unless e then [null,code] else [e, null]
  exchange:(client, code, redirectURI, done)->
    Clients.findOne code, (err, code)->
      return done e if e
      return done 'invalid client id', false if client.id != code.clientId
      return done 'invalid redirect url', false if redirectURI != code.redirectUri
      token = utils.uid 256
      new Credentials token, code.userId, code.clientId, code.scope
      .on 'save', (e)=>
        done?.apply @, unless e then [null,token] else [e, null]
  onRegister:->
    # initialize oauth2orize service
    server = oauth2orize.createServer()
    server.serializeClient @serialize
    server.deserializeClient @deserialize
    server.grant oauth2orize.grant.code @grant
    server.exchange oauth2orize.exchange.code @exchange
    # inistialize routes
    @api.addRoute  "/#{OAuthModule.namespace}/token", 'post', (req,res)->
      passport.authenticate 'consumer',  session: false
    @api.addRoute "/#{OAuthModule.namespace}/authorize", 'get', (req, res)->
      # console.log 'authorize'
      res.end 'test' #JSON.stringify {body:"authorize"}
    @api.addRoute "#{@api.getAPIPath()}/#{OAuthModule.namespace}/decision", 'get', (req, res)->
      res.end JSON.stringify {body:"decision"}
    @api.addRoute "#{@api.getAPIPath()}/#{OAuthModule.namespace}/token", 'get',  (req, res)->
      res.end JSON.stringify {body:"token"}
  onRemove:->
OAuthModule.namespace = 'auth'
module.exports = OAuthModule
