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
import SwiftUI


public class WindowUtil: NSObject, ObservableObject {
    typealias Window = NSWindow
    
    /// 私有初始化方法
    private override init() {}
    private static let shared = WindowUtil()
    
    /// 窗口缓存池 view name : Window
    private var windows: [String: Window] = [:]
    
    
    /// 视图类型
    public enum ViewType: String {
        /// 默认类型
        case `default`
        /// 设置页面
        case setting
        /// 文档页面
        case document
    }
}


// MARK: - NSWindowDelegate窗口代理
extension WindowUtil: NSWindowDelegate {
    public func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? Window else { return }
        remove(window)
    }
    
    public func windowDidBecomeKey(_ notification: Notification) {
        // do something...
    }
}


// MARK: - Public
extension WindowUtil {
    /// 通过视图创建window
    ///
    /// - Parameters:
    ///   - view: 视图
    ///   - allowMultiple: 是否可多开
    ///   - size: 窗口尺寸
    ///   - styleMask: 窗口样式
    ///
    /// - attention: 使用此方式创建的window，swiftui关于导航栏的设置代码将失效
    public class func makeWindow<T>(_ view: T,
                                    allowMultiple: Bool = false,
                                    title: String? = nil,
                                    size: NSSize = NSSize(width: 800, height: 600),
                                    styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]) where T: View {
        WindowUtil.shared.makeWindow(view, allowMultiple: allowMultiple, title: title, size: size, styleMask: styleMask)
    }
    
    /// 通过视图类型创建视图
    ///
    /// - Parameters:
    ///   - view: 视图类
    ///   - viewType: 视图类型
    ///
    /// - attention: 使用此方式创建的window，必须在包含在WIndowGroup下使用handlesExternal标记
    public class func makeWindow<T>(_ view: T.Type = T.self,
                             viewType: ViewType = .default) where T: View {
        WindowUtil.shared.makeWindow(view, viewType: viewType)
    }
}

extension WindowUtil {
    /// 添加window进行管理
    class func appendWindow<T>(_ window: Window, view: T.Type) where T: View {
        WindowUtil.shared.append(window, view: view)
    }
}


// MARK: - 视图创建窗口
extension WindowUtil {
    /// 视图构建Window并响应
    private func makeWindow<T>(_ view: T,
                               allowMultiple: Bool,
                               title: String?,
                               size: NSSize,
                               styleMask: NSWindow.StyleMask) where T: View {
        // 代码创建窗口
        let windowRef = window(view, allowMultiple: allowMultiple, title: title, size: size, styleMask: styleMask)
        
        guard !windowRef.isKeyWindow else { return }
        windowRef.makeKeyAndOrderFront(nil)
    }
    
    
    /// 视图构建window策略
    private func window<T>(_ view: T,
                           allowMultiple: Bool,
                           title: String?,
                           size: NSSize,
                           styleMask: NSWindow.StyleMask) -> Window where T: View {
        let identifier = identifier(view.self)
        // 缓存
        if let window = windows[identifier] { return window }
        
        // 手动创建window
        let hosting = NSHostingController(rootView: view)
        /*
         NOTE: 此种方式创建的window会使得一些属性无效，比如 title, toolbar, navigationTitle, frame等。
         大的titlebar样式通过 windowRef.toolbar = NSToolbar() 创建，但是设置也必须在此设置，在swiftui中的设置无效
         */
        let windowRef = NSWindow(contentViewController: hosting)
        windowRef.titlebarSeparatorStyle = .shadow
        windowRef.styleMask = styleMask
        windowRef.titlebarAppearsTransparent = true
        windowRef.setContentSize(size)
        windowRef.center()
        
        if let title = title { windowRef.title = title }
        if !allowMultiple { append(windowRef, identifier: identifier) }
        
        return windowRef
    }
}


