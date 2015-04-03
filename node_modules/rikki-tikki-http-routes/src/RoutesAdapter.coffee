# Adapter = require 'rikki-tikki-route-adapter'
class RoutesAdapter # extends Adapter
  required:['router']
  constructor:(@params)->
    @params.app?.on 'request', => @requestHandler.apply @, arguments
  addRoute:(route, method, handler)->
    @params.router[method.toLowerCase()]? route, handler || @responseHandler
  requestHandler:(req, res)->
    @params.router req, res, @responseHandler
  responseHandler:(res, data, headers)->
    unless headers
      res.setHeader 'Content-Type', 'application/json'
    else
      for header,value of headers
        res.setHeader header, value
    res.writeHead "#{data.status}", if data.status != 200 then "#{data.content}" else 'ok'
    res.end if data.status == 200 then (if typeof data.content is 'object' then JSON.stringify data.content else data.content) else ""
module.exports = RoutesAdapter
try 
  API = require '../../rikki-tikki' unless (API = require 'rikki-tikki')?
  API.registerAdapter 'routes', RoutesAdapter
catch e
  console.log e
  console.log 'RoutesAdapter not registered.\nreason: rikki-tikki was not found'
module.exports.use = (http, router)=>
  new RoutesAdapter {app:http, router:router}