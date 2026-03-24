; extends

; ((import_declaration)+ @imports @fold)

; Fold class annotations
(class_declaration
  (modifiers) @fold)

; Fold field annotations
; (needs improvements, also folds access modifier)

; (field_declaration
;   (modifiers
;     ([
;        (annotation)
;        (marker_annotation)
;      ]
;      [
;         (annotation)
;         (marker_annotation)
;      ]+)) @fold)

