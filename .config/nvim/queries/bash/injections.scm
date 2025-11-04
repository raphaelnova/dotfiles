; extends

;;
;; BASH INJECTION
;;
;; This one's for `bash -c` string params. It gets a little confusing
;; at first to see what's string and what's code, but it gets easier.
;; Using offset is required because bash's parser doesn't have a node
;; `string_content` like Python nor it's as lenient as Awk's.
;;
((command
    [
	   (command_name)
	   (word)
	 ]	@cmd (#eq? @cmd "bash")
	 (word) @arg (#eq? @arg "-c")
    [
      (string) @injection.content
      (raw_string) @injection.content
      (concatenation ((_)+ @injection.content))
    ] @program
 )
 (#offset! @injection.content 0 1 0 -1)
 (#set! injection.language "bash")
 (#set! injection.combined))

;;
;; AWK INJECTION
;;
;; Matches an awk call reading from stdin (the dot denotes "last child"
;; and is needed so the matcher doesn't match other previous flag args).
;; @injection.content is used multiple times because we need to capture
;; (concatenation)'s children all at once but not the node itself. Also
;; requires injection.combined to merge concat's children into a single
;; injection.content node.
((command
    name: (command_name) @cmd (#eq? @cmd "awk")
    argument: [
      (string) @injection.content
      (raw_string) @injection.content
      (concatenation ((_)+ @injection.content))
    ] @program .
 )
 (#set! injection.language "awk")
 (#set! injection.combined))

;; Matches an awk call that reads from a file. The file is the last arg,
;; it may be preceeded by a -- and the program string comes before that.
;; They're all immediate siblings, hence the dot between nodes.
((command
    name: (command_name) @cmd (#eq? @cmd "awk")
    argument: [
      (string) @injection.content
      (raw_string) @injection.content
      (concatenation ((_)+ @injection.content))
    ] @program
    .
    argument: ((word)? @sep (#eq? @sep "--"))
    .
    argument: [
      (word)
      (concatenation)
      (simple_expansion)
    ] @input_file .
 )
 (#set! injection.language "awk"))

