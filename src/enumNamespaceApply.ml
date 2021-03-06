open ApiAst
open ApiFold


let prepend_ns ns name =
  List.fold_left
    (fun name ns ->
       ns ^ "_" ^ name
    ) name ns


let resolve_ns symtab ns =
  List.map (SymbolTable.name symtab) ns


let fold_enumerator v (symtab, ns) = function
  | Enum_Name (_, uname, _) ->
      let symtab =
        SymbolTable.rename uname
          (prepend_ns (resolve_ns symtab ns)) symtab
      in
      (symtab, ns)

  | Enum_Namespace (uname, enumerators) ->
      let symtab, _ =
        visit_list v.fold_enumerator v (symtab, uname :: ns) enumerators
      in
      (symtab, ns)


let v = { default with fold_enumerator }


let transform (symtab, decls) =
  let symtab, _ =
    visit_decls v (symtab, []) decls
  in
  symtab, decls
