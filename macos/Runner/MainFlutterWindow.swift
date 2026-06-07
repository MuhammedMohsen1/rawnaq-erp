import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var flagsChangedMonitor: Any?
  private var commandScrollMonitor: Any?
  private var isCommandHeld = false

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    let zoomChannel = FlutterMethodChannel(
      name: "rawnaq/gantt_zoom",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    flagsChangedMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
      let commandPressed = event.modifierFlags
        .intersection(.deviceIndependentFlagsMask)
        .contains(.command)
      self?.isCommandHeld = commandPressed
      zoomChannel.invokeMethod("modifierChanged", arguments: [
        "commandPressed": commandPressed
      ])
      return event
    }

    commandScrollMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [weak self] event in
      let eventCommandPressed = event.modifierFlags
        .intersection(.deviceIndependentFlagsMask)
        .contains(.command)
      let currentCommandPressed = NSEvent.modifierFlags
        .intersection(.deviceIndependentFlagsMask)
        .contains(.command)
      let sessionCommandPressed = CGEventSource
        .flagsState(.combinedSessionState)
        .contains(.maskCommand)
      let commandPressed = eventCommandPressed ||
        currentCommandPressed ||
        sessionCommandPressed ||
        (self?.isCommandHeld ?? false)
      guard commandPressed else {
        return event
      }

      let scrollDelta = event.scrollingDeltaY != 0
        ? event.scrollingDeltaY
        : event.scrollingDeltaX
      guard scrollDelta != 0 else {
        return event
      }

      zoomChannel.invokeMethod("commandScroll", arguments: [
        "delta": scrollDelta,
        "commandPressed": commandPressed
      ])
      return nil
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  deinit {
    if let flagsChangedMonitor = flagsChangedMonitor {
      NSEvent.removeMonitor(flagsChangedMonitor)
    }
    if let commandScrollMonitor = commandScrollMonitor {
      NSEvent.removeMonitor(commandScrollMonitor)
    }
  }
}
