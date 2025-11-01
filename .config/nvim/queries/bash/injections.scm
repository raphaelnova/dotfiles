;;
;; AWK INJECTION
;;

;; Matches an awk call reading from stdin (the dot denotes "last child"
;; and is needed so the matcher don't match other previous flag args).
;; @injection.content is captured multiple times because when it's a
;; (concatenation) we need to capture all its children but not itself
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
;; They're all immediate siblings, hence the dot separating them.
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

