class_name ComplexObject
extends RefCounted

var var1 := SimpleObject.new()
var var2 := [SimpleObject.new(), SimpleObject.new()]
var var3 := {"key": SimpleObject.new()}

@warning_ignore("unused_private_class_variable")
var _snapshot = Snapshot.new(self, ["var1", "var2", "var3"])
