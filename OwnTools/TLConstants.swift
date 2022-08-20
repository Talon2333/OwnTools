//
//  TLConstants.swift
//  OwnTools
//
//  Created by talon on 2022/7/19.
//

import Foundation

let TLGenerateLazyMethodIdentifier = "com.talon.OwnTools.OwnToolsExtension.GenerateLazyMethod"


let TLGroupName = "group.talon.OwnTools"


let TLClassPlaceholder = "<class>"
let TLPropertyPlaceholder = "<property>"
let TLClassDicKey = "STClassDicKey"
let TLClassOriginDicKey = "STClassOriginDicKey"


let TLImplementation = "@implementation"
let TLInterface = "@interface"
let TLEnd = "@end"


let TLGetterSetterPragmaMark = "#pragma mark - Getter && Setter"
let TLLazyCommonCode = "\n- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] init];\n    }\n    return _%@;\n}"
