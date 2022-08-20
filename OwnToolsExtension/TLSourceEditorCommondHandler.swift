//
//  TLSourceEditorCommondHandler.swift
//  OwnToolsExtension
//
//  Created by talon on 2022/7/20.
//

import Foundation
import XcodeKit

protocol TLSourceEditorCommondHandler {
    func processCodeWithInvocation(invocation : XCSourceEditorCommandInvocation) -> Void
}
