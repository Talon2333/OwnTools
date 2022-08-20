//
//  TLGenerateLazyCode.swift
//  OwnToolsExtension
//
//  Created by talon on 2022/7/20.
//

import Cocoa
import XcodeKit

class TLGenerateLazyCode: TLSourceEditorCommondHandler {
    static let sharedInstance = TLGenerateLazyCode()
    lazy var lazyCodeArray: NSMutableArray = NSMutableArray.init()
    
    func processCodeWithInvocation(invocation: XCSourceEditorCommandInvocation) -> Void {
        for item in invocation.buffer.selections { // 遍历每一行选中的去添加lazy code
            self.addLazyCode(textRange: item as! XCSourceTextRange, invocation: invocation)
        }
    }
    
    private func addLazyCode(textRange: XCSourceTextRange, invocation: XCSourceEditorCommandInvocation) {
        self.lazyCodeArray.removeAllObjects()

        let startLine = textRange.start.line
        let endLine = textRange.end.line
        for lineIndex in startLine...endLine {
            var lineText: NSString = invocation.buffer.lines.object(at: lineIndex) as! NSString
            print("st tool lineText -- \(lineText)")
            lineText = lineText.deleteSpaceAndNewLine()
            print("st tool lineText end -- \(lineText)")
            if lineText.length <= 0 {
                continue
            }
            let className = lineText.fetchClassNameString()
            let propertyName = lineText.fetchPropertyNameString()
            let shouldAdd = lineText.contains("*")
            print("st tool className -- \(String(describing: className)) propertyName -- \(String(describing: propertyName)) shouldAdd -- \(shouldAdd)")
            guard className != nil && propertyName != nil && shouldAdd else { // 不是oc对象或者选中的行没有类名和属性名
                continue
            }
            // 格式化代码
            let formattedLineContent = self.formattedLineContent(by: lineText, className: className ?? "", propertyName: propertyName ?? "")
            invocation.buffer.lines.replaceObject(at: lineIndex, with: formattedLineContent)
            // 根据类名及属性名获取懒加载代码片段转化成的数组
            let lazyCodeArray: NSArray? = self.autoFetchGetterContents(className: className ?? "", propertyName: propertyName ?? "")
            guard lazyCodeArray != nil && lazyCodeArray!.count > 1 else {
                return
            }
            var firstString = lazyCodeArray?.object(at: 1)
            lazyCodeArray?.enumerateObjects({ (lazyCode, index, stop) in
                var lazyCodeString: NSString = lazyCode as! NSString
                lazyCodeString = lazyCodeString.deleteSpaceAndNewLine()
                if lazyCodeString.contains("-") {
                    firstString = lazyCodeString
                }
            })
            let currentClassName = invocation.buffer.lines.fetchCurrentClassName(to: startLine) // 获取当前需要插入懒加载代码片段的属性所在的类
            let impIndex = invocation.buffer.lines.indexOfFirstItemContainStringsArray(strings: NSArray.init(objects: TLImplementation as NSString, currentClassName!)) // 获取@implementation currentClassName 的位置
            let endIndex = invocation.buffer.lines.indexOfFirstItem(containedString: TLEnd as NSString, fromIndex: impIndex) // 获取@end的位置
            let existIndex = invocation.buffer.lines.indexOfFirstItem(containedString: firstString as! NSString, fromIndex: impIndex, toIndex: endIndex)
            let existLazyMethod = self.checkExistLazyMethod(with: className ?? "", propertyName: propertyName ?? "", lines: invocation.buffer.lines, startLine: startLine)
            if existIndex == NSNotFound && existLazyMethod == false { // 如果没有写过懒加载代码就插入
                // 待插入的懒加载代码
                self.lazyCodeArray.add(lazyCodeArray as! [Any])
            }
        }
        // 添加懒加载代码
        self.addLazyCode(with: invocation.buffer.lines, selectStartLine: startLine)
    }

