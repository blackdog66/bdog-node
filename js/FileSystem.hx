package js;

import js.Node;

import StringTools;

typedef FileStat = {
	var gid : Int;
	var uid : Int;
	var atime : Date;
	var mtime : Date;
	var ctime : Date;
	var dev : Int;
	var ino : Int;
	var nlink : Int;
	var rdev : Int;
	var size : Int;
	var mode : Int;
}

enum FileKind {
	kdir;
	kfile;
	kother( k : String );
}

class FileSystem {

  public static function exists( path : String ) : Bool {
    try {
      stat(path);
      return true;
    } catch(ex:Dynamic) {}
    return false;
  }
  
  public static function rename( path : String, newpath : String ) {
    Node.fs.renameSync(path,newpath);
  }
  
  public static function stat( path : String ) : FileStat {
    var s : FileStat = untyped Node.fs.statSync(path) ;
    return s;
  }

  public static function fullPath( relpath : String ) : String {
    return Node.fs.realpathSync(relpath);
  }
  
  static function getFileKind(stat:js.Node.Stats) {
    if (stat.isBlockDevice()) return "block";
    if (stat.isCharacterDevice()) return "character";
    if (stat.isSymbolicLink()) return "symbolic";
    if (stat.isFIFO()) return "fifo";
    if (stat.isSocket()) return "socket";
    return null;
  }
  
  public static function kind( path : String ) : FileKind {
    try {
    var stat = Node.fs.statSync(path);
    return
      if (stat.isDirectory())
        kdir;
      else {
        if (stat.isFile())
          kfile;
        else 
          kother(getFileKind(stat));
      }
    } catch(exc:Dynamic) {
      trace("kind:"+exc+", "+path);
    }
    return null;
  }

  public static function isDirectory( path : String ) : Bool {
    return kind(path) == kdir;
  }
  
  public static function createDirectory( path : String ) {
    Node.fs.mkdirSync(path,0777);
  }
  
  public static function deleteFile( path : String ) {
    Node.fs.unlinkSync(path);
  }
  
  public static function deleteDirectory( path : String ) {
    Node.fs.rmdirSync(path);
  }

  public static function readDirectory( path : String ) : Array<String> {
    return Node.fs.readdirSync(path);
  }
  
}
