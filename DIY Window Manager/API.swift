import Foundation

class API {
    
    final class Hotkey: LuaLibrary {
        let fn: Int
        let hotkey: Carbon.Hotkey
        
        class func typeName() -> String { return "<Hotkey>" }
        class var metatableName: String { return "Hotkey" }
        class func kind() -> Lua.Kind { return .Userdata }
        class func isValid(Lua, Int) -> Bool { return false }
        class func arg() -> (Lua.Kind, () -> String, (Lua, Int) -> Bool) { return (Hotkey.kind(), Hotkey.typeName, Hotkey.isValid) }
        
        func pushValue(L: Lua) {
            L.pushUserdata(self)
        }
        
        class func fromLua(L: Lua, at position: Int) -> Hotkey? {
            return L.getUserdata(position) as? Hotkey
        }
        
        init(fn: Int, hotkey: Carbon.Hotkey) {
            self.fn = fn
            self.hotkey = hotkey
        }
        
        func enable(L: Lua) -> [LuaValue] {
            hotkey.enable()
            return []
        }
        
        func disable(L: Lua) -> [LuaValue] {
            hotkey.disable()
            return []
        }
        
        class func bind(L: Lua) -> [LuaValue] {
            let key = String.fromLua(L, at: 1)!
            let mods = LuaArray<String>.fromLua(L, at: 2)
            if mods == nil { return [] }
            let modStrings = mods!.elements
            
            L.pushFromStack(3)
            let i = L.ref(Lua.RegistryIndex)
            
            let downFn: Carbon.Hotkey.Callback = {
                L.rawGet(tablePosition: Lua.RegistryIndex, index: i)
                L.call(arguments: 1, returnValues: 0)
            }
            
            let hotkey = Carbon.Hotkey(key: key, mods: modStrings, downFn: downFn, upFn: nil)
            hotkey.enable()
            
            return [Hotkey(fn: i, hotkey: hotkey)]
        }
        
        func cleanup(L: Lua) {
            hotkey.disable()
            L.unref(Lua.RegistryIndex, fn)
        }
        
        func equals(other: Hotkey) -> Bool {
            return fn == other.fn
        }
        
        class func classMethods() -> [(String, [LuaTypeChecker], Lua -> [LuaValue])] {
            return [
                ("bind", [String.arg, LuaArray<String>.arg, Lua.FunctionBox.arg], Hotkey.bind),
            ]
        }
        
        class func instanceMethods() -> [(String, [LuaTypeChecker], Hotkey -> Lua -> [LuaValue])] {
            return [
                ("enable", [], Hotkey.enable),
                ("disable", [], Hotkey.enable),
            ]
        }
        
        class func metaMethods() -> [LuaMetaMethod<Hotkey>] {
            return [
                .GC(Hotkey.cleanup),
                .EQ(Hotkey.equals),
            ]
        }
    }
    
}
