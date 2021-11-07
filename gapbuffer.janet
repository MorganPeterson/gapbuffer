(def *MIN_BUF_SIZE* 512)

(def buffer-proto
  @{:size 0
    :cursor 0
    :gap-end 0
    :buffer @""})

(defn new-buffer
  [size]
  (let [initsize (max size *MIN_BUF_SIZE*)
        nb (table/setproto @{} buffer-proto)]
    (set (nb :size) initsize)
    (set (nb :cursor) 0)
    (set (nb :gap-end) initsize)
    (set (nb :buffer) (buffer/new initsize))
    nb))

(defn- buffer-front
  "size of text before cursor"
  [buf]
  (get buf :cursor))

(defn- buffer-back
  "size of text after cursor"
  [buf]
  (- (get buf :size) (get buf :gap-end)))

(defn- buffer-used
  "total number of used characters"
  [buf]
  (+ (buffer-front buf) (buffer-back buf)))

(defn- buffer-move-back
  "move back of buf to back of new buffer"
  [buf bufstring size]
  (when (< size (length bufstring))
    (var newbuf (buffer/new size))
    (let [newbuf-start (+ (length bufstring) (- size (buffer-back buf)))]
      (buffer/push-string newbuf (buffer/slice bufstring 0 newbuf-start))
      (buffer/push-string newbuf (buffer/slice (get buf :buffer) (inc newbuf-start) (get buf :gap-end)))
    (set (buffer :buffer) newbuf))))
  
(defn- buffer-shrink
  "shrink gap buffer to new size"
  [buf newsize]
  (let [nsize (max newsize *MIN_BUF_SIZE*)]
    (when (>= nsize (buffer-used buf))
      (buffer-move-back buf (get buf :buffer) nsize))
      (set (buf :gap-end) (- nsize (buffer-back buf)))
      (set (buf :size) nsize)))

(defn- buffer-grow
  "grow gap buffer to a new size"
  [buf newsize]
  (let [nsize (max newsize *MIN_BUF_SIZE*)]
    (when (< (get buf :size) nsize)
      (buffer-move-back buf (get buf :buffer) nsize))
      (set (buf :gap-end) (- nsize (buffer-back buf)))
      (set (buf :size) nsize)))

(defn insert-char
  "insert character into the gap buffer"
  [buf c]
  (let [ch (get (string/bytes c) 0)]
    (when (= (get buf :cursor) (get buf :gap-end))
      (set (buf :buffer) (buffer-grow buf (* (get buf :size) 2))))
    (set (buf :buffer) (put (get buf :buffer) (get buf :cursor) ch))
    (++ (buf :cursor))))

(defn cursor-left
  "move gap buffer to the left"
  [buf]
  (when (> (get buf :b-cursor) 0)
    (-- (buf :gap-end))
    (-- (buf :cursor))
    (let [cursor ((get buf :cursor) (get buf :buffer))]
      (set (buf :buffer) (put (get buf :buffer) (get buf :gap-end) cursor)))))

(defn cursor-right
  "move gap buffer to the left"
  [buf]
  (when (< (get buf :gap-end) (get buf :size))
    (let [egap ((get buf :gap-end) (get buf :buffer))]
      (set (buf :buffer) (put (get buf :buffer) (get buf :cursor) egap)))
    (++ (buf :gap-end))
    (++ (buf :cursor))))

(defn delete-left
  "delete the character to the left of the cursor"
  [buf]
  (when (> (get buf :cursor) 0)
    (-- (buf :cursor)))
  (when (< (buffer-used buf) (/ (get buf :size) 4))
    (buffer-shrink buf (/ (get buf :size) 2))))

(defn delete-right
  "delete the character to the right of the cursor"
  [buf]
  (prompt :result
    (when (< (get buf :gap-end) (get buf :size))
      (++ (buf :gap-end)))
    (when (< (buffer-used buf) (/ (get buf :size) 4))
      (return :result (buffer-shrink buf (/ (get buf :size) 2))))
    (return :result buf)))

(defn extract-text
  [buf & tst]
  (var text (buffer/slice (get buf :buffer) 0 (get buf :cursor)))
  (when tst
    (buffer/push-string text "_"))
  (cond (> (length (get buf :buffer)) (get buf :gap-end))
    (do
      (def txt2 (buffer/slice (get buf :buffer) (get buf :gap-end)))
      (buffer/push-string text txt2))
    text))

