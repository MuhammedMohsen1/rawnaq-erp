#include "flutter_window.h"

#include <commctrl.h>
#include <optional>

#include "flutter/generated_plugin_registrant.h"
#include <flutter/standard_method_codec.h>

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

LRESULT CALLBACK FlutterWindow::FlutterViewSubclassProc(
    HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam, UINT_PTR subclass_id,
    DWORD_PTR ref_data) {
  auto* window = reinterpret_cast<FlutterWindow*>(ref_data);
  if (window) {
    window->TrackNativeZoomModifier(message, wparam);
  }
  if (window && window->HandleNativeZoomWheel(message, wparam)) {
    return 0;
  }
  return DefSubclassProc(hwnd, message, wparam, lparam);
}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  zoom_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), "rawnaq/gantt_zoom",
          &flutter::StandardMethodCodec::GetInstance());
  RegisterPlugins(flutter_controller_->engine());
  flutter_view_window_ = flutter_controller_->view()->GetNativeWindow();
  SetChildContent(flutter_view_window_);
  SetWindowSubclass(flutter_view_window_, FlutterViewSubclassProc, 1,
                    reinterpret_cast<DWORD_PTR>(this));

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_view_window_) {
    RemoveWindowSubclass(flutter_view_window_, FlutterViewSubclassProc, 1);
    flutter_view_window_ = nullptr;
  }
  zoom_channel_ = nullptr;
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    TrackNativeZoomModifier(message, wparam);
    if (HandleNativeZoomWheel(message, wparam)) {
      return 0;
    }

    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

bool FlutterWindow::HandleNativeZoomWheel(UINT message, WPARAM wparam) {
  if (message != WM_MOUSEWHEEL && message != WM_MOUSEHWHEEL) {
    return false;
  }

  const bool control_pressed =
      native_control_held_ ||
      (::GetKeyState(VK_CONTROL) & 0x8000) != 0 ||
      (::GetAsyncKeyState(VK_CONTROL) & 0x8000) != 0;
  if (!control_pressed) {
    return false;
  }
  SetNativeControlHeld(true);

  const auto wheel_delta = static_cast<double>(GET_WHEEL_DELTA_WPARAM(wparam));
  if (wheel_delta == 0 || !zoom_channel_) {
    return true;
  }

  flutter::EncodableMap arguments;
  arguments[flutter::EncodableValue("delta")] =
      flutter::EncodableValue(wheel_delta);
  arguments[flutter::EncodableValue("controlPressed")] =
      flutter::EncodableValue(true);
  zoom_channel_->InvokeMethod(
      "commandScroll", std::make_unique<flutter::EncodableValue>(arguments));
  return true;
}

void FlutterWindow::TrackNativeZoomModifier(UINT message, WPARAM wparam) {
  if (message == WM_KILLFOCUS || message == WM_CANCELMODE) {
    SetNativeControlHeld(false);
    return;
  }

  const bool is_control_key =
      wparam == VK_CONTROL || wparam == VK_LCONTROL || wparam == VK_RCONTROL;
  if (!is_control_key) {
    return;
  }

  if (message == WM_KEYDOWN || message == WM_SYSKEYDOWN) {
    SetNativeControlHeld(true);
    return;
  }

  if (message == WM_KEYUP || message == WM_SYSKEYUP) {
    const bool control_still_pressed =
        (::GetKeyState(VK_CONTROL) & 0x8000) != 0 ||
        (::GetAsyncKeyState(VK_CONTROL) & 0x8000) != 0;
    SetNativeControlHeld(control_still_pressed);
  }
}

void FlutterWindow::SetNativeControlHeld(bool is_held) {
  if (native_control_held_ == is_held) {
    return;
  }
  native_control_held_ = is_held;

  if (!zoom_channel_) {
    return;
  }

  flutter::EncodableMap arguments;
  arguments[flutter::EncodableValue("controlPressed")] =
      flutter::EncodableValue(is_held);
  zoom_channel_->InvokeMethod(
      "modifierChanged", std::make_unique<flutter::EncodableValue>(arguments));
}
