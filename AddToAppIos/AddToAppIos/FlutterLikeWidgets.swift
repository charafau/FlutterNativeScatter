//
//  Scatter.swift
//  AddToAppIos
//
//  Created by Rafal Wachol on 2025/12/12.
//


import UIKit
import FlexLayout
import PinLayout

// In a Flutter-like system, everything is a Widget. Here, every Widget wraps a UIView.
public class FlexWidget: NSObject {
    public let view: UIView
    
    init(view: UIView) {
        self.view = view
    }
}


// Handles Padding, Size, Color, and a single Child
public class ContainerWidget: FlexWidget {
    public init() {
        super.init(view: UIView())
    }
    
    // Builder methods for configuration
    public func setPadding(_ value: CGFloat) -> ContainerWidget {
        view.flex.padding(value)
        return self
    }
    
    public func setSize(width: CGFloat?, height: CGFloat?) -> ContainerWidget {
        if let w = width { view.flex.width(w) }
        if let h = height { view.flex.height(h) }
        return self
    }
    
    public func setColor(r: CGFloat, g: CGFloat, b: CGFloat) -> ContainerWidget {
        view.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        return self
    }
    
    // Composition: Accepts a single child
    public func setChild(_ child: FlexWidget) -> ContainerWidget {
        // FlexLayout requires adding the subview, then defining the item
        view.addSubview(child.view)
        child.view.flex.markDirty() // Ensure layout update
        
        // Define the layout for this container
        view.flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(child.view)
        }
        return self
    }
}

// Handles Multi-child layouts (Column/Row)
public class LinearWidget: FlexWidget {
    private let direction: Flex.Direction
    
    public init(direction: Flex.Direction) {
        self.direction = direction
        super.init(view: UIView())
    }
    
    // Composition: Accepts multiple children
    public func addChildren(_ children: [FlexWidget]) {
        children.forEach { view.addSubview($0.view) }
        
        view.flex.direction(direction).padding(10).define { flex in
            for child in children {
                // Add item with some default spacing between elements
                flex.addItem(child.view).marginBottom(10)
            }
        }
    }
}

// Special "Card" Widget (Composition of Container + Styling)
public class CardWidget: ContainerWidget {
    public override init() {
        super.init()
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.backgroundColor = .white
    }
}

// MARK: - 3. Leaf Widgets (Content)

public class TextWidget: FlexWidget {
    public init(_ text: String) {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        super.init(view: label)
    }
}

public class ButtonWidget: FlexWidget {
    private var onClick: (() -> Void)?
    
    public init(text: String) {
        let btn = UIButton(type: .system)
        btn.setTitle(text, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        // intrinsic content size handles dimensions
        super.init(view: btn)
        // Give button specific sizing constraints in flex
        self.view.flex.height(44).paddingHorizontal(20)
        
        btn.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    @objc func handleTap() {
        onClick?()
    }
    
    func setOnClick(_ callback: @escaping () -> Void) {
        self.onClick = callback
    }
}

public class ImageWidget: FlexWidget {
    public init(systemName: String) {
        let imgView = UIImageView(image: UIImage(systemName: systemName))
        imgView.contentMode = .scaleAspectFit
        super.init(view: imgView)
        self.view.flex.size(50) // Default size
    }
}

public class SwitchWidget: FlexWidget {
    public init() {
        let toggle = UISwitch()
        super.init(view: toggle)
    }
}

// MARK: - 4. C-Bindings
// We expose these classes via opaque pointers (void*)

// --- Constructors ---

@_cdecl("create_text")
public func create_text(_ text: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    let str = String(cString: text)
    return Unmanaged.passRetained(TextWidget(str)).toOpaque()
}

@_cdecl("create_button")
public func create_button(_ text: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    let str = String(cString: text)
    return Unmanaged.passRetained(ButtonWidget(text: str)).toOpaque()
}

@_cdecl("create_image")
public func create_image(_ name: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    let str = String(cString: name)
    return Unmanaged.passRetained(ImageWidget(systemName: str)).toOpaque()
}

@_cdecl("create_switch")
public func create_switch() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(SwitchWidget()).toOpaque()
}

@_cdecl("create_container")
public func create_container() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(ContainerWidget()).toOpaque()
}

@_cdecl("create_card")
public func create_card() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(CardWidget()).toOpaque()
}

@_cdecl("create_column")
public func create_column() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(LinearWidget(direction: .column)).toOpaque()
}

