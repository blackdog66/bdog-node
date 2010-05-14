package js;

typedef StdOut = Dynamic;
typedef StdErr = Dynamic;
typedef Watch = {persistant:Bool,interval:Int};
typedef Listener = Dynamic;

typedef NodeErr = {
  var code:Int;
}

typedef NodeSys = {
  function puts(s:String):Void;
  function print(s:String):Void;
  function debug(s:String):Void;
  function inspect(o:Dynamic,?showHidden:Bool,?depth:Int):Void;
  function log(s:String):Void;
}

typedef EventEmitter = {
  function addListener(event:String,fn:Listener):Dynamic;
  function removeListener(event:String,listener:Listener):Void;
  function removeAllListener(event:String):Void;
  function listeners(event:String):Array<Listener>;
  function emit(event:String,?arg1:Dynamic,?arg2:Dynamic,?arg3:Dynamic):Void;
}

typedef ReadableStream = { > EventEmitter,
  function pause():Void;
  function resume():Void;
  function destroy():Void;
  function setEncoding(s:String):Void;  
}

typedef WriteableStream = { > EventEmitter,
  function write(s:Dynamic,?enc:String):Void;
  function end(?s:Dynamic,?enc:String):Void;
  function destroy():Void;
}

typedef Process = { > EventEmitter,
  var stdout:WriteableStream;
  var argv:Array<String>;
  var env:Dynamic;
  var pid:Int;
  var platform:String;
  var installPrefix:String;
  
  function memoryUsage():{rss:Int,vsize:Int,heapUsed:Int,heapTotal:Int};
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
  function binding(s:String):Dynamic;
}

typedef StreamOptions = {
  var flags:String;
  var encoding:String;
  var mode:Int;
  var bufferSize:Int;
}

typedef FileReadStream = { > EventEmitter,
  var readable:Bool;
  function pause():Void;
  function resume():Void;
  function forceClose(cb:Void->Void):Void;
}
  
