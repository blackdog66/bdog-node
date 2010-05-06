
package bdog.nodejs;

import js.Node;
using StringTools;

typedef Validator = {
	var err:Dynamic;
	var validator:String->Dynamic;
};

typedef IRequest = {
  var params:Dynamic;
  var validated:Dynamic;
  var raw:Request;
}

private enum Params {
  OK(newData:Dynamic);
  REQUIRED(fld:String);
  EXC(exc:String);
  INVALID(en:Dynamic);
}
  
typedef Action = IRequest->(String->Void)->Void;

class HttpServer  {
  var serverID:String;

  public function
  new(host:String,port:Int,name:String) {
    var http = Node.http;
    
    serverID = name;
    trace("Starting "+serverID+" on "+host+":"+port);
    
    var
      me = this,
      URL = Node.url;
        
    http.createServer(function(req:Request,res:Response) {
        var
          reqPrms = URL.parse(req.url,true),
          path = reqPrms.pathname,
          s = Servlet.servlets.get(path);
          
        if (s == null) {
          var s = "Servlet " + path + " not found";
          headers(res,200,s.length);
          res.write(s,Node.ASCII);
          res.end();
          return;
        }
      
        s.pre(req);

        var
          params = reqPrms.query,
          validated = s.checkRequired(params);
        
        switch(validated) {

        case OK(newParams):
          var
            internalRequest = {params:params,validated:newParams,raw:req} ,
            f = s.getAction(),
            response = function(results:String) {
              var
              results = s.post(internalRequest,results);
              headers(res,200,results.length,s.contentType);
              res.write(results,Node.ASCII);
              res.end();
            }
                
            try {
              f(internalRequest,response);
            } catch(exc:Dynamic) {
              var results = s.post(internalRequest,error(s,EXC(exc)));
              headers(res,200,results.length,s.contentType);
              res.write(results,Node.ASCII);
              res.end();
            }
              
        case REQUIRED(fld):
          var results = error(s,validated);
          headers(res,200,results.length);
          res.write(results,Node.ASCII);
          res.end();

        case INVALID(e):
          var results = error(s,validated);
          headers(res,200,results.length);
          res.write(results,Node.ASCII);
          res.end();

        case EXC(dummy):
          // shouldn't get here
          trace("BUGGER "+dummy);
        }

      }).listen(port,host);
  }

  static function
  headers(res:Response,code:Int,length:Int,ct="text/html") {
    var hdrs = {};
    Reflect.setField(hdrs,"Content-Length",length);
    Reflect.setField(hdrs,"Content-Type",ct);
    Reflect.setField(hdrs,"Connection","close");
    res.writeHead(200, hdrs);
  }

  public static function
  error(srv:Servlet,e:Dynamic) {
    var p = Type.enumParameters(e);
    return reply(e,(p.length > 0) ? p[0] : p);
  }
  
  public static function
  reply(err:Enum<Dynamic>,?prms:Dynamic) {
    var
      txt = Type.enumConstructor(err),
      e = {ERR:txt};

    if (prms != null)
      Reflect.setField(e,"PAYLOAD",prms);

    return Node.stringify(e);
  }

}

class Servlet {

  public static var servlets = new Hash<Servlet>();
  static var http:Server;

  var action:Action;
  var validations:Hash<Validator>;

  public var contentType:String;
  var requiredKeys:Array<String> ;

  public function
  new(e:Dynamic,a:Action,?prefix = '/') {
    var url = prefix+Type.enumConstructor(e);
    if (servlets.exists(url)) throw "Duplicate server URL";
    servlets.set(url,this);
    action = a;
    contentType = "text/html";
    validations = new Hash<Validator>();
  }

  public function
  checkRequired(keys:Dynamic):Params {
    var newData = {};

    if (requiredKeys == null) return OK(null);

    for (n in requiredKeys) {
      var val = Reflect.field(keys,n);
      if (val == null) {
        return REQUIRED(n);
      }
      var v = validations.get(n);
      if (v != null) {
        var realVal = v.validator(val);
        if (realVal == null) {
          return INVALID(v.err);

        }
        Reflect.setField(newData,n,realVal);
      }
    }
    return OK(newData);
  }

  public static inline function
  getServlet(path:String) {
    return servlets.get(path);
  }

  public inline function
  getAction():Action {
    return action;
  }

  public function
  required(r:Array<Dynamic>) {
    if (requiredKeys == null) requiredKeys = [];
    for( k in r)
      requiredKeys.push(Type.enumConstructor(k));
  }

  public function
  validate(param:Dynamic,err:Dynamic,validator:String->Dynamic) {
    var s:String = Type.enumConstructor(param);
    validations.set(s,{validator:validator,err:err});
  }

  /**
   * Allow the servlet implementation to modify the request if it wishes
   */
  public function
  pre(req:Request) {}

  /** Allow the servlet implementation to modify the response if it wishes
   * e.g. a JSONP implementation.
   */
  public function
  post(req:IRequest,results:String) {
    return results;
  }

}

/**
 * The JSONP servlet looks for a callback parameter. If callback exists
 * then a jsonp response is returned. However, the servlet does not
 * enforce callback so that it can still be used with non jsonp requests.
 *
 * If you want to enforce the callback parameter add to the required params.
 */
class JSONP extends Servlet {
  public function
  new(e:Dynamic,a:Action) {
    super(e,a);
    contentType = "text/json";
  }

  public override function
  post(req:IRequest,results) {
    var cb = Reflect.field(req.params,"callback") ;
    return (cb != null) ? cb+"("+results+");" : results;
  }
}
