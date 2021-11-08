# Gap Buffer

This is a pure Janet module for using a gap buffer data structure in your code.

# Getting Started

Interface consists of 7 methods:
```lisp
(new-buffer buf-size)          ;; create a new buffer table
(insert-char buffer character) ;; insert a character into the buffer under the cursor moving the cursor one space to the left
(cursor-left buffer)           ;; move cursor back
(cursor-right buffer)          ;; move cursor formard
(delete-left buffer)           ;; delete character to the right of the cursor, backspace
(delete-right buffer)          ;; delete character to the left of the cursor, delete
(extract-text buffer)          ;; remove gap buffer and return the whole string
```
