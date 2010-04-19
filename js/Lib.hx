/*
 * Copyright (c) 2005, The haXe Project Contributors
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */
package js;

#if !nodejs
import js.Dom;
#end

class Lib {

  #if !nodejs
	public static var isIE : Bool;
	public static var isOpera : Bool;
	public static var document : Document;
	public static var window : Window;
  #end
  
  static var onerror : String -> Array<String> -> Bool = null;

  public static function alert( v : Dynamic ) {
    #if !nodejs
    untyped __js__("alert")(js.Boot.__string_rec(v,""));
    #else
    untyped js.Node.sys.print(js.Boot.__string_rec(v,""));
    #end
  }
  
  public static function print(v:Dynamic) {
    alert(v);
  }

  public static function println(v:Dynamic) {
    #if nodejs
    untyped js.Node.sys.puts(js.Boot.__string_rec(v,""));
    #end
  }

 
  public static function eval( code : String ) : Dynamic {
    return untyped __js__("eval")(code);
  }
  
  public static function setErrorHandler( f ) {
    onerror = f;
  }
  
	static function __init__() untyped {
#if !nodejs
      document = untyped __js__("document");
	  window = untyped __js__("window");
#end
        #if debug
__js__('onerror = function(msg,url,line) {
		var stack = $s.copy();
		var f = js.Lib.onerror;
		$s.splice(0,$s.length);
		if( f == null ) {
			var i = stack.length;
			var s = "";
			while( --i >= 0 )
				s += "Called from "+stack[i]+"\\n";
			alert(msg+"\\n\\n"+s);
			return false;
		}
		return f(msg,stack);
	}');
		#else
__js__('onerror = function(msg,url,line) {
		var f = js.Lib.onerror;
		if( f == null )
			return false;
		return f(msg,[url+":"+line]);
	}');
		#end
	}

}