typedef FileWriteStream = { > EventEmitter,
  var writable:Bool;
  function write(?d:Dynamic,?enc:String):Void;
  function end():Void;
  function destroy():Void;
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
  
typedef NodeFS = {
  // async
  function rename(from:String,to:String,cb:NodeErr->Void):Void;
  function stat(path:String,cb:NodeErr->Stats->Void):Void;
  function lstat(path:String,cb:NodeErr->Stats->Void):Void;
  function link(srcPath:String,dstPath:String,cb:NodeErr->Void):Void;
  function unlink(path:String,cn:NodeErr->Void):Void;
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
  function truncate(fd:Int,len:Int,cb:NodeErr->Void):Void;
  
  function readFile(path:String,?enc:String,cb:NodeErr->String->Void):Void;
  function writeFile(fileName:String,contents:String,cb:NodeErr->Void):Void;

  // sync

  function renameSync(from:String,to:String):Void;
  function statSync(path:String):Stats;
  function lstatSync(path:String):Stats;
  function linkSync(srcPath:String,dstPath:String):Void;
  function unlinkSync(path:String):Void;
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
  function truncateSync(fd:Int,len:Int):NodeErr;
  
  function readFileSync(path:String,?enc:String):String;
  function writeFileSync(fileName:String,contents:String,?enc:String):Void;

  // other

  function watchFile(fileName:String,?options:Watch,listener:Stats->Stats->Void):Void;
  function unwatchFile(fileName:String):Void;

  function createReadStream(path:String,?options:StreamOptions):FileReadStream;
  function createWriteStream(path:String,?options:StreamOptions):FileWriteStream;
  
}

typedef ChildProcess = { > EventEmitter,
  var pid:Int;
  var stdin:WriteableStream;
  var stdout:ReadableStream;
  var stderr:ReadableStream;
  function kill(signal:String):Void;
}
  
typedef Request ={
  var method:String;
  var url:String;
  var headers:Dynamic;
  var httpVersion:String;
  var connection:Stream;
  function setEncoding(enc:String):Void;
  function pause():Void;
  function resume():Void;
}

typedef Response = {
  function writeHead(statusCode:Int,?reasonPhrase:String,headers:Dynamic):Void;
  function end():Void;
  function write(chunk:String,?enc:String):Void;  
}

typedef ClientResponse = { > EventEmitter,
  var statusCode:Int;
  var httpVersion:String;
  var headers:Dynamic;
  var client:Client;
  function setEncoding(enc:String):Void;
  function resume():Void;
  function pause():Void;  
}

typedef ClientRequest = { > EventEmitter,
  function sendBody(chunk:String,enc:String):Void;
  function end():Void;
}

typedef Client = {
  function request(method:String,path:String,?headers:Dynamic):ClientRequest;
  function head(path:String,?headers:Dynamic):ClientRequest;
  function del(path:String,?headers:Dynamic):ClientRequest;
  function put(path:String,?headers:Dynamic):ClientRequest;
  function setSecure(fmtType:String,caCerts:String,crlList:String,privKey:String,cert:String):Void;
}

typedef Http = {
  function createServer(listener:Request->Response->Void,?options:Dynamic):Server;
  function createClient(port:Int,host:String):Client;
}
  
typedef Stream = { > EventEmitter,
  var remoteAddress:String;
  function connect(port:Int,?host:String):Void;
  function readyState():String;
  function setEncoding(s:String):Void;
  function write(d:String,?enc:String):Void;
  function end():Void;
  function destroy():Void;
  function pause():Void;
  function resume():Void;
  function setTimeout(t:Int):Void;
  function setKeepAlive(?enable:Bool,delay:Int):Void;
  function setNoDelay(d:Bool):Void;
  function verifyPeer():Int;
}

typedef Server = {
  function setSecure(formatType:String,caCerts:String,crlList:String,privKey:String,cert:String):Void;
  function listen(port:Int,?host:String,?backlog:Int):Void;
  function close():Void;
  function addListener(event:String,fn:Dynamic->Void):Void;
}

typedef Net = { > EventEmitter,
  function createConnection(port:Int,host:String):Stream;
  function createServer(fn:Stream->Void):Server;
}

typedef ExecOptions = {
	var encoding:String;
	var timeout:Int;
	var maxBuffer:Int;
	var killSignal:String;
}

typedef Path = {
  function join():String;
  function normalizeArray(a:Array<String>):Array<String>;
  function normalize(p:String):String;
  function dirname(p:String):String;
  function basename(p:String,?ext:String):String;
  function extname(p:String):String;
  function exists(p:String,cb:Bool->Void):Void;
}

typedef UrlObj = {
  var href:String;
  var host:String;
  var protocol:String;
  var auth:String;
  var hostname:String;
  var port:String;
  var pathname:String;
  var search:String;
  var query:Dynamic;
  var hash:String;
}

typedef Url = {
  function parse(p:String,?andQueryString:Bool):UrlObj;
  function format(o:UrlObj):String;
  function resolve(from:String,to:String):String;
}

typedef QueryString = {
  function parse(s:String,?sep:String,?eq:String):Dynamic;
  function escape(s:String):String;
  function unescape(s:String):String;
  function stringify(obj:Dynamic,?sep:String,?eq:String):String;
}

extern class Buffer implements ArrayAccess<Int> {
  var length(default,null) : Int;
  function copy(targetBuffer:Dynamic,targetStart:Dynamic,start:Int,end:Int):Void;
  function slice(start:Int,end:Int):Void;
  function write(s:String,enc:String,offset:Int):Void;
  function toString(enc:String,?start:Int,?stop:String):String;
}

typedef Script =  {  
  function runInThisContext():Dynamic;
  function runInNewContext(sandbox:Dynamic):Void;
}

class Node {
  // encodings ...

  public static var UTF8 = "utf8";
  public static var ASCII = "ascii";
  public static var BINARY = "binary";

  // process events ...

  public static var UNCAUGHT_EXC = "uncaughtException";
  public static var SIGINT = "SIGINT";
  public static var SIGUSR1 = "SIGUSR1";
  
  public static var require:String->Dynamic = untyped __js__('require');
  public static var paths:String = untyped  __js__('require.paths');
  
  public static var setTimeout:Dynamic->Int->Array<Dynamic>->Int = untyped __js__('setTimeout');
  public static var clearTimeout:Int->Void = untyped __js__('clearTimeout');
  public static var setInterval:Dynamic->Int->Array<Dynamic>->Int = untyped __js__('setInterval');
  public static var clearInterval:Int->Void = untyped __js__('clearInterval');
  
  public static var global:Dynamic = untyped __js__('global');
  public static var process:Process = untyped __js__('process');
  public static var sys:NodeSys = require("sys");
  public static var fs:NodeFS = require("fs");
  public static var net:Net = require("net");
  public static var http:Http = require("http");
  
  public static var __filename = untyped __js__('__filename');
  public static var __dirname = untyped __js__('__dirname');
  public static var module:Dynamic = untyped __js__('module');  // ref to the current module
  public static var stringify:Dynamic->String = untyped __js__('JSON.stringify');
  public static var parse:String->Dynamic = untyped __js__('JSON.parse');
  public static var path:Path = require('path');
  public static var url:Url = require('url');
  public static var queryString:QueryString = require('querystring');
  
  public static function
  spawn(cmd:String,prms:Array<String>,?env:Dynamic):ChildProcess {
    var cp = require('child_process');
    return cp.spawn(cmd,prms,env);
  }

  public static function
  exec(cmd:String,options:ExecOptions,fn:NodeErr->StdOut->StdErr->Void) {
    var cp:Dynamic = require('child_process');
    trace("cp is "+cp);
    if (options != null)
      cp.exec(cmd,options,fn);
    else
      cp.exec(cmd,fn);    
  }
  
  public static function
  newBuffer(size:Int):Buffer {
    var b = require('buffer');
    return untyped __js__('new b.Buffer(size)');
  }

  public static function
  newScript(code:String,?fileName:Dynamic):Script {
    var b = process.binding('evals');
    return untyped __js__('new b.Script(code,fileName)');
  }

}


