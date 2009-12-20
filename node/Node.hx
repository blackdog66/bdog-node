package node;

typedef StdOut = Dynamic;
typedef StdErr = Dynamic;

typedef Sys = {
  function puts(s:String):Void;
  function print(s:String):Void;
  function debug(s:String):Void;
  function inspect(o:Dynamic):Void;
  function exec(c:String,fn:StdOut->StdErr->Void):Void;
}

typedef Watch = {persistant:Bool,interval:Int};

typedef StdIO = {
  function open(enc:String):Void;
  function close():Void;
  function write(data:String):Void;
  function writeError(data:String):Void;
}

typedef ChildProcess = {
  var pid:Int;
  function write(data:String,?enc:String):Void;
  function close():Void;
  function kill(?signal:String):Void;
}

typedef Process = {
  var ARGV:Array<String>;
  var pid:Int;
  var platform:String;
  function memoryUsage():{rss:Int,vsize:Int,heapUsed:Int};
  function exit(code:Int):Void;
  function cwd():String;
  function kill(pid:Int,signal:String):Void;
  function watchFile(fileName:String,?options:Watch,listener:Dynamic->Dynamic->Void):Void;
  function unwatchFile(fileName:String):Void;
  function compile(source:String,scriptOrigin:String):Void;
  function mixin(?deep:Bool,target:Dynamic,obj:Dynamic,?objN:Dynamic):Void;

  var stdio:StdIO;

  function createChildProcess(command:String,args:Array<String>,env:Dynamic):ChildProcess;
}

typedef Stats = {
  var dev:Int;
  var ino:Int;
  var mode:Int;
  var nlink:Int;
  var uid:Int;
  var gid:Int;
  var rdev:Int;
  var size:Int;
  var blkSize:Int;
  var blocks:Int;
  var atime:String;
  var mtime:String;
  var ctime:String;
  function isFile():Bool;
  function isDirectory():Bool;
  function isBlockDevice():Bool;
  function isCharacterDevice():Bool;
  function isSymbolicLink():Bool;
  function isFIFO():Bool;
  function isSocket():Bool;
}

typedef Listener = Dynamic->Void;

typedef EventEmitter = {
  function addListener(event:String,fn:Listener):Void;
  function removeListener(event:String,listener:Listener):Void;
  function listeners(event:String):Array<Listener>;
}
  
typedef Promise = { EventEmitter,
  function addCallback(d:Dynamic):Void;
  function wait():Dynamic;
  function emitSuccess(d:Dynamic):Void;
  function emitCancel():Void;
  function emitError():Void;
  function emit():Void;
  function addCancelback(fn:Void->Void):Void;
  function addErrback(fn:Dynamic->Void):Void;
  function timeout(t:Int):Void;
}

typedef Posix = {
  function unlink(fileName:String):Promise ;
  function rename(from:String,to:String):Promise;
  function stat(path:String):Promise;
  function rmdir(path:String):Promise;
  function mkdir(path:String,mode:Int):Promise;
  function readdir(path:String):Promise;
  function close(fd:Int):Promise;
  function open(path:String,flags:String,mode:String):Promise;
  function write(fd:Int,data:String,position:Int,enc:String):Promise;
  function read(fd:Int,length:Int,position:Int,end:String):Promise;
  function cat(fileName:String,enc:String):Promise;  
}

typedef URI = {
  var full:String;
  var path:String;
  var queryString:String;
  var params:Dynamic;
  var fragment:String;
}

typedef Request ={
  var method:String;
  var uri:URI;
  var headers:Dynamic;
  var httpVersion:String;
  function setBodyEncoding(enc:String):Void;
  function pause():Void;
  function resume():Void;
  var connection:Connection; // docs refer to HttpConnection here!!!
}

typedef Response={
  function sendHeader(statusCode:Int,headers:Dynamic):Void;
  function finish():Void;
  function sendBody(chunk:String,enc:String):Void;  
}

typedef ClientResponse= { > EventEmitter,
  var statusCode:Int;
  var httpVersion:String;
  var headers:Dynamic;
  var client:Client;
  function setBodyEncoding(enc:String):Void;
  function resume():Void;
  function pause():Void;
  
}

// chunk Array<Int> or string
typedef ClientRequest={
  function sendBody(chunk:String,enc:String):Void;
  function finish(responseListener:ClientResponse->Void):Void;
}

typedef Client={
  function get(path:String,?headers:Dynamic):ClientRequest;
  function head(path:String,?headers:Dynamic):ClientRequest;
  function post(path:String,?headers:Dynamic):ClientRequest;
  function del(path:String,?headers:Dynamic):ClientRequest;
  function put(path:String,?headers:Dynamic):ClientRequest;
  function setSecure(fmtType:String,caCerts:String,crlList:String,privKey:String,cert:String):Void;
}

typedef Http ={
  function createServer(listener:Request->Response->Void,options:Dynamic):Void;
  function createClient(port:Int,host:String):Client;
}
  
typedef Connection = {
  function connect(port:Int,host:String):Void;
  function remoteAddress():String;
  function readyState():String;
  function setEncoding(s:String):Void;
  function send(d:String,?enc:String):Void;
  function close():Void;
  function forceClose():Void;
  function readPause():Void;
  function readResume():Void;
  function setTimeout(t:Int):Void;
  function setNoDelay(d:Bool):Void;
  function verifyPeer():Int;
  function getPeerCertificate(format:String):Void;
  function addListener(e:String,listener:Dynamic->Void):Void;
}

typedef Server = {
  function setSecure(formatType:String,caCerts:String,crlList:String,privKey:String,cert:String):Void;
  function listen(port:Int,?host:String,?backlog:Int):Void;
  function close():Void;
  function addListener(event:String,fn:Dynamic->Void):Void;
}

typedef Tcp = {
  function createConnection():Connection;
  function createServer(fn:Connection->Void):Server;
}

class Node {
  // encodings ...
  public static var UTF8 = "utf8";
  public static var ASCII = "ascii";
  public static var BINARY = "binary";
  // connection events ...
  public static var CONNECT = "connect";
  public static var RECEIVE = "receive";
  public static var EOF = "eof";
  public static var TIMEOUT = "timeout";
  public static var DRAIN = "drain";
  public static var CLOSE = "close";
  // listener events ...
  public static var OUTPUT = "output";
  public static var ERROR = "error";
  public static var EXIT = "exit";
  public static var NEW_LISTENER = "newListener";
  // process events ...
  public static var UNCAUGHT_EXC = "uncaughtException";
  public static var SIGINT = "SIGINT";
  public static var SIGUSR1 = "SIGUSR1";
  // stdio events ...
  public static var DATA = "data";
  
  public static var require:String->Dynamic = untyped __js__('require');
  public static var setTimeout:Void->Void = untyped __js__('setTimeout');
  public static var clearTimeout:Int->Void = untyped __js__('clearTimeout');
  public static var setInterval:Void->Void = untyped __js__('setInterval');
  public static var clearInterval:Int->Void = untyped __js__('clearInterval');
  public static var exec:String->Promise = untyped __js__('exec');                                                          
  public static var GLOBAL:Dynamic = untyped __js__('GLOBAL');
  public static var process:Process = untyped __js__('process');
  public static var sys:Sys = require("sys");

  public static var toJSON:Dynamic->String = untyped __js__('JSON.stringify');
  public static var fromJSON:Dynamic->String = untyped __js__('JSON.parse');
  
  public function createPromise():Promise {
    return untyped __js__('new process.Promise()');
  }
}