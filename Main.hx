
import node.Node;

class Main {

  public static
  function main() {
        clientTest();
    //tcpTest();
    //    flashCrossDomain();
  } 
  
  public static function
  tcpTest() {
    
    var tcp:Tcp = Node.require("tcp");
    
    var s = tcp.createServer(function(c:Connection) {
        c.addListener(Node.CONNECT,function(d) {
            trace("got connection");
            c.send("hello\r\n");
          });

        c.addListener(Node.RECEIVE,function(d) {
            c.send(d);
          });

        c.addListener(Node.EOF,function(d) {
            trace("lost connection");
            c.close();
          });
      });

    s.listen(5000,"localhost");
    
    trace("here");
  }

  public static function
  flashCrossDomain() {
     var tcp:Tcp = Node.require("tcp");
    
    var s = tcp.createServer(function(c:Connection) {
        c.addListener(Node.CONNECT,function(d) {
            c.send('<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy
  SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
  <allow-access-from domain="*" to-ports="1138,1139,1140" />
</cross-domain-policy>');
               c.close();
          });
        
        c.addListener(Node.EOF,function(d) {
            trace("lost connection");
            //     c.close();
          });
      });

    trace("args[1] "+Node.process.argv[2]);
    s.listen(843,Node.process.argv[2]);
   
  }


  static function
  clientTest() {
    var
      sys:Sys = Node.require("sys"),
      http:Http = Node.require("http"),
      google = http.createClient(80, "www.google.cl"),
      request = google.request("GET","/", {host: "www.google.cl"});

    
    request.finish(function (response) {
        sys.puts("STATUS: " + response.statusCode);
        sys.puts("HEADERS: " + Node.stringify(response.headers));
        response.setBodyEncoding("utf8");
        response.addListener("body", function (chunk) {
            sys.puts("BODY: " + chunk);
          });
      });
    
  }
}
