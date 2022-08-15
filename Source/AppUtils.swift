//
//  MIT License
//
//  Copyright (c) 2022 Daniel
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  WindowManagerDemo
//
//  Created by Daniel.Hu on 2022/8/15.
//
//  NOTE:
//  U R NEVER WRONG TO DO THE RIGHT THING.
//
//  Copyright (c) 2022 Daniel.Hu. All rights reserved.
//
    

import Foundation
import AppKit

struct AppUtils {
    /// 创建新的文档
    static func openNewDocument() {
        NSDocumentController.shared.newDocument(nil)
    }
    
    /// 打开设置
    static func openSettings() {
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
    }
    
    /// 打开scheme跳转指定页面
    static func open(_ scheme: String = "windowManagerDemo", target: String) {
        open("\(scheme)://\(target)")
    }
    
    
    /// 打开目标地址
    static func open(_ string: String) {
        guard let url = URL(string: string) else { return }
        open(url)
    }
    
    /// 打开目标链接
    /// - warning: 可能打印错误 [open] LAUNCH: Launch failure with -10652... 但不影响大局
    static func open(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
}
