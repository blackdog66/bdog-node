
package bdog.nodejs;

import js.Node;
using Lambda;

typedef Msg = {
  var nick:String;
  var type:String;
  var text:String;
  var timestamp:Float;
}

class Session {
  public var id:String;
  public var nick:String;
  public var timestamp:Float;
  
  public function new(n:String) {
    nick = n;
    id = Std.string(Math.floor(Math.random() * 1e10));
    timestamp = Date.now().getTime();
  }

  public function poke() {
    timestamp = Date.now().getTime();
  }
}

class Channel {
  public var sessions:Hash<Session>;
  public var nicks:Hash<String>;
  var messages:Array<Msg>;
  var callbacks:Array<{sessID:String,timestamp:Float,fn:Array<Msg>->Void}>;
  
  var messageBacklog:Int; 
  var sessionTimeout:Int;
  
  public function new(id:String) {
    sessions = new Hash<Session>() ;
    nicks = new Hash<String>();
    messages = new Array<Msg>();
    callbacks = new Array();
    messageBacklog = 20;
    sessionTimeout = 60*1000;
    var me = this;
    Node.setInterval(function() {
        me.flushCallbacks();
        me.expireOldSessions();
      },1000,[]);
  }

  public function
  createSession(n:String):Session {
    var nick = n.toLowerCase();
    if (nick.length > 50) return null;
    if (~/[^\w_\-^!]/.match(nick)) return null;
    //    if (nicks.exists(nick)) return null;

    nicks.set(nick,nick);
    var sess = new Session(nick);
    sessions.set(sess.id,sess);
    return sess;
  }

  public function
  appendMessage(nick:String,type:String,?text:String) {
    var message = {
      nick:nick,
      type:type,
      text:text,
      timestamp:Date.now().getTime()
    };
    
    messages.push(message);

    while(callbacks.length > 0)
      callbacks.shift().fn([message]);
    
    while(messages.length > messageBacklog)
      messages.shift();
    
  }

  public function
  query(sessID:String,since:Float,fn:Array<Msg>->Void) {
    var
      matching:Array<Msg> = null ,
      length = messages.length;

    for (i in 0 ... length) {
      if (messages[i].timestamp > since) {
        matching = messages.slice(i);
        break;
      }
    }
    
    if (matching != null) {
      fn(matching);
    } else {
      callbacks.push({
        sessID:sessID,
        timestamp:Date.now().getTime(),
        fn:fn
      });
    }
  }
  
  function flushCallbacks() {
    var now = Date.now().getTime();
    while (callbacks.length > 0 && now - callbacks[0].timestamp > sessionTimeout * 0.75) {
      callbacks.shift().fn([]);
    }
  }

  function flushCallbacksBySess(sessID) {
    var now = Date.now().getTime();
    while (callbacks.length > 0 && callbacks[0].sessID == sessID) {
      trace("removing callback be session "+sessID);
      callbacks.shift().fn([]);
    }
  }

  public function
  expireOldSessions() {
    var now = Date.now().getTime();
    for (s in sessions) {
      if (now - s.timestamp > sessionTimeout){
        destroySession(s.id);
      }
    }
  }
    
  public function
  destroySession(id) {
    if (sessions.exists(id)) {
      trace("parting:"+id);
      var n = sessions.get(id).nick;
      sessions.remove(id);
      nicks.remove(n);
      flushCallbacksBySess(id);
    }
  }
}

class ChatServer {

  var channels:Hash<Channel>;

  public static function main() {
    var
      args = Node.process.argv,
      loc = args[2].split(":");
    
    trace("Starting chat on "+loc[0]+":"+loc[1]);
    new ChatServer(loc[0],Std.parseInt(loc[1]));
  }
  
  public function new(hostname:String,port:Int) {
    channels = new Hash<Channel>();
     
    var
      me = this;

    Node.http.createServer(function(req,res) {
        var
          reqPrms = Node.url.parse(req.url,true),
          givenChannel = reqPrms.query.channel,
          channel = me.channels.get(givenChannel);

        if (channel == null && givenChannel != null) {
          channel = me.addChannel(givenChannel);
        }

        if (channel != null) {
          switch(reqPrms.pathname) {
          case "/chat/join":
            me.join(channel,req,res);
          case "/chat/who":
            me.who(channel,req,res);
          case "/chat/send":
            me.send(channel,req,res);
          case "/chat/recv":
            me.recv(channel,req,res);
          case "/chat/part":
            me.part(channel,req,res);
          default:
            me.write(res,400,{error:"need a command!"});
          }
        } 
          
      }).listen(port,hostname);
  }

  public function
  join(channel:Channel,req,res) {
    var query = Node.url.parse(req.url).query;
    
    var nick:String = Node.queryString.parse(query).nick;
    if (nick == null) {
      write(res,400,{error: "bad nick" });
      return;
    }

    var session = channel.createSession(nick) ;

    /*
    if (session == null) {
      write(res,400, {error: "nick in use" });
      return;
    }
    */

    channel.appendMessage(nick,"join");
    write(res,200, {id: session.id, nick:nick });
  }

  public function
  who(channel:Channel,req,res) {
    write(res,200,{nicks:Lambda.array(channel.nicks)});
  }

  public function send(channel:Channel,req,res) {
    var
      me = this,
      query = Node.url.parse(req.url,true).query,
      since = query.since,
      id = query.id,
      text = query.text;

    var session = channel.sessions.get(id);
    if (session == null || text == null) {
      write(res,400,{error:"no such session"});
      return;
    }

    session.poke();
    channel.appendMessage(session.nick,"msg",text);
    write(res,200,{});
  }

  
  public function
  recv(channel:Channel,req,res) {
    var
      me = this,
      query = Node.url.parse(req.url,true).query,
      qsince = query.since,
      id = query.id,
      session;

    if (qsince == null) {
      write(res,400,{error: "must supply a since parameter" });
      return;
    }

    var since = Std.parseInt(qsince);
    session = channel.sessions.get(id);
    if (session != null) 
      session.poke();
    
    channel.query(id,since,function(messages) {
        if (session != null) session.poke();
        me.write(res,200,{messages:messages});
      });
    
  }

  public function
  part(channel:Channel,req,res) {
    var
      query = Node.url.parse(req.url).query,
      qs = Node.queryString.parse(query),
      id = qs.id,
      session = channel.sessions.get(id);

    channel.appendMessage(session.nick,"part");
    channel.destroySession(id);
   
    write(res,200,{});
  }
  
  public function
  addChannel(name:String) {
    var channel = new Channel(name);
    channels.set(name,channel);
    return channel;
  }
  
  public function
  write(res:Response,errno:Int,o:Dynamic) {
    var s = Node.stringify(o);
    var hdrs = {};
    Reflect.setField(hdrs,"Content-Length",s.length);
    Reflect.setField(hdrs,"Content-Type","text/json");
    res.writeHead(errno,null,hdrs);
    res.write(s);
    res.end();
  }
}