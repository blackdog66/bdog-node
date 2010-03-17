/*
 * Copyright (c) 2005-2007, The haXe Project Contributors
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

/**
	By compiling the [haxe.remoting.SocketWrapper] into a SWF, you can create and use XMLSockets directly from Javascript.
**/
class XMLSocket {

	var cnx : haxe.remoting.ExternalConnection;

	public function new( flashObject : String ) {
		var ctx = new haxe.remoting.Context();
		var cnx = haxe.remoting.ExternalConnection.flashConnect("SocketWrapper",flashObject,ctx);
		var sockId = cnx.api.create.call([flashObject]);
		cnx.close();
		ctx.addObject("api",this,false);
		this.cnx = haxe.remoting.ExternalConnection.flashConnect(sockId,flashObject,ctx);
	}

	public function connect( host : String, port : Int ) {
		cnx.sock.connect.call([host,port]);
	}

	public function send( data : String ) {
		cnx.sock.send.call([data]);
	}

	public function close() {
		cnx.sock.close.call([]);
		cnx.api.destroy.call([]);
		cnx.close();
	}

	public dynamic function onData( data : String ) {
	}

	public dynamic function onClose() {
	}

	public dynamic function onConnect( b : Bool ) {
	}

}
