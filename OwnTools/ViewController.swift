//
//  ViewController.swift
//  OwnTools
//
//  Created by talon on 2022/7/1.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var sourceCodeTextView: NSTextView!
    @IBOutlet var resultCodeTextView: NSTextView!
    @IBOutlet weak var classNameTextField: NSTextField!
    
    var dataArray:[String] = []
    var classDic:Dictionary<String, String>!
    var classOriginDic:Dictionary<String, String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initData()
        tableView.delegate = self
        tableView.dataSource = self
//        clearData()
    }
    
    func initData() {
        guard let ud = UserDefaults.init(suiteName: TLGroupName) else {
            return
        }
        if let dic:Dictionary<String, String> = ud.object(forKey: TLClassDicKey) as? Dictionary<String, String> {
            classDic = dic
        } else {
            classDic = [String:String]()
        }
        if let dic:Dictionary<String, String> = ud.object(forKey: TLClassOriginDicKey) as? Dictionary<String, String> {
            classOriginDic = dic
        } else {
            classOriginDic = [String:String]()
        }
        let allkeys = classDic.keys
        let array = Array(allkeys)
        dataArray = array
        
        if array.isEmpty {
            addExampleClass(ud: ud)
        }
        print("st allkeys -- \(array)")
    }

    @IBAction func addButtonClick(_ sender: Any) {
        let text = sourceCodeTextView.string
        guard let className = text.fetchClassNameString(), let propertyName = text.fetchPropertyNameString() else {return}

        classNameTextField.stringValue = className
        var resultText = text.replacingOccurrences(of: className, with: TLClassPlaceholder)
        resultText = resultText.replacingOccurrences(of: propertyName, with: TLPropertyPlaceholder)

        resultCodeTextView.string = resultText
        
        print("st textView text -- \(sourceCodeTextView.string) \n className -- \(className) propertyName -- \(propertyName)")

        guard let ud = UserDefaults.init(suiteName: TLGroupName) else {
            return
        }
        
        let existClass:Bool = classDic[className] != nil
        
        classDic[className] = resultText
        classOriginDic[className] = text
        ud.setValue(classDic, forKey: TLClassDicKey)
        ud.setValue(classOriginDic, forKey: TLClassOriginDicKey)

        if !existClass {
            //添加数据
            dataArray.append(className)
            tableView.reloadData()
        }
    }
    
    /// 清除数据
    func clearData() {
        guard let ud = UserDefaults.init(suiteName: TLGroupName) else {
            return
        }
        classDic.removeAll()
        classOriginDic.removeAll()
        dataArray.removeAll()
        ud.setValue(classDic, forKey: TLClassDicKey)
        ud.setValue(classOriginDic, forKey: TLClassOriginDicKey)
        tableView.reloadData()
    }
    
    
    /// 添加自定义Getter例子-UILabel
    func addExampleClass(ud:UserDefaults) {
        let className = "UILabel"
        let labelOriginStr = "- (UILabel *)titleLabel {\n    if (!_titleLabel) {\n        _titleLabel = [[UILabel alloc] init];\n        _titleLabel.font = [UIFont systemFontOfSize:15];\n        _titleLabel.textColor = [UIColor blackColor];\n        _titleLabel.textAlignment = NSTextAlignmentLeft;\n    }\n    return _titleLabel;\n}\n"
        
        let labelStr = "- (<class> *)<property> {\n    if (!_<property>) {\n        _<property> = [[<class> alloc]\n        _<property>.font = [UIFont systemFontOfSize:15];\n        _<property>.textColor = [UIColor blackColor];\n        _<property>.textAlignment = NSTextAlignmentLeft;\n    }\n    return _<property>;\n}"
        classDic[className] = labelStr
        classOriginDic[className] = labelOriginStr
        ud.setValue(classDic, forKey: TLClassDicKey)
        ud.setValue(classOriginDic, forKey: TLClassOriginDicKey)
        
        dataArray.append(className)
        tableView.reloadData()
    }
}

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return dataArray[row]
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let textFiled = NSTextField.init(frame: .zero)
        textFiled.isBordered = false
        textFiled.isEditable = false
        return textFiled
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let className = dataArray[tableView.selectedRow]
        guard let method = classDic[className] else {return}
        classNameTextField.stringValue = className
        resultCodeTextView.string = method
        
        //原有方法
        guard let originMethod = classOriginDic[className] else {
            sourceCodeTextView.string = ""
            return
        }
        sourceCodeTextView.string = originMethod
    }
}
