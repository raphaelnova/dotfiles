; extends

;; I'm trying to hide lines with comments to remove clutter when reading code.
;; Using conceal and conceal_lines work when this query is placed here, but it
;; breaks syntax highlights. It doesn't work if I put this same file under
;; after/queries/lua/. I still need to learn how to toggle it with a keymap, I
;; think I can call treesitter's API to toggle this query.



;; This hides the lines' contents but leaves the lines there. It results in lots
;; of empty lines between code.

; ((comment) @comment (#set! conceal "x"))



;; This hides all lines with comments, but navigating through the code gets wonky
;; because, although the lines are concealed, navigation still takes them into
;; consideration, so you have to count lines that are not there.

; ((comment) @comment (#set! conceal_lines "*"))
