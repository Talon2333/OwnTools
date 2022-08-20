//
//  SourceEditorCommand.swift
//  OwnToolsExtension
//
//  Created by talon on 2022/7/1.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        let identifier = invocation.commandIdentifier
        print(identifier)
        
        if identifier == TLGenerateLazyMethodIdentifier {
            TLGenerateLazyCode.sharedInstance.processCodeWithInvocation(invocation: invocation)
        }
        completionHandler(nil)
    }
    
}
