# Gap Buffer

This is a pure Janet module for using a gap buffer data structure in your code.

# Getting Started

Interface consists of 8 methods:
```lisp
(new-buffer buf-size)          ;; create a new buffer table
(insert-char buffer character) ;; insert a character into the buffer under the cursor moving the cursor one space to the left
(insert-string buffer string)  ;; same as insert-char, but with a string
(cursor-left buffer)           ;; move cursor left
(cursor-right buffer)          ;; move cursor right
(delete-left buffer)           ;; delete character to the left of the cursor, backspace
(delete-right buffer)          ;; delete character to the right of the cursor, delete
(extract-text buffer)          ;; remove gap buffer and return the whole string
```
