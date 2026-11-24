; extends

; let sql = (*language=sql*) """..."""
([(block_comment) (line_comment)] @_marker
  . (const (triple_quoted_string) @injection.content)
  (#match? @_marker "\\c^%(//|\\(\\*)\\s*language\\s*[=]\\s*t?sql\\s*%(\\*\\))?$")
  (#lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 3 0 -3)
  (#set! injection.language "sql"))

; query (*language=sql*) <| """..."""
([(block_comment) (line_comment)] @_marker
  . (infix_op) @_op
  . (const (triple_quoted_string) @injection.content)
  (#eq? @_op "<|")
  (#match? @_marker "\\c^%(//|\\(\\*)\\s*language\\s*[=]\\s*t?sql\\s*%(\\*\\))?$")
  (#lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 3 0 -3)
  (#set! injection.language "sql"))

; An annotation above a let binding can be a sibling of the declaration
; or the final line comment inside the preceding expression.
([
  (block_comment) @_marker
  (line_comment) @_marker
  (_ (line_comment) @_marker .)
  (declaration_expression (function_or_value_defn (line_comment) @_marker .) .)
]
  . (declaration_expression
      (function_or_value_defn
        body: [
          (const (triple_quoted_string) @injection.content)
          (application_expression
            (tuple_expression . (const (triple_quoted_string) @injection.content)))
        ]))
  (#match? @_marker "\\c^%(//|\\(\\*)\\s*language\\s*[=]\\s*t?sql\\s*%(\\*\\))?$")
  (#lua-match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 3 0 -3)
  (#set! injection.language "sql"))