@_cdecl("create_row")
public func create_row() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(LinearWidget(direction: .row)).toOpaque()
}

// --- Modifiers / Composition ---

@_cdecl("widget_set_padding")
public func widget_set_padding(_ ptr: UnsafeMutableRawPointer, _ value: Float) {
    let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
    widget.view.flex.padding(CGFloat(value))
}

@_cdecl("widget_set_margin")
public func widget_set_margin(_ ptr: UnsafeMutableRawPointer, _ value: Float) {
    let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
    widget.view.flex.margin(CGFloat(value))
}

@_cdecl("widget_set_size")
public func widget_set_size(_ ptr: UnsafeMutableRawPointer, width: Float, height: Float) {
    let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
    if width > 0 { widget.view.flex.width(CGFloat(width)) }
    if height > 0 { widget.view.flex.height(CGFloat(height)) }
}

@_cdecl("widget_set_background_color")
public func widget_set_background_color(_ ptr: UnsafeMutableRawPointer, r: Float, g: Float, b: Float, a: Float) {
    let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
    widget.view.backgroundColor = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
}

@_cdecl("widget_set_corner_radius")
public func widget_set_corner_radius(_ ptr: UnsafeMutableRawPointer, radius: Float) {
    let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
    widget.view.layer.cornerRadius = CGFloat(radius)
    widget.view.clipsToBounds = true
}

@_cdecl("widget_set_flex_grow")
public func widget_set_flex_grow(_ ptr: UnsafeMutableRawPointer, _ value: Float) {
    let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
    widget.view.flex.grow(CGFloat(value))
}

@_cdecl("widget_set_on_click")
public func widget_set_on_click(_ ptr: UnsafeMutableRawPointer, _ callback: @convention(c) @escaping () -> Void) {
    let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
    if let btn = widget as? ButtonWidget {
        btn.setOnClick {
            callback()
        }
    }
}

@_cdecl("widget_log")
public func widget_log(_ message: UnsafePointer<CChar>) {
    NSLog("NATIVE_LOG: \(String(cString: message))")
}


@_cdecl("container_set_child")
public func container_set_child(_ containerPtr: UnsafeMutableRawPointer, _ childPtr: UnsafeMutableRawPointer) {
    let container = Unmanaged<ContainerWidget>.fromOpaque(containerPtr).takeUnretainedValue()
    // We take retained value of child because container will now own it essentially
    // (In a full system, you need careful memory management here.
    // For simplicity: C creates, C passes ownership to Parent).
    let child = Unmanaged<FlexWidget>.fromOpaque(childPtr).takeUnretainedValue()
    
    _ = container.setChild(child)
}

@_cdecl("linear_add_child")
public func linear_add_child(_ parentPtr: UnsafeMutableRawPointer, _ childPtr: UnsafeMutableRawPointer) {
    let parent = Unmanaged<LinearWidget>.fromOpaque(parentPtr).takeUnretainedValue()
    let child = Unmanaged<FlexWidget>.fromOpaque(childPtr).takeUnretainedValue()
    parent.addChildren([child])
}

// --- Layout Helper ---
// Since FlexLayout needs a manual layout call on the root
@_cdecl("widget_layout_root")
public func widget_layout_root(_ ptr: UnsafeMutableRawPointer, width: Float, height: Float) {
    let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
    widget.view.pin.width(CGFloat(width)).height(CGFloat(height))
    widget.view.flex.layout(mode: .adjustHeight)
}

// MARK: - 5. View Retrieval Binding

@_cdecl("get_ui_view_from_widget")
// Returns the raw pointer to the underlying UIView of the widget.
// The returned view is RETAINED, meaning the caller (C/Dart) MUST call
// release_object_handle() on it later if it's not added to a managed UI hierarchy.
public func get_ui_view_from_widget(_ ptr: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
    // 1. Get the FlexWidget object
    let widget = Unmanaged<FlexWidget>.fromOpaque(ptr).takeUnretainedValue()
    
    // 2. Get the underlying UIView
    let uiView = widget.view
    
    // 3. Increment the reference count and return the opaque pointer to the UIView
    // This passes ownership of the UIView reference to the C/Dart layer.
    return Unmanaged.passRetained(uiView).toOpaque()
}

@_cdecl("widget_release")
public func widget_release(_ ptr: UnsafeMutableRawPointer) {
    // Take ownership back from C/Dart and let it fall out of scope to deallocate
    Unmanaged<FlexWidget>.fromOpaque(ptr).release()
}
