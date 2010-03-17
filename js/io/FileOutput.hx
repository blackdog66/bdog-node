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
import js.io.File;

/**
	Use [neko.io.File.write] to create a [FileOutput]
**/
class FileOutput extends haxe.io.Output {

	private var __f : FileHandle;

	public function new(f) {
		__f = f;
	}

	public override function writeByte( c : Int ) {
      try js.Node.fs.writeSync(__f,c,Node.BINARY) catch( e : Dynamic ) throw haxe.io.Error.Custom(e);
	}

	public override function writeBytes( s : haxe.io.Bytes, p : Int, l : Int ) : Int {
      return try js.Node.fs.writeSync(__f,s.getData().toString,p,Node.BINARY) catch( e : Dynamic ) throw haxe.io.Error.Custom(e);
	}

	public override function flush() {
      //file_flush(__f);
	}

	public override function close() {
		super.close();
		closeSync(__f);
	}

	public function seek( p : Int, pos : FileSeek ) {
      //TODO
      //		file_seek(__f,p,switch( pos ) { case SeekBegin: 0; case SeekCur: 1; case SeekEnd: 2; });
	}

	public function tell() : Int {
      //TODO
        return -1;
	}

}
