(def *MIN_BUF_SIZE* 512)

(def buffer-proto
  @{:size 0
    :cursor 0
    :gap-end 0
    :buffer @""})

(defn extract-text
  [buf & tst]
  (var text (buffer/slice (get buf :buffer) 0 (get buf :cursor)))
  (when (and (> (length tst) 0) (tst 0))
    (buffer/push-string text "_"))
  (cond (>= (length (get buf :buffer)) (get buf :gap-end))
    (buffer/push text (buffer/slice (get buf :buffer) (get buf :gap-end))))
  text)

(defn new-buffer
  [size]
  (let [initsize (max size *MIN_BUF_SIZE*)
        nb (table/setproto @{} buffer-proto)]
    (set (nb :size) initsize)
    (set (nb :cursor) 0)
    (set (nb :gap-end) initsize)
    (set (nb :buffer) (buffer/new-filled initsize))
    nb))

(defn buffer-front
  "size of text before cursor"
  [buf]
  (get buf :cursor))

(defn buffer-back
  "size of text after cursor"
  [buf]
  (- (get buf :size) (get buf :gap-end)))

(defn buffer-used
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
    (when (= (buf :cursor) (buf :gap-end))
      (set (buf :buffer) (buffer-grow buf (* (buf :size) 2))))
    (set (buf :buffer) (put (buf :buffer) (buf :cursor) ch))
    (++ (buf :cursor))))

(defn insert-string
  "insert string into the gap buffer"
  [buf str]
  (each c str
    (insert-char buf (string/from-bytes c))))

(defn cursor-left
  "move gap buffer to the left"
  [buf]
  (when (> (buf :cursor) 0)
    (-- (buf :gap-end))
    (-- (buf :cursor))
    (let [cursor ((get buf :cursor) (get buf :buffer))]
      (put (buf :buffer) (buf :gap-end) cursor)
      (put (buf :buffer) (buf :cursor) 0))))

(defn cursor-right
  "move gap buffer to the right"
  [buf]
  (when (< (get buf :gap-end) (get buf :size))
    (let [egap ((get buf :gap-end) (get buf :buffer))]
      (put (buf :buffer) (buf :cursor) egap)
      (put (buf :buffer) (buf :gap-end) 0))
    (++ (buf :gap-end))
    (++ (buf :cursor))))

(defn- move-gap
  "move cursor and gap to a given index"
  [buf index]
  (let [cursor (buf :cursor)
        size (buf :size)
        new-size (- (buf :gap-end) (buf :cursor))]
    (cond
      (and (<= index cursor) (>= index 0))
      (let [new-gap (buffer/new-filled (- cursor index))
            x (buffer/slice (buf :buffer) index cursor)]
        (set (buf :cursor) index)
        (set (buf :gap-end) (+ index new-size))
        (buffer/blit (buf :buffer) new-gap index)
        (buffer/blit (buf :buffer) x (buf :gap-end)))
      (and (> index cursor))
      (let [new-gap (buffer/new-filled new-size)
            new-space (- index cursor)
            x (buffer/slice (buf :buffer) (buf :gap-end) (+ (buf :gap-end) new-space))]
        (set (buf :cursor) index)
        (set (buf :gap-end) (+ index new-size))
        (buffer/blit (buf :buffer) new-gap index)
        (buffer/blit (buf :buffer) x (- index new-space))))))

(defn move-cursor-to
  "convenience function for move-gap"
  [buf type & pos]
  (when (or (not= type :index) (> (length pos) 0))
    (case type
      :begin (move-gap buf 0)
      :end (move-gap buf (length (extract-text buf)))
      :index (move-gap buf (first pos)))))

(defn delete-left
  "delete the character to the left of the cursor"
  [buf]
  (when (> (get buf :cursor) 0)
    (-- (buf :cursor))
    (put (buf :buffer) (buf :cursor) 0))
  (when (< (buffer-used buf) (/ (get buf :size) 4))
    (buffer-shrink buf (/ (get buf :size) 2))))

(defn delete-right
  "delete the character to the right of the cursor"
  [buf]
    (when (< (get buf :gap-end) (get buf :size))
      (put (buf :buffer) (buf :gap-end) 0))
      (++ (buf :gap-end))
    (when (< (buffer-used buf) (/ (get buf :size) 4))
      (buffer-shrink buf (/ (get buf :size) 2))))

