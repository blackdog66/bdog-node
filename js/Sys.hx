package js;

import js.Node;

class Sys {
  public static function
  args() : Array<String> {
    return Node.process.argv;
  }

  public static function
  getEnv( s : String ) : String {
    return Reflect.field(Node.process.env,s);
  }

  public static function
  putEnv( s : String, v : String ) : Void {
    //TODO
  }

  public static function
  sleep( seconds : Float ) {
    //TODO
  }

  public static function
  setTimeLocale( loc : String ) : Bool {
    //return untyped __call__("setlocale", __php__("LC_TIME"), loc) != false;
    //TODO
    return false;
  }

  public static function
  getCwd() : String {
    return Node.process.cwd();
  }

  public static function
  setCwd( s : String ) {
    Node.process.chdir(s);
  }

  public static function
  systemName() : String {
    return "nodejs";
  }

  public static function
  escapeArgument( arg : String ) : String {
    var ok = true;
    for( i in 0...arg.length )
      switch( arg.charCodeAt(i) ) {
      case 32, 34: // [space] "
        ok = false;
      case 0, 13, 10: // [eof] [cr] [lf]
        arg = arg.substr(0,i);
      }
    if( ok )
      return arg;
    return '"'+arg.split('"').join('\\"')+'"';
	}


  public static function
  commandAsync( cmd : String, ?args : Array<String>,ret:Int->String->Void):Void {
    if( args != null ) {
      cmd = escapeArgument(cmd);
      for( a in args )
        cmd += " "+escapeArgument(a);
    }
    
    Node.exec(cmd,null,function(err,stdout,stderr) {
        var result:Int = 0,
          output:String=stdout;
        
        if (err != null)
          result = err.code;
        
        ret(result,output);
      });         
  }
  
  public static function
  exit( code : Int ) {
    return Node.process.exit(code);
  }

  public static function
  time() : Float {
    //TODO
    return 0.0;
  }

  public static function
  cpuTime() : Float {
    //TODO
    return 0.0;
  }

  public static function
  executablePath() : String {
    return Node.__filename;
  }

  public static function
  environment() : Hash<String> {
    var
      env = Node.process.env,
      h = new Hash<String>() ;

    for (f in Reflect.fields(env)) {
      h.set(f,Reflect.field(env,f));
    }
      
    return h;
  }
  
}

