//
//  SwiftBridge.swift
//  AddToAppIos
//
//  Created by Rafal Wachol on 2025/12/12.
//

import Foundation
import UIKit
import Flutter

@_cdecl("add_numbers")
public func addNumbers(a: Int32, b: Int32) -> Int32 {
    
    print("adding numbers ", a + b)
    
    return a + b
}

// Replace the existing content of the FFI Entry Point
@_cdecl("display_widget_in_view_controller")
public func display_widget_in_view_controller(_ viewHandleAddress: Int) {
    // 1. Find the current active view controller using the robust method
    guard let topVC = ViewController.uiViewController else {
        print("FFI Display Error: Robust search failed to find the top view controller.")
        return
    }

    // 2. Execute the display logic on the main thread
    DispatchQueue.main.async {
        // Use the found top-most VC
        topVC.displayWidgetFromHandle(viewHandleAddress: viewHandleAddress, in: topVC.view)
    }
}

// --- Display Logic (Reusable Extension) ---

extension UIViewController {
    /**
     * Converts a raw memory address (handle) into a UIView instance and adds it to the container.
     */
    func displayWidgetFromHandle(viewHandleAddress: Int, in containerView: UIView) {
        guard viewHandleAddress != 0 else {
            print("Display Logic Error: Received zero or invalid view handle address.")
            return
        }

        let ptr = UnsafeMutableRawPointer(bitPattern: viewHandleAddress)
        
        guard let viewPtr = ptr else {
            print("Display Logic Error: Could not create raw pointer from address.")
            return
        }

        // UNWIND: .takeRetainedValue() is essential to balance the .passRetained()
        // from the Dart side (get_ui_view_from_widget), transferring ownership
        // back to ARC since the view is now in the UIKit hierarchy.
        let nativeWidgetView = Unmanaged<UIView>.fromOpaque(viewPtr).takeRetainedValue()

        // Cleanup any previous native views (optional, good practice)
        containerView.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
        
        containerView.addSubview(nativeWidgetView)
        nativeWidgetView.tag = 999

        // Constraints
        nativeWidgetView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nativeWidgetView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nativeWidgetView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            nativeWidgetView.topAnchor.constraint(equalTo: containerView.topAnchor),
            nativeWidgetView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
}
// Add this extension method to your Swift file (e.g., ViewControllerFFIBridge.swift)
extension UIViewController {
    // THE MOST ROBUST WAY TO FIND THE KEY WINDOW AND TOP VC
        static func topMostViewController() -> UIViewController? {
            // 1. Find the Key Window (iOS 13+ safe way)
            var keyWindow: UIWindow?
            
            if #available(iOS 13.0, *) {
                // Scene-based approach for modern iOS
                keyWindow = UIApplication.shared.connectedScenes
                    .filter { $0.activationState == .foregroundActive }
                    .map { $0 as? UIWindowScene }
                    .compactMap { $0?.windows }
                    .flatMap { $0 }
                    .first { $0.isKeyWindow }
            } else {
                // Legacy approach
                keyWindow = UIApplication.shared.keyWindow
            }
            
            guard let window = keyWindow, let rootController = window.rootViewController else {
                // If we can't get the window or root controller, we return nil
                return nil
            }
            
            // 2. Traverse the hierarchy from the determined root
            var topController = rootController
            
            // Traverse presented views
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            // Handle containers
            if let nav = topController as? UINavigationController {
                topController = nav.visibleViewController ?? topController
            }
            if let tab = topController as? UITabBarController {
                topController = tab.selectedViewController ?? topController
            }
            
            return topController
        }
}

