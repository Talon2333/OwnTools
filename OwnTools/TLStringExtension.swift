//
//  TLStringExtension.swift
//  OwnTools
//
//  Created by talon on 2022/7/19.
//

import Foundation

extension String {
    func stringBetween(leftString:String, rightString:String) -> String {
        guard var leftIndex = firstIndex(of: Character.init(leftString)), let rightIndex = firstIndex(of: Character.init(rightString))
        else {return ""}

        leftIndex = self.index(after: leftIndex)
        let str:String = String(self[leftIndex..<rightIndex])
        return str
    }
    
    /// 删除掉空格和换行
    func deleteSpaceAndNewLine() -> String {
        var string = self.replacingOccurrences(of: " ", with: "")
        let characterSet = CharacterSet.whitespacesAndNewlines
        string = string.trimmingCharacters(in: characterSet)
        
        return string
    }

    /// 从string中提取类名
    func fetchClassNameString() -> String? {
        let tempString = self.deleteSpaceAndNewLine()
        var classNameString : String? = nil
        if tempString.contains("*") {
            // 判断NSMutableArray<NSString *> *testArray 这样的情况来处理
            if tempString.contains("<") {
                classNameString = tempString.stringBetween(leftString: ")", rightString: "*>")
                classNameString = classNameString?.appending("*>")
            } else if tempString.contains(")") {
                classNameString = tempString.stringBetween(leftString: "(", rightString: "*")
            } else {
                classNameString = tempString.stringBetween(leftString: ",", rightString: "*")
            }
        } else {
            let tempString0 = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let characterSet = CharacterSet(charactersIn: " ")
            let itemArray = tempString0.components(separatedBy: characterSet)
            if !tempString0.hasPrefix("@property") && itemArray.count == 2 {
                classNameString = itemArray[0]
            }
        }
        
        return classNameString?.deleteSpaceAndNewLine()
    }
    
    /// 从string中提取属性名
    func fetchPropertyNameString() -> String? {
        let tempString = self.deleteSpaceAndNewLine()
        var propertyNameString : String? = nil
        propertyNameString = tempString.stringBetween(leftString: ")", rightString: "{").deleteSpaceAndNewLine()
        return propertyNameString
    }
}
