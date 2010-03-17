
package bdog.nodejs;

import js.Node;

using StringTools;

typedef Payload = Dynamic;

typedef ClientPkt = {
  var cmd:String;
  var payload:Dynamic;
}

typedef WorkerPkt = { > ClientPkt,
  var id:Int;
}

class Worker {

  public static var EOL = "\r\n";
  var stdio:StdIO ;
  var log:Int;
  
  public function new() {
    stdio = Node.process.stdio;
    var me = this;
    
  }

  public function
  writePkt(d) {
    stdio.write(Node.stringify(d));
  }
  
  public function
  run(d:WorkerPkt,fn:Payload->Void) {}

  public function start() {
    var
      me = this;
    
    stdio.open();
    stdio.addListener("data", function (data) {

        /*
        Node.posix.open("log.txt",Node.process.O_APPEND,Node.process.O_RDWR)
          .addCallback(function(fd) {
              Node.posix.write(fd,data);
              Node.posix.close(fd);
            });


        */

    me.stdio.write(data);
  
    return;
        try {    
          var inPkt = Node.parse(data);
          try {
            me.run(inPkt,function(payload:Payload) {
                me.writePkt({
                	id:inPkt.id,
                	cmd:inPkt.cmd,
                	payload:payload
                });
              });         
          } catch(exc:Dynamic) {
            me.writePkt({
          		id:-inPkt.id,
           		cmd:"error",
          		payload:Std.string(exc)
            });
          }
        } catch(jsonExc:Dynamic) {
          me.writePkt({
            id:-1,
          	cmd:"error",
          	payload:jsonExc
          });          
        }        
      });
    
    writePkt({
    	id:-1,
    	cmd:"handshake",
    	payload:null
    });
    
  }
}

class WorkerClient {  
  var child:ChildProcess ;
  var handlers:IntHash<Payload->Void>;
  
  public function new(js:String) {
    var
      me = this;

    handlers = new IntHash<Dynamic->Void>();
    child = Node.process.createChildProcess("node", [js]);
   
    child.addListener(Node.OUTPUT, function (data) {
     
        if (data == null) {
          Node.sys.debug("child closed conneciton");
        } else {
          try {
            var j:WorkerPkt = Node.parse(data);
            Node.sys.puts(data);
            if (j.id > 0) {
              var cb = me.handlers.get(j.id) ;
              if (cb != null){
                me.handlers.remove(j.id);              
                try {
                  cb(j.payload);
                } catch(exc:Dynamic) {
                  Node.sys.debug(exc);
                }
              }
            } else {
              if (j.cmd == "handshake") 
                me.start();
              else {
                if (j.cmd == "error") {
                  Node.sys.debug("fucker:"+j);
                }
              }
            }
          } catch(exc:Dynamic) {
            Node.sys.debug(exc);
          }
        }
      });
    
    child.addListener("error", function (data) {
          Node.sys.debug("error:"+data);
      });
    
    child.addListener("exit", function (code) {
        Node.sys.debug("exit:"+code);
      });
  }
 

  function start() { }
  
  function
  setCallback(fn:Dynamic->Void) {
    var id = 1 + Std.random(1000000);
    handlers.set(id,fn);
    return id;
  }

  public function
  send(s:ClientPkt,fn:Payload->Void) {
    var toSend = Node.stringify({
      id:setCallback(fn),
      cmd:s.cmd,
      payload:s.payload
    });

   
    child.write(toSend);
    Node.sys.puts("SENT:"+toSend);
    //    child.write(Worker.EOL,Node.UTF8);
  }

}