// MARK: - 标识与定义打开窗口
extension WindowUtil {
    /// 通过表示标识与定义打开窗口
    private func makeWindow<T>(_ view: T.Type?, viewType: ViewType) where T: View {
        if let windowRef = window(view) {
            guard !windowRef.isKeyWindow else { return }
            windowRef.makeKeyAndOrderFront(nil)
            return
        }
        
        switch viewType {
        case .setting: AppUtils.openSettings()
        case .document: AppUtils.openNewDocument()
        default:
            guard let view = view else { return }
            
            let identifier = identifier(view.self)
            AppUtils.open(target: identifier)
        }
    }
    
    private func window<T>(_ view: T.Type?) -> Window? where T: View {
        guard let view = view else { return nil }
        return windows[identifier(view.self)]
    }
}


// MARK: - Window的增删查
extension WindowUtil {
    /// 添加缓存
    private func append<T>(_ window: Window, view: T.Type = T.self) where T: View {
        let identifier = identifier(view.self)
        window.delegate = self
        windows[identifier] = window
    }
    
    /// 添加缓存
    private func append(_ window: Window, identifier: String) {
        window.delegate = self
        windows[identifier] = window
    }
    
    /// 移除缓存
    private func remove(_ window: Window) {
        guard let index = windows.firstIndex (where: { window == $0.value }) else { return }
        windows.remove(at: index)
        window.close()
    }
    
    /// 标识转化 Any -> String
    private func identifier(_ value: Any) -> String {
        String(describing: type(of: value))
    }
}


// MARK: - View Extension
extension WindowUtil {
    /// 当视图需要对window进行管理（关闭等操作）时，则需要通过此方法异步获取该视图的window
    struct HostingWindowView: NSViewRepresentable {
        let callback: (Window?) -> ()
        
        func makeNSView(context: Context) -> some NSView {
            let view = NSView()
            
            DispatchQueue.main.async { [weak view] in
                self.callback(view?.window)
            }
            return view
        }
        
        func updateNSView(_ nsView: NSViewType, context: Context) {
            // do nothing...
        }
    }
    
    /// 当视图需要对控制器进行管理时，则需要通过此方法异步获取该视图的控制器
    struct HostingWindowViewController: NSViewControllerRepresentable {
        let callback: (NSViewController?) -> ()
        
        func makeNSViewController(context: Context) -> some NSViewController {
            let viewController = NSViewController()
            
            DispatchQueue.main.async { [weak viewController] in
                self.callback(viewController)
            }
            return viewController
        }
        
        func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
            // do nothing...
        }
        
    }
}

extension View {
    /// 定义扩展匹配标识
    /// - attention: 视图名称不可存在包含关系，比如:  `Main`, `MainView`。一旦存在包含关系，在使用open的方式打开`Main`时，有可能打开`MainView`
    static var externalEventsMatching: Set<String> {
        Set(arrayLiteral: String(describing: type(of: self)))
    }
}

extension Scene {
    /// 标识Scene用于链接创建新窗口window
    func handlesExternal<T>(_ view: T.Type) -> some Scene where T: View {
        handlesExternalEvents(matching: view.externalEventsMatching)
    }
}

extension View {
    /// 标识View以防重复创建同一视图
    func handlesExternal(allowing: Set<String> = Set(arrayLiteral: "*")) -> some View {
        handlesExternalEvents(preferring: Self.externalEventsMatching, allowing: allowing)
            .windowModifier()
    }

    /// 对视图简易管理window
    func windowModifier() -> some View {
        modifier(WindowUtil.HostingWindowViewModifier(view: Self.self))
    }

}

extension WindowUtil {
    /// 对视图简易管理window
    struct HostingWindowViewModifier<T>: ViewModifier where T: View {
        let view: T.Type

        func body(content: Content) -> some View {
            ZStack {
                // 初始化界面才需要手动添加管理
                WindowUtil.HostingWindowView { window in
                    guard let window = window else { return }

                    WindowUtil.appendWindow(window, view: view)
                }
                .frame(width: .zero, height: .zero) // 空视图避免影响布局

                content
            }
        }
    }
}



