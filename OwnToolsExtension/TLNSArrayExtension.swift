//
//  TLNSArrayExtension.swift
//  OwnToolsExtension
//
//  Created by talon on 2022/7/20.
//

import Foundation

extension NSMutableArray {
    
    func indexOfFirstItemContainStringsArray(strings : NSArray) -> NSInteger {
        var index = NSNotFound
        var i = 0
        for item in self {
            var isMatch = true
            if item is NSString {
                var aString: NSString = item as! NSString
                aString = aString.deleteSpaceAndNewLine()
                for innerItem in strings {
                    guard let bString: NSString = innerItem as? NSString else {
                        continue
                    }
                    if !aString.contains(bString as String) {
                        isMatch = false
                        break
                    }
                }
            }
            if isMatch {
                index = i
                break
            }
            i += 1
        }
        
        return index
    }
    
    func indexOfFirstItem(containedString: NSString, fromIndex : NSInteger) -> NSInteger {
        return self.indexOfFirstItem(containedString: containedString, fromIndex: fromIndex, toIndex: self.count - 1)
    }
    
    func indexOfFirstItem(containedString: NSString, fromIndex: NSInteger, toIndex: NSInteger) -> NSInteger {
        var index = NSNotFound
        guard fromIndex < self.count && toIndex < self.count && containedString.length > 0 else {
            return index
        }

        for itemIndex in (fromIndex...toIndex) {
            var contentString: NSString? = self.object(at: itemIndex) as? NSString
            guard contentString != nil else {
                continue
            }
            contentString = contentString?.deleteSpaceAndNewLine()
            let range = contentString?.range(of: containedString as String)
            if range?.location != NSNotFound {
                index = itemIndex
                break
            }
        }
        
        return index
    }
    
    func insertItems(itemsArray: NSArray, fromIndex: NSInteger) -> Void {
        guard itemsArray.count > 0 && fromIndex < self.count else {
            return
        }
        var insertIndex = fromIndex
        for item in itemsArray {
            guard let insertString: NSString = item as? NSString else {
                continue
            }
            self.insert(insertString, at: insertIndex)
            insertIndex += 1
        }
    }
    
    func fetchCurrentClassName(to currentLineIndex: NSInteger) -> NSString? {
        var className: NSString? = nil
        guard currentLineIndex < self.count else {
            return className
        }
        for index in (0...currentLineIndex).reversed() {
            guard var tempString: NSString = self.object(at: index) as? NSString else {
                continue
            }
            tempString = tempString.deleteSpaceAndNewLine()
            if tempString.hasPrefix(TLImplementation) {
                let implementationString = TLImplementation as NSString
                if tempString.contains("(") {
                    className = tempString.stringBetween(leftString: implementationString, rightString: "(")
                } else {
                    className = tempString.substring(from: implementationString.length) as NSString
                }
                break
            } else if tempString.hasPrefix(TLInterface) {
                let interfaceString = TLInterface as NSString
                if tempString.contains(":") {
                    className = tempString.stringBetween(leftString: interfaceString, rightString: ":")
                } else if tempString.contains("(") {
                    className = tempString.stringBetween(leftString: interfaceString, rightString: "(")
                }
                break
            }
        }
        
        return className
    }
}
