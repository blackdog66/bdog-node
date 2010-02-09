package nodejs;

import nodejs.Node;
using Lambda;

typedef MongoObj = Dynamic; 

typedef MongoConnect = {
  var hostname:String;
  var port:Int;
  var db:String;
}
  
typedef MongoCollection<T> = {
  function find(query:MongoObj,?field:MongoObj):Promise<T>;
  function insert(obj:T):Int;
  function update(cond:MongoObj,newObj:T,upsert:Bool,multi:Bool):Void;
  function remove(query:MongoObj):Void;
  function find_one(query:MongoObj,?field:MongoObj):Promise<T>;
  function count(query:MongoObj):Promise<Int>;
 
};

typedef MongoDB = { > EventEmitter<Void>,
  function connect(cnt:MongoConnect):Void;
  function close():Void;
  //function addQuery(promise:Promise,ns,query,fields,limit,skip):Void;
  //function dispatch():Void;
  function getCollection(name:String):MongoCollection<Dynamic>;
  function getCollections():Promise<Array<String>>;
};

enum Modifier {
  SET;
}

class Collection<T> {

  public var name:String;
  public var serialize:T->Dynamic;
  public var deserialize:Dynamic->T;
  
  public function new(name:String,ser:T->Dynamic=null,deser:Dynamic->T=null) {
    this.name = name;
    setSerializers(ser,deser);
  }

  public function
  setSerializers(ins:T->Dynamic,out:Dynamic->T) {
    serialize = (ins != null) ? ins : function(o) { return o; };
    deserialize = out ; // can be null because called via internalDeser
  }

}

class Mongo {
  
  public static var CONNECTION = "connection";
  public static var CLOSE = "close";
  public static var READY = "ready";
  static var IDFIELD = "_id";
  
  static var defaultCnx:MongoConnect;
  static var internalMongo:Dynamic;
  public static var ObjectID:Void->String;

  var db:MongoDB;
  
  public static function
  init(?cnx:MongoConnect) {
    defaultCnx = cnx;
    internalMongo = Node.require("mongodb");
    ObjectID = untyped __js__("node.Mongo.internalMongo.ObjectID");
  }

  public function
  new() {
    var me = this;
    db = getDB();
    db.addListener(CLOSE,function(t) {
        trace("got close");
      });
  }

  public static inline function
  getDB():MongoDB {
    return untyped __js__("new node.Mongo.internalMongo.MongoDB()");
  }
  
  public function
  collection<T>(col:Collection<T>) {
    return db.getCollection(col.name);
  }
  
  public static function
  exec(fn:Mongo->Void,?cnx:MongoConnect) {
    var mdb = new Mongo();
    mdb.addListener(CONNECTION,function(x) {
        fn(mdb);
      });
    mdb.connect((cnx != null) ? cnx : defaultCnx);
  }

  public function
  insert<T>(collection:Collection<T>,obj:T) {
    var
      p = Node.createPromise(),
      col = db.getCollection(collection.name),
      i = collection.serialize(obj);
    
    col.insert(i);        
    col.find_one(i).addCallback(function(o) {
        var
          id = Std.string(Reflect.field(o,IDFIELD));
        p.emitSuccess(id);
      });
    return p;
  }

  public function
  batchInsert<T>(col:Collection<T>,objs:Array<T>) {
    var
      p = Node.createPromise(),
      gotBack = 0,
      all = objs.length,
      insertionIDs = [];
    
    for (i in 0 ... all) {
      var p = insert(col,objs[i]).addCallback(function(id) {
          gotBack++;
          insertionIDs.push(id);
          if (gotBack == all) {
            p.emitSuccess(insertionIDs);
          }
        });
    }    
    return p;
  }

  public function
  findOne<T>(collection:Collection<T>,query:MongoObj) {
    var
      p = Node.createPromise(),
      col = db.getCollection(collection.name);
    col.find_one(query).addCallback(function(o) {
        p.emitSuccess(internalDeser(collection,o));
      });
    return p;
  }

  public function
  find<T>(collection:Collection<T>,query:MongoObj) {
    var
      p = Node.createPromise(),
      col = db.getCollection(collection.name);
    col.find(query).addCallback(function(arr:Array<MongoObj>) {
        p.emitSuccess(arr.map(function(el) { return internalDeser(collection,el); }));
      });
    return p;
  }

  public function
  update<T>(collection:Collection<T>,query:MongoObj,newObj:MongoObj,upsert=false,multi=false) {
    var
      col = db.getCollection(collection.name);
    col.update(query,collection.serialize(newObj),upsert,multi);
  }

  static function
  internalDeser<T>(coll:Collection<T>,d:Dynamic) {
    Reflect.setField(d,IDFIELD,Std.string(Reflect.field(d,IDFIELD)));
    if (coll.deserialize != null) return coll.deserialize(d);
    return d;
  }
  
  public function
  close() {
    db.close();
  }
  
  public function
  addListener(event:String,listener) {
    db.addListener(event,listener);
  }

  public function
  removeListener(event:String,listener) {
    db.removeListener(event,listener);
  }
  
  public static function
  ID(obj:MongoObj):String {
    return Std.string(Reflect.field(obj,IDFIELD));
  }

  public function
  connect(cnx:MongoConnect) {
    db.connect(cnx);
  }

  public static function
  modifier(m:Modifier,obj:MongoObj) {
    var mod = {};
    switch(m) {
    case SET:
      Reflect.setField(mod,"$set",obj);
    }
    return mod;
  }
}

