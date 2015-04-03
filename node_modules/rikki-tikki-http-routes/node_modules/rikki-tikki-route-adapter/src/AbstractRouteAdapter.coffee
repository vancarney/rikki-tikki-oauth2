class AbstractRouteAdapter extends Object
  required:[]
  constructor:(@params={})->
    # _con = arguments.callee.caller.__super__.constructor
    # # attempts to safely determine name of the Class Constructor returns RikkiTikki.UNDEFINED_CLASSNAME as fallback
    # if typeof (name = _con.constructor.name) == 'undefined'
      # if !(name = if (n = _con.constructor.toString().match /function+\s{1,}([a-zA-Z_0-9]*)/)? then n[1] else null)
        # throw "Invalid Class Instance"
    # if ( name ) != 'AbstractRouteAdapter'
      # return throw "AbstractRouteAdapter can not be directly instatiated. Use a subclass instead."
    for param in @required
      throw Error "required param '#{param}' was not defined in the adapter params object" if !(@params.hasOwnProperty param)
  requestHandler:(req,res)->
    throw 'AbstractRouteAdapter.requestHandler(req,res) must be implemented by subclass' 
  responseHandler:(req,res)->
    throw 'AbstractRouteAdapter.responseHandler(req,res) must be implemented by subclass'
  addRoute:(route, method, handler)->
    throw 'AbstractRouteAdapter.addRoute(route, method, handler) must be implemented by subclass'
module.exports = AbstractRouteAdapter