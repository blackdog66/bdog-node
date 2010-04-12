package js;

typedef StdOut = Dynamic;
typedef StdErr = Dynamic;

typedef NodeErr = {
  var code:Int;
}

typedef NodeSys = {
  function puts(s:String):Void;
  function print(s:String):Void;
  function debug(s:String):Void;
  function inspect(o:Dynamic,?showHidden:Bool,?depth:Int):Void;
  function log(s:String):Void;
  function exec(c:String,fn:NodeErr->StdOut->StdErr->Void):Void;
}

typedef Watch = {persistant:Bool,interval:Int};

typedef Listener<T> = T->Void;

typedef EventEmitter<T> = {
  function addListener(event:String,fn:Listener<T>):Dynamic;
  function removeListener(event:String,listener:Listener<T>):Void;
  function listeners(event:String):Array<Listener<T>>;
  // TODO function emit(event:String);
}

typedef ReadableStream = { > EventEmitter<Dynamic>,
  function pause():Void;
  function resume():Void;
  function destroy():Void;
  function setEncoding(s:String):Void;  
}

typedef WritableStream = { > EventEmitter<Dynamic>,
  function write(s:Dynamic,?enc:String):Void;
  function end(s:Dynamic,?enc:String):Void;
  function destroy():Void;
}

typedef Process = { > EventEmitter<Dynamic>,
  var argv:Array<String>;
  var env:Dynamic;
  var pid:Int;
  var platform:String;
  var installPrefix:String;

  function memoryUsage():{rss:Int,vsize:Int,heapUsed:Int};
  function nextTick(fn:Void->Void):Void;
  function exit(code:Int):Void;
  function cwd():String;
  function getuid():Int;
  function getgid():Int;
  function setuid(u:Int):Void;
  function setgid(g:Int):Void;
  function umask(?m:Int):Void;
  function chdir(d:String):Void;
  function kill(pid:Int,?signal:String):Void;
  function compile(code:String,scriptOrigin:String):Void;
  function evalcx(code:String,sandbox:Dynamic,fileName:String):Dynamic;
  function openStdin():ReadableStream;

}

typedef StreamOptions = {
  var flags:String;
  var encoding:String;
  var mode:Int;
  var bufferSize:Int;
}

typedef FileReadStream = { > EventEmitter<Dynamic>,
  var readable:Bool;
  function pause():Void;
  function resume():Void;
  function forceClose(cb:Void->Void):Void;
}
  
typedef FileWriteStream = { > EventEmitter<Dynamic>,
  var writable:Bool;
  function close(cb:Void->Void):Void;
  function forceClose(cb:Void->Void):Void;
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
  function createReadStream(path:String,?options:StreamOptions):FileReadStream;
  function createWriteStream(path:String,?options:StreamOptions):FileWriteStream;
}
  
typedef Posix = {
  // async
  function unlink(path:String,cb:NodeErr->Void):Void;
  function rename(from:String,to:String,cb:NodeErr->Void):Void;
  function stat(path:String,cb:NodeErr->Stats->Void):Void;
  function lstat(path:String,cb:NodeErr->Stats->Void):Void;
  function link(srcPath:String,dstPath:String,cb:NodeErr->Void):Void;
  function symlink(linkData:Dynamic,path:String,cb:NodeErr->Void):Void;
  function readlink(path:String,cb:NodeErr->String->Void):Void;
  function realpath(path:String,cb:NodeErr->String->Void):Void;
  function chmod(path:String,mode:Int,cb:NodeErr->Void):Void;
  function rmdir(path:String,cb:NodeErr->Void):Void;
  function mkdir(path:String,mode:Int,cb:NodeErr->Void):Void;
  function readdir(path:String,cb:NodeErr->Array<String>->Void):Void;
  function close(fd:Int,cb:NodeErr->Void):Void;
  function open(path:String,flags:Int,mode:Int,cb:NodeErr->Int->Void):Void;
  function write(fd:Int,data:String,?position:Int,?enc:String,cb:NodeErr->Int->Void):Void;
  function read(fd:Int,length:Int,position:Int,?enc:String,cb:NodeErr->String->Int->Void):Void;

  function readFile(path:String,?enc:String,cb:NodeErr->String->Void):Void;
  function writeFile(fileName:String,contents:String,cb:NodeErr->Void):Void;

  // sync

  function unlinkSync(path:String):Void;
  function renameSync(from:String,to:String):Void;
  function statSync(path:String):Stats;
  function lstatSync(path:String):Stats;
  function linkSync(srcPath:String,dstPath:String):Void;
  function symlinkSync(linkData:Dynamic,path:String):Void;
  function readlinkSync(path:String):String;
  function realpathSync(path:String):String;
  function chmodSync(path:String,?mode:Int):Void;
  function rmdirSync(path:String):Void;
  function mkdirSync(path:String,?mode:Int):Void;
  function readdirSync(path:String):Array<String>;
  function closeSync(fd:Int):Void;
  function openSync(path:String,flags:String,?mode:Int):Int;
  function writeSync(fd:Int,data:String,?position:Int,?enc:String):Void;
  function readSync(fd:Int,length:Int,position:Int,?enc:String):String;
  function readFileSync(path:String,?enc:String):String;
  function writeFileSync(fileName:String,contents:String):Void;

  // other

  function watchFile(fileName:String,?options:Watch,listener:Stats->Stats->Void):Void;
  function unwatchFile(fileName:String):Void;

}

