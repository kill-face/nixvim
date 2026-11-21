; F# folds. nvim-treesitter ships no fsharp folds query, and nixvim only turns
; on treesitter folding (foldmethod=expr) for languages that have one.
; Single-line nodes never fold, so listing small constructs is harmless.
[
  (module_defn)
  (type_definition)
  (type_extension)
  (member_defn)
  (interface_implementation)
  (function_or_value_defn)
  (ce_expression)
  (match_expression)
  (rule)
  (if_expression)
  (try_expression)
  (for_expression)
  (while_expression)
  (fun_expression)
  (object_expression)
  (list_expression)
  (array_expression)
  (brace_expression)
  (anon_record_expression)
  (block_comment)
] @fold
