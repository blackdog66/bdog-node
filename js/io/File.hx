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

package js.io;

import js.Node;

enum FileHandle {
}

enum FileSeek {
	SeekBegin;
	SeekCur;
	SeekEnd;
}

/**
	API for reading and writing to files.
**/

class File {

  public static function getContent( path : String ) {
    return Node.fs.readFileSync(path);
  }
  
  public static function getBytes( path : String ) {
    return Node.fs.readFileSync(path,js.Node.BINARY);
  }
  
  public static function read( path : String, binary : Bool ) {
    return new FileInput(Node.fs.openSync(path,"r+"));
  }
  
  public static function write( path : String, binary : Bool ) {
    return new FileOutput(Node.fs.openSync(path,"w+"));
  }
  
  public static function append( path : String, binary : Bool ) {
    return new FileOutput(Node.fs.openSync(path,"a+"));
  }
  
  public static function copy( src : String, dst : String ) {
    var s = read(src,true);
    var d = write(dst,true);
    d.writeInput(s);
    s.close();
    d.close();
  }
  
  public static function stdin() {
    return new FileInput();
  }
  
  public static function stdout() {
    return new FileOutput(file_stdout());
  }
  
  public static function stderr() {
    return new FileOutput(file_stderr());
  }
  
  public static function getChar( echo : Bool ) : Int {
    //return getch(echo);
    return -1;
  }
  
}
