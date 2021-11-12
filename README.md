# Gap Buffer

This is a pure Janet module for using a gap buffer data structure in your code.

# Getting Started

Interface consists of:

```lisp
(new-buffer buf-size)          ;; create a new buffer table
(insert-char buffer character) ;; insert a character into the buffer under the cursor moving the cursor one space to the right
(insert-string buffer string)  ;; same as insert-char, but with a string
(cursor-left buffer)           ;; move cursor left
(cursor-right buffer)          ;; move cursor right
(move-cursor-to :token & num)  ;; move cursor to :index, :begin, or :end of text
(delete-left buffer)           ;; delete character to the left of the cursor, backspace
(delete-right buffer)          ;; delete character to the right of the cursor, delete
(extract-text buffer)          ;; remove gap buffer and return the whole string
(buffer-front buffer)          ;; returns size before the gap
(buffer-back buffer)           ;; returns size after the gap
(buffer-used buffer)           ;; how much is in the gab buffer
```
