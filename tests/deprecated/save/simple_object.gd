class_name SimpleObject 
extends RefCounted
	
var var1 := 1
var var2 := 1.0
var var3 := true
var var4 := "String"
var var5 := Vector2.ONE
var var6 := [1, 2]
var var7 := {"key": 1}

@warning_ignore("unused_private_class_variable")
var _snapshot = Snapshot.new(self,  ["var1", "var2", "var3", "var4", "var5", "var6", "var7"])
