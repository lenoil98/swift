// RUN: %target-swift-frontend -swift-version 4 -enforce-exclusivity=checked %s -emit-ir -module-name CurrentModule -D CURRENT_MODULE | %FileCheck %s --check-prefix=CHECK-COMMON --check-prefix=CHECK-CURRENT
// RUN: %target-swift-frontend -swift-version 4 -enforce-exclusivity=checked %s -emit-ir -module-name OriginalModule | %FileCheck %s --check-prefix=CHECK-COMMON --check-prefix=CHECK-ORIGINAL

#if CURRENT_MODULE

@_originallyDefinedIn(module: "OriginalModule", macOS 10.15)
public struct Entity {
	public func addEntity(_ e: Entity) {}
	public func removeEntity(_ e: Entity) {}
}

@_originallyDefinedIn(module: "OriginalModule", macOS 10.15)
public protocol Movable {
	func MovableFuncFoo()
}

public protocol Unmoveable {}

@_originallyDefinedIn(module: "OriginalModule", macOS 10.15)
public class MovedClass: Movable, Unmoveable {
	public func MovableFuncFoo() {}
}

public class UnmovableClass {}

#else

public struct Entity {
	public func addEntity(_ e: Entity) {}
	public func removeEntity(_ e: Entity) {}
}

public protocol Movable {
	func MovableFuncFoo()
}

public protocol Unmoveable {}

public class MovedClass: Movable, Unmoveable {
	public func MovableFuncFoo() {}
}

public class UnmovableClass {}

#endif


func entityClient() {
	let root = Entity()
	// CHECK-COMMON: call swiftcc void @"$s14OriginalModule6EntityVACycfC"()
	let leaf = Entity()
	// CHECK-COMMON: call swiftcc void @"$s14OriginalModule6EntityVACycfC"()
	root.addEntity(leaf)
	// CHECK-COMMON: call swiftcc void @"$s14OriginalModule6EntityV03addC0yyACF"()
	let moved = MovedClass()
	// CHECK-COMMON: call swiftcc %T14OriginalModule10MovedClassC* @"$s14OriginalModule10MovedClassCACycfC"
	moved.MovableFuncFoo()
	// CHECK-COMMON: call swiftcc void @"$s14OriginalModule10MovedClassC14MovableFuncFooyyF"
}

public func unmovableClient() {
	let unmovable = UnmovableClass()
	// CHECK-CURRENT: call swiftcc %swift.metadata_response @"$s13CurrentModule14UnmovableClassCMa"(i64 0)
	// CHECK-ORIGINAL: call swiftcc %swift.metadata_response @"$s14OriginalModule14UnmovableClassCMa"(i64 0)
}

entityClient()
unmovableClient()
