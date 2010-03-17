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
import Xml;

class JsXml__ {

	static var enode = ~/^<([a-zA-Z0-9:_-]+)/;
	static var ecdata = ~/^<!\[CDATA\[/i;
	static var edoctype = ~/^<!DOCTYPE/i;
	static var eend = ~/^<\/([a-zA-Z0-9:_-]+)>/;
	static var epcdata = ~/^[^<]+/;
	static var ecomment = ~/^<!--/;
	static var eprolog = ~/^<\?[^\?]+\?>/;

	static var eattribute = ~/^\s*([a-zA-Z0-9:_-]+)\s*=\s*(["'])([^\2]*?)\2/; //"
	static var eclose = ~/^[ \r\n\t]*(>|(\/>))/;
	static var ecdata_end = ~/\]\]>/;
	static var edoctype_elt = ~/[\[|\]>]/;
	static var ecomment_end = ~/-->/;

	public var nodeType(default,null) : XmlType;
	public var nodeName(getNodeName,setNodeName) : String;
	public var nodeValue(getNodeValue,setNodeValue) : String;
	public var parent(getParent,null) : JsXml__;

	var _nodeName : String;
	var _nodeValue : String;
	var _attributes : Hash<String>;
	var _children : Array<JsXml__>;
	var _parent : JsXml__;

	public static function parse( str : String ) : Xml {
		var rules = [enode,epcdata,eend,ecdata,edoctype,ecomment,eprolog];
		var nrules = rules.length;
		var current = Xml.createDocument();

		var stack = new List();
		while( str.length > 0 ) {
			var i = 0;
			while( i < nrules ) {
				var r = rules[i];
				if( r.match(str) ) {
					switch( i ) {
					case 0: // Node
						var x = Xml.createElement(r.matched(1));
						current.addChild(x);
						str = r.matchedRight();
						while( eattribute.match(str) ) {
							x.set(eattribute.matched(1),eattribute.matched(3));
							str = eattribute.matchedRight();
						}
						if( !eclose.match(str) ) {
							i = nrules;
							break;
						}
						if( eclose.matched(1) == ">" ) {
							stack.push(current);
							current = x;
						}
						str = eclose.matchedRight();
					case 1: // PCData
						var x = Xml.createPCData(r.matched(0));
						current.addChild(x);
						str = r.matchedRight();
					case 2: // End Node
						untyped if( current._children != null && current._children.length == 0 ) {
							var e = Xml.createPCData("");
							current.addChild(e);
						}
						untyped if( r.matched(1) != current._nodeName || stack.isEmpty() ) {
							i = nrules;
							break;
						}
						current = stack.pop();
						str = r.matchedRight();
					case 3: // CData
						str = r.matchedRight();
						if( !ecdata_end.match(str) )
							throw "End of CDATA section not found";
						var x = Xml.createCData(ecdata_end.matchedLeft());
						current.addChild(x);
						str = ecdata_end.matchedRight();
					case 4: // DocType
						var pos = 0;
						var count = 0;
						var old = str;
						while( true ) {
							if( !edoctype_elt.match(str) )
								throw "End of DOCTYPE section not found";
							var p = edoctype_elt.matchedPos();
							pos += p.pos + p.len;
							str = edoctype_elt.matchedRight();
							switch( edoctype_elt.matched(0) ) {
							case "[": count++;
							case "]": count--; if( count < 0 ) throw "Invalid ] found in DOCTYPE declaration";
							default:
								if( count == 0 )
									break;
							}
						}
						var x = Xml.createDocType(old.substr(0,pos));
						current.addChild(x);
					case 5: // Comment
						if( !ecomment_end.match(str) )
							throw "Unclosed Comment";
						var p = ecomment_end.matchedPos();
						var x = Xml.createComment(str.substr(0,p.pos+p.len));
						current.addChild(x);
						str = ecomment_end.matchedRight();
					case 6: // Prolog
						var x = Xml.createProlog(r.matched(0));
						current.addChild(x);
						str = r.matchedRight();
					}
					break;
				}
				i += 1;
			}
			if( i == nrules ) {
				if( str.length > 10 )
					throw ("Xml parse error : Unexpected "+str.substr(0,10)+"...");
				else
					throw ("Xml parse error : Unexpected "+str);
			}
		}
		if( !stack.isEmpty() )
			throw "Xml parse error : Unclosed "+stack.last().nodeName;
		untyped return current;
	}

	private function new(){
	}

	static function createElement( name : String ) : JsXml__ {
		var r = new JsXml__();
		r.nodeType = Xml.Element;
		r._children = new Array();
		r._attributes = new Hash();
		r.setNodeName( name );
		return r;
	}

	static function createPCData( data : String ) : JsXml__ {
		var r = new JsXml__();
		r.nodeType = Xml.PCData;
		r.setNodeValue( data );
		return r;
	}

	static function createCData( data : String ) : JsXml__ {
		var r = new JsXml__();
		r.nodeType = Xml.CData;
		r.setNodeValue( data );
		return r;
	}

	static function createComment( data : String ) : JsXml__ {
		var r = new JsXml__();
		r.nodeType = Xml.Comment;
		r.setNodeValue( data );
		return r;
	}

	static function createDocType( data : String ) : JsXml__ {
		var r = new JsXml__();
		r.nodeType = Xml.DocType;
		r.setNodeValue( data );
		return r;
	}

	static function createProlog( data : String ) : JsXml__ {
		var r = new JsXml__();
		r.nodeType = Xml.Prolog;
		r.setNodeValue( data );
		return r;
	}

	static function createDocument() : JsXml__ {
		var r = new JsXml__();
		r.nodeType = Xml.Document;
		r._children = new Array();
		return r;
	}

	private function getNodeName() : String {
		if( nodeType != Xml.Element )
			throw "bad nodeType";
		return _nodeName;
	}

	private function setNodeName( n : String ) : String {
		if( nodeType != Xml.Element )
			throw "bad nodeType";
		return _nodeName = n;
	}

	private function getNodeValue() : String {
		if( nodeType == Xml.Element || nodeType == Xml.Document )
			throw "bad nodeType";
		return _nodeValue;
	}

	private function setNodeValue( v : String ) : String {
		if( nodeType == Xml.Element || nodeType == Xml.Document )
			throw "bad nodeType";
		return _nodeValue = v;
	}

	private function getParent() {
		return _parent;
	}

	public function get( att : String ) : String {
		if( nodeType != Xml.Element )
			throw "bad nodeType";
		return _attributes.get( att );
	}

	public function set( att : String, value : String ) : Void {
		if( nodeType != Xml.Element )
			throw "bad nodeType";
		_attributes.set( att, value );
	}

	public function remove( att : String ) : Void{
		if( nodeType != Xml.Element )
			throw "bad nodeType";
		_attributes.remove( att );
	}

	public function exists( att : String ) : Bool {
		if( nodeType != Xml.Element )
			throw "bad nodeType";
		return _attributes.exists( att );
	}

	public function attributes() : Iterator<String> {
		if( nodeType != Xml.Element )
			throw "bad nodeType";
		return _attributes.keys();
	}

	public function iterator() : Iterator<JsXml__> {
		if( _children == null ) throw "bad nodetype";
		return untyped {
			cur: 0,
			x: this._children,
			hasNext : function(){
				return this.cur < this.x.length;
			},
			next : function(){
				return this.x[this.cur++];
			}
		}
	}

	public function elements(){
		if( _children == null ) throw "bad nodetype";
		return untyped {
			cur: 0,
			x: this._children,
			hasNext : function() {
				var k = this.cur;
				var l = this.x.length;
				while( k < l ) {
					if( this.x[k].nodeType == Xml.Element )
						break;
					k += 1;
				}
				this.cur = k;
				return k < l;
			},
			next : function() {
				var k = this.cur;
				var l = this.x.length;
				while( k < l ) {
					var n = this.x[k];
					k += 1;
					if( n.nodeType == Xml.Element ) {
						this.cur = k;
						return n;
					}
				}
				return null;
			}
		}
	}

	public function elementsNamed( name : String ) {
		if( _children == null ) throw "bad nodetype";
		return untyped {
			cur: 0,
			x: this._children,
			hasNext : function() {
				var k = this.cur;
				var l = this.x.length;
				while( k < l ) {
					var n = this.x[k];
					if( n.nodeType == Xml.Element && n._nodeName == name )
						break;
					k++;
				}
				this.cur = k;
				return k < l;
			},
			next : function() {
				var k = this.cur;
				var l = this.x.length;
				while( k < l ) {
					var n = this.x[k];
					k++;
					if( n.nodeType == Xml.Element && n._nodeName == name ) {
						this.cur = k;
						return n;
					}
				}
				return null;
			}
		}
	}

	public function firstChild() : JsXml__ {
		if( _children == null ) throw "bad nodetype";
		return _children[0];
	}

	public function firstElement() : JsXml__ {
		if( _children == null ) throw "bad nodetype";
		var cur = 0;
		var l = _children.length;
		while( cur < l ) {
			var n = _children[cur];
			if( n.nodeType == Xml.Element )
				return n;
			cur++;
		}
		return null;
	}

	public function addChild( x : JsXml__ ) : Void {
		if( _children == null ) throw "bad nodetype";
		if( x._parent != null ) x._parent._children.remove(x);
		x._parent = this;
		_children.push( x );
	}

	public function removeChild( x : JsXml__ ) : Bool {
		if( _children == null ) throw "bad nodetype";
		var b = _children.remove( x );
		if( b )
			x._parent = null;
		return b;
	}

	public function insertChild( x : JsXml__, pos : Int ) : Void {
		if( _children == null ) throw "bad nodetype";
		if( x._parent != null ) x._parent._children.remove(x);
		x._parent = this;
		_children.insert( pos, x );
	}

	public function toString() {
		if( nodeType == Xml.PCData )
			return _nodeValue;
		if( nodeType == Xml.CData )
			return "<![CDATA["+_nodeValue+"]]>";
		if( nodeType == Xml.Comment || nodeType == Xml.DocType || nodeType == Xml.Prolog )
			return _nodeValue;

		var s = new StringBuf();

		if( nodeType == Xml.Element ) {
			s.add("<");
			s.add(_nodeName);
			for( k in _attributes.keys() ){
				s.add(" ");
				s.add(k);
				s.add("=\"");
				s.add(_attributes.get(k));
				s.add("\"");
			}
			if( _children.length == 0 ) {
				s.add("/>");
				return s.toString();
			}
			s.add(">");
		}

		for( x in iterator() )
			s.add(x.toString());

		if( nodeType == Xml.Element ) {
			s.add("</");
			s.add(_nodeName);
			s.add(">");
		}
		return s.toString();
	}

}
