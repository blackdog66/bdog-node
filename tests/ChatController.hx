
package tests;

import bdog.ChatClient;

class ChatController {

  public static function main() {
    var c = new ChatClient('localhost',9000);
    c.events.msg.addHandler(function(m:Msg) {
        trace(m.text);
      });
    
    c.join("outhouse","ritchie",function(o) {
        trace("joined :"+o);
        c.who(function(o) { trace(o); });
        for (i in 0 ... 10) {
          c.send("msg"+i);
        }
      });

    trace("polling");
    c.poll();
  }

}

