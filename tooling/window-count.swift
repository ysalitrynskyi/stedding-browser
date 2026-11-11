// The processes that own the most windows in this login session (macOS), most first.
// Built and run by tooling/window-count --owners. Window titles need Screen Recording;
// owner names and counts do not, so nothing here asks for it.
//
//   window-count-owners [N]    "listed<TAB>total", then N lines of "count<TAB>name<TAB>pid"

import CoreGraphics
import Foundation

let limit = CommandLine.arguments.count > 1 ? Int(CommandLine.arguments[1]) ?? 10 : 10
let windows = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]] ?? []

var counts: [String: Int] = [:]
for window in windows {
  let name = window[kCGWindowOwnerName as String] as? String ?? "?"
  let pid = window[kCGWindowOwnerPID as String] as? Int ?? 0
  counts["\(name)\t\(pid)", default: 0] += 1
}

print("listed\t\(windows.count)")
for (owner, count) in counts.sorted(by: { $0.value > $1.value }).prefix(limit) {
  print("\(count)\t\(owner)")
}