    private func formattedLineContent(by originContent: NSString, className: NSString, propertyName: NSString) -> NSString {
        guard originContent.length > 0 && className.length > 0 && propertyName.length > 0 else {
            return ""
        }
        var formattedLineContent: NSString
        
        let hasProperty:Bool = originContent.contains("@property")
        if hasProperty {
            formattedLineContent = originContent
            formattedLineContent = formattedLineContent.replacingOccurrences(of: "(", with: " (") as NSString
            formattedLineContent = formattedLineContent.replacingOccurrences(of: ")", with: ") ") as NSString
            formattedLineContent = formattedLineContent.replacingOccurrences(of: ",", with: ", ") as NSString
            formattedLineContent = formattedLineContent.replacingOccurrences(of: "*", with: " *") as NSString

        } else if originContent.contains("*") {
            formattedLineContent = NSString.init(format: "@property (nonatomic, strong) %@ *%@;", className, propertyName)
            
        } else {
            formattedLineContent = NSString.init(format: "@property (nonatomic, assign) %@ %@;", className, propertyName)
        }
        
        return formattedLineContent
    }
    
    func autoFetchGetterContents(className: NSString, propertyName: NSString) -> NSArray? {
        guard className.length > 0 && propertyName.length > 0 else {
            return nil
        }
        print("st tool autoFetchGetterContents")
        guard let ud = UserDefaults.init(suiteName: TLGroupName),
              let classDic:Dictionary<String, String> = ud.object(forKey: TLClassDicKey) as? Dictionary<String, String>,
              let contentString:String = classDic[className as String] else {
            print("st tool old code")
            return fetchGetterContents(className: className, propertyName: propertyName)
        }
        print("st tool classDic -- \(classDic)")
        print("st tool contentString -- \(contentString)")
        var resultString = contentString.replacingOccurrences(of: TLClassPlaceholder, with: className as String)
        resultString = resultString.replacingOccurrences(of: TLPropertyPlaceholder, with: propertyName as String)
        var contents = resultString.components(separatedBy: "\n")
        contents.append("")
        
        return contents as NSArray
    }
    
    func fetchGetterContents(className: NSString, propertyName: NSString) -> NSArray? {
        guard className.length > 0 && propertyName.length > 0 else {
            return nil
        }
        var contentString: NSString
        
        contentString = NSString.init(format: TLLazyCommonCode as NSString, className, propertyName, propertyName, propertyName, className, propertyName)

        var contents = contentString.components(separatedBy: "\n")
        contents.append("")
        
        return contents as NSArray
    }
    
    func checkExistLazyMethod(with className: NSString, propertyName: NSString, lines: NSMutableArray, startLine: NSInteger) -> Bool {
        var existLazyMethod = false
        let lazyFirstLine = NSString.init(format: "-(%@*)%@", className, propertyName)
        let currentClassName = lines.fetchCurrentClassName(to: startLine)
        let impIndex = lines.indexOfFirstItemContainStringsArray(strings: NSArray.init(objects: TLImplementation as NSString, currentClassName!))
        let endIndex = lines.indexOfFirstItem(containedString: TLEnd as NSString, fromIndex: impIndex)
        guard impIndex != NSNotFound && endIndex != NSNotFound else {
            return true
        }
        for lineIndex in impIndex...endIndex {
            var lineText: NSString = lines.object(at: lineIndex) as! NSString
            lineText = lineText.deleteSpaceAndNewLine()
            if lineText.contains(lazyFirstLine as String) {
                existLazyMethod = true
                break
            }
        }
        
        return existLazyMethod
    }
    
    private func addLazyCode(with lines: NSMutableArray, selectStartLine: NSInteger) {
        let currentClassName = lines.fetchCurrentClassName(to: selectStartLine) // 获取当前需要插入懒加载代码片段的属性所在的类
        let impIndex = lines.indexOfFirstItemContainStringsArray(strings: NSArray.init(objects: TLImplementation as NSString, currentClassName!)) // 获取@implementation currentClassName 的位置
        let endIndex = lines.indexOfFirstItem(containedString: TLEnd as NSString, fromIndex: impIndex) // 获取@end的位置
        var insertIndex = lines.indexOfFirstItem(containedString: TLGetterSetterPragmaMark as NSString, fromIndex: impIndex, toIndex: endIndex)
        if insertIndex != NSNotFound {
            insertIndex = insertIndex + 1 // 在getter setter后面插入
        } else {
            insertIndex = endIndex
        }
        for item in self.lazyCodeArray {
            guard let codeArray: NSArray = item as? NSArray else {
                continue
            }
            lines.insertItems(itemsArray: codeArray, fromIndex: insertIndex)
            insertIndex = insertIndex + codeArray.count
        }
    }
}
