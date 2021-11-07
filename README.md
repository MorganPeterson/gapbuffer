# Gap Buffer

This is a pure Janet module for using a gap buffer data structure in your code.

# Getting Started

Interface consists of 7 methods:
```lisp
(new-buffer buf-size)          ;; create a new buffer table
(insert-char buffer character) ;; enter a character into the buffer moving the cursor left
(cursor-left buffer)           ;; move cursor left
(cursor-right buffer)          ;; move cursor right
(delete-left buffer)           ;; delete character to the right, backspace
(delete-right buffer)          ;; delete character to the left, delete
(extract-text buffer)          ;; remove gap buffer and return the whole string
```
