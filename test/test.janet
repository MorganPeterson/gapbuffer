(import ../gapbuffer :as g)

(def buf (g/new-buffer 2))

(g/insert-char buf "f")
(g/insert-char buf "o")
(g/insert-char buf "o")

(assert (= (g/buffer-used buf) 3) "buffer used")
(assert (= (- (length (buf :buffer)) (g/buffer-used buf)) 509) "buffer available")
(assert (= (string (g/extract-text buf true)) "foo_"))

(g/cursor-left buf)
(g/insert-char buf "x")

(assert (= (g/buffer-used buf) 4) "buffer used")
(assert (= (- (length (buf :buffer)) (g/buffer-used buf)) 508) "buffer available")
(assert (= (string (g/extract-text buf true)) "fox_o"))

(g/cursor-left buf)
(g/cursor-left buf)
(g/insert-char buf "y")

(assert (= (g/buffer-used buf) 5) "buffer used")
(assert (= (- (length (buf :buffer)) (g/buffer-used buf)) 507) "buffer available")
(assert (= (string (g/extract-text buf true)) "fy_oxo"))

(g/cursor-right buf)
(g/cursor-right buf)
(g/cursor-right buf)
(g/cursor-right buf)
(g/insert-char buf "z")

(assert (= (g/buffer-used buf) 6) "buffer used")
(assert (= (- (length (buf :buffer)) (g/buffer-used buf)) 506) "buffer available")
(assert (= (string (g/extract-text buf true)) "fyoxoz_"))

(g/delete-left buf)

(assert (= (g/buffer-used buf) 5) "buffer used")
(assert (= (- (length (buf :buffer)) (g/buffer-used buf)) 507) "buffer available")
(assert (= (string (g/extract-text buf true)) "fyoxo_"))

(g/cursor-left buf)
(g/cursor-left buf)
(g/delete-right buf)

(assert (= (g/buffer-used buf) 4) "buffer used")
(assert (= (- (length (buf :buffer)) (g/buffer-used buf)) 508) "buffer available")
(assert (= (string (g/extract-text buf true)) "fyo_o"))

(g/cursor-left buf)
(g/insert-char buf "y")

(assert (= (g/buffer-used buf) 5) "buffer used")
(assert (= (- (length (buf :buffer)) (g/buffer-used buf)) 507) "buffer available")
(assert (= (string (g/extract-text buf true)) "fyy_oo"))

(g/insert-string buf "hello, world")

(assert (= (g/buffer-used buf) 17) "buffer used")
(assert (= (- (length (buf :buffer)) (g/buffer-used buf)) 495) "buffer available")
(assert (= (string (g/extract-text buf true)) "fyyhello, world_oo"))

(g/move-cursor-to buf :begin)

(assert (= (g/buffer-used buf) 17) "buffer used")
(assert (= (- (length (buf :buffer)) (g/buffer-used buf)) 495) "buffer available")
(assert (= (string (g/extract-text buf true)) "_fyyhello, worldoo"))

(g/cursor-right buf)
(g/cursor-right buf)
(g/move-cursor-to buf :end)

(assert (= (g/buffer-used buf) 17) "buffer used")
(assert (= (- (length (buf :buffer)) (g/buffer-used buf)) 495) "buffer available")
(assert (= (string (g/extract-text buf true)) "fyyhello, worldoo_"))

(g/move-cursor-to buf :begin)

(assert (= (g/buffer-used buf) 17) "buffer used")
(assert (= (- (length (buf :buffer)) (g/buffer-used buf)) 495) "buffer available")
(assert (= (string (g/extract-text buf)) "fyyhello, worldoo"))

(g/move-cursor-to buf :index 8)

(assert (= (g/buffer-used buf) 17) "buffer used")
(assert (= (- (length (buf :buffer)) (g/buffer-used buf)) 495) "buffer available")
(assert (= (string (g/extract-text buf true)) "fyyhello_, worldoo"))

# check if cursor is already at index
(g/move-cursor-to buf :index 8)

(assert (= (g/buffer-used buf) 17) "buffer used")
(assert (= (- (length (buf :buffer)) (g/buffer-used buf)) 495) "buffer available")
(assert (= (string (g/extract-text buf true)) "fyyhello_, worldoo"))
