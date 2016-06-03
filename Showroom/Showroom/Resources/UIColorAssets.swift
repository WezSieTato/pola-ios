// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import UIKit.UIColor

extension UIColor {
  convenience init(rgbaValue: UInt32) {
    let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
    let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
    let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
    let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}

enum ColorName {
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#000000"></span>
  /// Alpha: 100% <br/> (0x000000ff)
  case Black
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#1e1cbf"></span>
  /// Alpha: 100% <br/> (0x1e1cbfff)
  case Blue
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#a4aab3"></span>
  /// Alpha: 100% <br/> (0xa4aab3ff)
  case DarkGray
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#dddddd"></span>
  /// Alpha: 100% <br/> (0xddddddff)
  case Separator
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#bb1270"></span>
  /// Alpha: 100% <br/> (0xbb1270ff)
  case RedViolet
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  case White

  var rgbaValue: UInt32! {
    switch self {
    case .Black: return 0x000000ff
    case .Blue: return 0x1e1cbfff
    case .DarkGray: return 0xa4aab3ff
    case .Separator: return 0xddddddff
    case .RedViolet: return 0xbb1270ff
    case .White: return 0xffffffff
    }
  }

  var color: UIColor {
    return UIColor(named: self)
  }
}

extension UIColor {
  convenience init(named name: ColorName) {
    self.init(rgbaValue: name.rgbaValue)
  }
}