typedef ChildProcess = { > EventEmitter<Dynamic>,
  var pid:Int;
  function write(data:String,?enc:String):Void;
  function close():Void;
  function kill(?signal:String):Void;
}
  
typedef Request ={
  var method:String;
  var url:String;
  var headers:Dynamic;
  var httpVersion:String;
  function setBodyEncoding(enc:String):Void;
  function pause():Void;
  function resume():Void;
  var connection:Connection; // docs refer to HttpConnection here!!!
}

typedef Response={
  function sendHeader(statusCode:Int,headers:Dynamic):Void;
  function end():Void;
  function write(chunk:String,?enc:String):Void;  
}

typedef ClientResponse = { > EventEmitter<Null<String>>,
  var statusCode:Int;
  var httpVersion:String;
  var headers:Dynamic;
  var client:Client;
  function setBodyEncoding(enc:String):Void;
  function resume():Void;
  function pause():Void;  
}

// chunk Array<Int> or string
typedef ClientRequest={ > EventEmitter<Dynamic>,
  function sendBody(chunk:String,enc:String):Void;
  function end():Void;
}

typedef Client={
  function request(method:String,path:String,?headers:Dynamic):ClientRequest;
  function head(path:String,?headers:Dynamic):ClientRequest;
  function del(path:String,?headers:Dynamic):ClientRequest;
  function put(path:String,?headers:Dynamic):ClientRequest;
  function setSecure(fmtType:String,caCerts:String,crlList:String,privKey:String,cert:String):Void;
}

typedef Http ={
  function createServer(listener:Request->Response->Void,?options:Dynamic):Server;
  function createClient(port:Int,host:String):Client;
}
  
typedef Connection = {
  function connect(port:Int,host:String):Void;
  var remoteAddress:String;
  function readyState():String;
  function setEncoding(s:String):Void;
  function write(d:String,?enc:String):Void;
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

typedef Net = {
  function createConnection():Connection;
  function createServer(fn:Connection->Void):Server;
}

typedef Part = {
  var parent:Dynamic;
  var headers:Dynamic;
  var filename:String;
  var name:String;
  var isMultiPart:Bool;
  var parts:Array<Part>;
  var boundary:String;
  var type:String;
}

typedef MultiPartStream = { > EventEmitter<Dynamic>,
  var part:Part;
  var isMultiPart:Bool;
  var parts:Array<Part>;
  function pause():Void;
  function resume():Void;
}

typedef MultiPart = {
  function parse(message:Dynamic):MultiPartStream;
  function cat(message:Dynamic,cb:NodeErr->MultiPartStream->Void):Void;
}    

class Node {
  // encodings ...
  public static var UTF8 = "utf8";
  public static var ASCII = "ascii";
  public static var BINARY = "binary";
  // connection events ...
  public static var CONNECT = "connect";
  public static var DATA = "data";
  public static var END = "end";
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
  
  public static var require:String->Dynamic = untyped __js__('require');
  public static var setTimeout:Dynamic->Int->Array<Dynamic>->Int = untyped __js__('setTimeout');
  public static var clearTimeout:Int->Void = untyped __js__('clearTimeout');
  public static var setInterval:Dynamic->Int->Array<Dynamic>->Int = untyped __js__('setInterval');
  public static var clearInterval:Int->Void = untyped __js__('clearInterval');
  
  public static var global:Dynamic = untyped __js__('global');
  public static var process:Process = untyped __js__('process');
  public static var sys:NodeSys = require("sys");
  public static var fs:Posix = require("fs");

  public static var __filename = untyped __js__('__filename');
  public static var __dirname = untyped __js__('__dirname');
  public static var module = untyped __js__('module');
  
  public static var stringify:Dynamic->String = untyped __js__('JSON.stringify');
  public static var parse:String->Dynamic = untyped __js__('JSON.parse');  
}

