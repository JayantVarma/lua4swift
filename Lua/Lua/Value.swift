import Foundation

public protocol Value {
    func push(vm: VirtualMachine)
}

public class StoredValue: Value, Equatable {
    
    private let registryLocation: Int
    internal weak var vm: VirtualMachine?
    
    internal init(_ vm: VirtualMachine) {
        self.vm = vm
        vm.pushFromStack(-1)
        registryLocation = vm.ref(RegistryIndex)
    }
    
    deinit {
        vm?.unref(RegistryIndex, registryLocation)
    }
    
    public func push(vm: VirtualMachine) {
        vm.rawGet(tablePosition: RegistryIndex, index: registryLocation)
    }
    
}

public func ==(lhs: StoredValue, rhs: StoredValue) -> Bool {
    if lhs.vm == nil { return false }
    if lhs.vm!.vm != rhs.vm!.vm { return false }
    
    lhs.push(lhs.vm!)
    lhs.push(rhs.vm!)
    let result = lua_compare(lhs.vm!.vm, -2, -1, LUA_OPEQ) == 1
    lhs.vm!.pop(2)
    
    return result
}

//public protocol Value {
//    func push(vm: VirtualMachine)
//    init?(fromLua vm: VirtualMachine, at position: Int)
//    class func typeName() -> String
//    class func isValid(vm: VirtualMachine, at position: Int) -> Bool
//    class func arg() -> TypeChecker
//}
