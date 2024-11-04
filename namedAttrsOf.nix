lib:
with lib;
with types;
elemTypeFactory:
let
  elemType = elemTypeFactory null;
in
mkOptionType rec {
  name = "namedAttrsOf";
  description = "attribute set of ${
    optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
  } aware of their names";
  descriptionClass = "composite";
  check = isAttrs;
  merge =
    loc: defs:
    mapAttrs (n: v: v.value) (
      filterAttrs (n: v: v ? value) (
        zipAttrsWith
          (name: defs: (mergeDefinitions (loc ++ [ name ]) (elemTypeFactory name) defs).optionalValue)
          # Push down position info.
          (
            map (
              def:
              mapAttrs (n: v: {
                inherit (def) file;
                value = v;
              }) def.value
            ) defs
          )
      )
    );
  emptyValue = {
    value = { };
  };
  getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "<name>" ]);
  getSubModules = elemType.getSubModules;
  substSubModules = m: attrsOf (elemType.substSubModules m);
  functor = (defaultFunctor name) // {
    wrapped = elemType;
  };
  nestedTypes.elemType = elemType;
}
