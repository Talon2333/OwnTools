# Xcode - Source Editor Extension
用了一段时间`Tools for Xcode`，感觉生成代码功能挺好用的，很好奇它是如何实现的。搜索一番，最后找到了`Source Editor Extension`。
![Tools for Xcode](https://github.com/Talon2333/OwnTools/blob/main/Images/Tools%20for%20Xcode.png)

此文只是大致梳理了`Source Editor Extension`的使用流程及遇到的问题，详细内容可查看苹果官方文档[XcodeKit](https://developer.apple.com/documentation/xcodekit?language=objc)，另外本文最后实现了一个自定义生成`Getter`的demo。


## 创建一个源代码编辑器扩展
您可以使用 `XcodeKit` 在 `Xcode` 中构建源代码编辑器的扩展。源代码编辑器扩展可以读取和修改源文件的内容，以及读取和修改编辑器中的当前选择的文本。


### 在 Xcode 中创建一个新的 macOS 项目
要创建源代码编辑器扩展，首先在 `Xcode` 中创建一个新的 `macOS` 项目。将一个新的 `Xcode Source Editor Extension` 目标添加到您的项目中，如下图所示，并在出现提示时将其激活。

![Create Extension](https://github.com/Talon2333/OwnTools/blob/main/Images/Create%20Extension.jpg)|![Activate](https://github.com/Talon2333/OwnTools/blob/main/Images/Activate.png)
---|---


添加extension完成后，会自动生成SourceEditorCommand类，该类实现了XCSourceEditorCommand协议，协议中定义了`performCommandWithInvocation:completionHandler: `方法，当用户点击菜单中添加的命令时，都会调用此方法。


### 添加可自定义的行为
#### 添加命令
在添加的`extension`目录下找到`info`文件，并在`XCSourceEditorCommandDefinitions`下添加`item`。
![XCSourceEditorCommandDefinitions](https://github.com/Talon2333/OwnTools/blob/main/Images/XCSourceEditorCommandDefinitions.png)

#### 实现命令功能
在`SourceEditorCommand`文件中，通过填写方法的主体，将可自定义的行为添加到您的源代码编辑器扩展。以下示例显示了一个反转源代码编辑器中的行顺序的命令：`performCommandWithInvocation:completionHandler:`
```
class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Retrieve the contents of the current source editor.
        let lines = invocation.buffer.lines
        // Reverse the order of the lines in a copy.
        let updatedText = Array(lines.reversed())
        lines.removeAllObjects()
        lines.addObjects(from: updatedText)
        // Signal to Xcode that the command has completed.
        completionHandler(nil)
    }
}
```


## 测试您的源代码编辑器扩展
源代码编辑器扩展在单独的 Xcode 中运行，以帮助防止正在进行的扩展中的错误干扰您的开发环境。

### 测试源代码编辑器扩展
选择扩展方案后，通过运行`extension`来测试您正在开发的源代码编辑器扩展。将出现一个对话框，要求您选择要运行的应用程序。
![Run Xcode](https://github.com/Talon2333/OwnTools/blob/main/Images/Run%20Xcode.jpg)
选择 Xcode，您的源代码编辑器扩展在 Xcode 的第二个实例中初始化。您可以根据应用程序图标的背景颜色来区分 Xcode 的两个实例。运行源代码编辑器扩展的 Xcode 实例具有黑色背景，而不是第一个实例的浅蓝色背景。
![Xcode](https://github.com/Talon2333/OwnTools/blob/main/Images/Xcode.jpg)
要测试您的扩展定义的命令，请在 Xcode 的测试实例中打开一个源文件。扩展程序定义的所有命令都出现在`Editor`中，嵌套在扩展程序的名称下，如下图：
![OwnToolsExtension](https://github.com/Talon2333/OwnTools/blob/main/Images/OwnToolsExtension.png)

选择一个命令后，SourceEditorCommand类中的`performCommandWithInvocation:completionHandler:`方法将会被调用。通过参数`XCSourceEditorCommandInvocation`中的`commandIdentifier`来区分不用的命令。

当您测试您的源代码编辑器扩展时，Xcode的原始实例会继续运行。您可以使用它来调试或查看您正在测试的扩展的控制台输出。

## 踩坑
#### 1.运行黑色Xcode后，Editor下没有出现定义的命令
首先确认info文件中的命令配置无误后，可尝试把XcodeKit.framework删除后重新导入。
![XcodeKit](https://github.com/Talon2333/OwnTools/blob/main/Images/XcodeKit.png)

然后再确认下设置扩展中，您的应用程序是否选中`Xcode Source Editor`
![Setting](https://github.com/Talon2333/OwnTools/blob/main/Images/Setting.png)


## 实战——实现自定义Getter生成工具
### 使用流程
选中属性后，点击`Editor`下配置的`Getter`生成命令（可配置快捷键），便可自动生成对应的`Getter`方法，生成的`Getter`方法模版可自定义。

![CustomGetter1](https://github.com/Talon2333/OwnTools/blob/main/Images/CustomGetter1.png)|
![CustomGetter2](https://github.com/Talon2333/OwnTools/blob/main/Images/CustomGetter2.png)|
![CustomGetter3](https://github.com/Talon2333/OwnTools/blob/main/Images/CustomGetter3.png)
---|---|---

### 自定义Getter介绍
将对应类的`Getter`模版拷贝到上方的输入框中，点击`添加`按钮即可添加。当类已添加时，会覆盖模版。
![OwnTools](https://github.com/Talon2333/OwnTools/blob/main/Images/OwnTools.png)

### 实现大致流程
* 获取到选中的行，然后遍历处理每一行
* 尝试获取行中属性的`类名`和`属性名`，获取失败则`continue`
* 根据获取的`类名`找到对应的`Getter`方法模版
* 替换模版中的`类名`和`属性名`

源码已上传Github，[OwnTools](https://github.com/Talon2333/OwnTools)。

## 最后
### 参考文章
苹果官方文档 [XcodeKit](https://developer.apple.com/documentation/xcodekit?language=objc)
[Xcode Source Editor Extension 创建入门](https://www.jianshu.com/p/8c7ca1a35574)
[Xcode - Source Editor Extension](https://juejin.cn/post/6915295119700656141)
[给自己的Xcode写个自动生成代码小插件](https://www.jianshu.com/p/06f495aaf973)
