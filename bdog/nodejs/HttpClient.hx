
package bdog.nodejs;

import js.Node;

/*
Usage:

    var c = new HttpClient('localhost',8083);
    
    c.get("/PLOGIN",{EMAIL:"t1@t1.com",PASSWORD:"pass",SITE:'site'})
     .then(function(resp) {
         trace("here with :"+resp);
     });
  }


 */


class HttpClient {
  var host:String;
  var port:Int;
  var url:String;
  var request:ClientRequest;
  var method:String;
  
  static function
  objToString(prms:Dynamic):String {
    var
      sb = new StringBuf();
    if (prms != null) {
      sb.add("?");
      for (p in Reflect.fields(prms)) {
        sb.add(p);
        sb.add("=");
        sb.add(Std.string(Reflect.field(prms,p)));
        sb.add("&");
      }
    }
    return sb.toString().substr(0,-1);
  }

  public function new(h:String,p:Int) {
    host = h;
    port = p;
  }

  public function get(path:String,?prms:Dynamic) {
    method = "GET";
    url = path + ((prms != null) ? objToString(prms) : "");
    return this;
  }

  public function then(fn:String->Void) {
    var
      http = Node.require("http"),      
      client = http.createClient(port,host),
      request = client.request(method,url,{host:host});

    request.addListener('response',function(response) {
        response.setBodyEncoding("ascii");
        response.addListener("data", function (chunk) {
            fn(chunk);
          });
      });
    request.end();  
  }
}

