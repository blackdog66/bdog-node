
import node.Node;

class Main {

  public static
  function main() {
    clientTest();
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


  static function
  clientTest() {
    var
      sys:Sys = Node.require("sys"),
      http:Http = Node.require("http"),
      google = http.createClient(80, "www.google.cl"),
      request = google.get("/", {host: "www.google.cl"});
    
    request.finish(function (response) {
        sys.puts("STATUS: " + response.statusCode);
        sys.puts("HEADERS: " + Node.toJSON(response.headers));
        response.setBodyEncoding("utf8");
        response.addListener("body", function (chunk) {
            sys.puts("BODY: " + chunk);
          });
      });

  }
}
