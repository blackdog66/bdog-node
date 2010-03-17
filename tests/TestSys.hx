
import utest.Assert;
import utest.Runner;
import utest.ui.Report;

import js.Sys;
import js.FileSystem;
import js.io.File;

class TestSys {

  static var testDir = "/home/blackdog/Projects/hx/node/tests";
  
  public static function main() {
    var runner = new Runner();
    runner.addCase(new TestSys());
    runner.addCase(new FileSys());
    Report.create(runner);
    runner.run();
  }
  
  public function new() {}
  
  public function
  testEnv() {
    Assert.equals(Sys.getEnv("HAXE_LIBRARY_PATH"), "/home/blackdog/Projects/hx/haxe/std");
  }

  public function
  testArgs() {
    Assert.equals(Sys.args()[1],Sys.executablePath());
    Assert.equals(Sys.args()[0],"node");
  }

  public function
  testCwd() {
    Assert.equals(Sys.getCwd(),testDir);
  }

  public function
  testSetCwd() {
    Assert.equals(Sys.getCwd(),testDir);
    Sys.setCwd("..");
    Assert.equals(Sys.getCwd(),"/home/blackdog/Projects/hx/node");
    Sys.setCwd("tests");
    Assert.equals(Sys.getCwd(),testDir);
  }

  public function
  testSystemName() {
    Assert.equals(Sys.systemName(),"linux2");
  }

  public function
  testCmd() {
     
    Sys.commandAsync("pwd",function(err,out) {
        trace("testing "+out);
        if (err != 0) throw "shtie";
        if (out != "sadads") throw "boo";
      });
  }

  public function
  testEnvironment() {
    var env = Sys.environment() ;
    Assert.equals(env.get("HAXE_LIBRARY_PATH"),Sys.getEnv("HAXE_LIBRARY_PATH"));
  }
  
}

class FileSys {
  public function new() {}

  public function testStat() {
    var st = FileSystem.stat("testsys.js");
    Assert.equals(1002,st.gid);
    Assert.equals(st.atime.getDay(),Date.now().getDay());      
  }

  public function testKind() {
    var st = FileSystem.stat("testsys.js");
    Assert.isTrue(untyped st.isFile());
    Assert.equals(FileSystem.kind("testsys.js"),kfile);
    
  }

  public function testDirs() {
    if (!FileSystem.exists("./woot/"))
      FileSystem.createDirectory("./woot/");
    Assert.equals(FileSystem.kind("./woot/"),kdir);
    FileSystem.deleteDirectory("./woot/");
  } 
}

