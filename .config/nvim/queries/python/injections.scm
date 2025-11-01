; extends

((string_content) @injection.content
    (#match? @injection.content "(CREATE|DROP|SELECT|INSERT|UPDATE|DELETE)")
    (#set! injection.language "sql"))
