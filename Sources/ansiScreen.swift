public private(set) var isReplacingMode = false
public private(set) var isCursorVisible = true

// Reference: https://invisible-island.net/xterm/ctlseqs/ctlseqs.html


public enum CursorStyle: UInt8 {
  case block = 1
  case line  = 3
  case bar   = 5
}

/// Changes the cursor displayed in the terminal.
/// - Parameter style: The style to use for the cursor.
/// - Parameter blinking: True if the cursor should blink, defaults to `true`.
public func setCursorStyle(_ style: CursorStyle, blinking: Bool = true) {
  if blinking { write(CSI+"\(style.rawValue) q") }
    else { write(CSI+"\(style.rawValue + 1) q") }
}

#if os(macOS)
/// Stores the current cursor position (macOS only)
///
/// The macOS implementation defaults to non ANSI codes.
///
/// - Parameter isANSI: A boolean describing if the the terminal is ANSI, defaults to `false`.
public func storeCursorPosition(isANSI: Bool = false) {
  if isANSI { write(CSI,"s") } else { write(ESC,"7") }
}
#else
/// Stores the current cursor position (non-macOS)
///
/// The non-macOS implementation defaults to ANSI codes.
///
/// - Parameter isANSI: A boolean describing if the the terminal is ANSI, defaults to `true`.
public func storeCursorPosition(isANSI: Bool = true) {
  if isANSI { write(CSI,"s") } else { write(ESC,"7") }
}
#endif

#if os(macOS)
/// Restores the last cursor position saved with ``storeCursorPosition(isANSI:)`` (macOS only)
///
/// The macOS implementation defaults to non ANSI codes.
/// On some terminals this function has a side effect to also reset color and style to default.
///
/// - Parameter isANSI: A boolean describing if the the terminal is ANSI, defaults to `false`.
public func restoreCursorPosition(isANSI: Bool = false) {
  if isANSI { write(CSI,"u") } else { write(ESC,"8") }
}
#else
/// Restores the last cursor position saved with ``storeCursorPosition(isANSI:)`` (non-macOS)
///
/// The non-macOS implementation defaults to ANSI codes.
/// On some terminals this function has a side effect to also reset color and style to default.
///
/// - Parameter isANSI: A boolean describing if the the terminal is ANSI, defaults to `true`.
public func restoreCursorPosition(isANSI: Bool = true) {
  if isANSI { write(CSI,"u") } else { write(ESC,"8") }
}
#endif

/// Clears text from cursor to end of the screen
public func clearBelow() {
  write(CSI,"0J")
}

/// Clears text from cursor to start of the screen
public func clearAbove() {
  write(CSI,"1J")
}

/// Clears all text on screen and places cursor to position 1,1 (left corner)
public func clearScreen() {
  write(CSI,"2J",CSI,"H")
}

/// Clears from cursor to end of line.
public func clearToEndOfLine() {
  write(CSI,"0K")
}

/// Clears from cursor to start of line.
public func clearToStartOfLine() {
  write(CSI,"1K")
}

/// Clears line.
public func clearLine() {
  write(CSI,"2K")
}

/// Moves cursor up `row` rows.
///
/// If the cursor is already at the edge of the screen, nothing happens.
///
/// - Parameter row: The number of rows to move up by. Defaults to `1`.
public func moveUp(_ row: Int = 1) {
  write(CSI,"\(row)A")
}

/// Moves cursor down `row` rows.
///
/// If the cursor is already at the edge of the screen, nothing happens.
///
/// - Parameter row: The number of rows to move down by. Defaults to `1`.
public func moveDown(_ row: Int = 1) {
  write(CSI,"\(row)B")
}

/// Moves cursor right `col` columns.
///
/// If the cursor is already at the edge of the screen, nothing happens.
///
/// - Parameter col: The number of columns to move right by. Defaults to `1`.
public func moveRight(_ col: Int = 1) {
  write(CSI,"\(col)C")
}

/// Moves cursor left `col` columns.
///
/// If the cursor is already at the edge of the screen, nothing happens.
///
/// - Parameter col: The number of columns to move left by. Defaults to `1`.
public func moveLeft(_ col: Int = 1) {
  write(CSI,"\(col)D")
}

/// Moves cursor down `row` lines.
/// - Parameter row: The number of lines to move down by. Defaults to `1`.
public func moveLineDown(_ row: Int = 1) {
  write(CSI,"\(row)E")
}

/// Moves cursor up `row` lines.
/// - Parameter row: The number of lines to move up by. Defaults to `1`.
public func moveLineUp(_ row: Int = 1) {
  write(CSI,"\(row)F")
}

/// Moves cursor to column `col`.
/// - Parameter col: The column to move to.
public func moveToColumn(_ col: Int) {
  write(CSI,"\(col)G")
}

/// Moves cursor to position `row`x`col`.
/// - Parameter row: The row to move to.
/// - Parameter col: The column to move to.
public func moveTo(_ row: Int, _ col: Int) {
  write(CSI,"\(row);\(col)H")
}

/// Inserts a line.
///
/// Description missing
/// - Parameter row: The row to insert the line at. Defaults to `1`.
public func insertLine(_ row: Int = 1) {
  write(CSI,"\(row)L")
}

/// Deletes a line.
///
/// Description missing
/// - Parameter row: The row to delete the line at. Defaults to `1`.
public func deleteLine(_ row: Int = 1) {
  write(CSI,"\(row)M")
}

/// Deletes a character.
///
/// Description missing
/// - Parameter char: The char to delete. Defaults to `1`.
public func deleteChar(_ char: Int = 1) {
  write(CSI,"\(char)P")
}

public func enableReplaceMode() {
  write(CSI,"4l")
  isReplacingMode = true
}

public func disableReplaceMode() {
  write(CSI,"4h")
  isReplacingMode = false
}

public func cursorOff() {
  write(CSI,"?25l")
  isCursorVisible = false
}

public func cursorOn() {
  write(CSI,"?25h")
  isCursorVisible = true
}

public func scrollRegion(top: Int, bottom: Int) {
  write(CSI,"\(top);\(bottom)r")
}

public func readCursorPos() -> (row: Int, col: Int) {
  let str = ansiRequest(CSI+"6n", endChar: "R")  // returns ^[row;colR
  if str.isEmpty { return (-1, -1) }

  let esc = str.firstIndex(of: "[")!
  let del = str.firstIndex(of: ";")!
  let end = str.firstIndex(of: "R")!
  let row = String(str[str.index(after: esc)...str.index(before: del)])
  let col = String(str[str.index(after: del)...str.index(before: end)])

  return (Int(row)!, Int(col)!)
}

//! WARNING: 18t only works on a real terminal console, *not* on emulation.
public func readScreenSize() -> (row: Int, col: Int) {
  var str = ansiRequest(CSI+"18t", endChar: "t")  // returns ^[8;row;colt
  if str.isEmpty { return (-1, -1) }

  str = String(str.dropFirst(4))  // remove ^[8;
  let del = str.firstIndex(of: ";")!
  let end = str.firstIndex(of: "t")!
  let row = String(str[...str.index(before: del)])
  let col = String(str[str.index(after: del)...str.index(before: end)])

  return (Int(row)!, Int(col)!)
}
