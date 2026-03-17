{
  pkgs,
  ...
}:
let
  packageLock = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/abhigyanpatwari/GitNexus/main/gitnexus/package-lock.json";
    hash = "sha256-4vSCq7MlQw1myq5rEmxoNnoDpcAl+WO0v2nb2W/2HJ8=";
  };

  gitnexus = pkgs.buildNpmPackage {
    pname = "gitnexus";
    version = "1.4.6";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/gitnexus/-/gitnexus-1.4.6.tgz";
      hash = "sha256-6r1fSYWB6nghdCV+QSnq/JvzGDnb46wITIZAMhvO5hs=";
    };

    postPatch = ''
      cp ${packageLock} package-lock.json
    '';

    npmDepsHash = "sha256-GufohnlbTe/FAMEzQvWAKFC32OTfGqAHKff5JDoOtSA=";

    npmFlags = [ "--ignore-scripts" ];
    nativeBuildInputs = [ pkgs.tree-sitter ];
    dontNpmBuild = true;

    # tree-sitter's install script tries to download from github (blocked by sandbox).
    # tree-sitter is provided natively via nativeBuildInputs.
    # @ladybugdb/core just needs its prebuilt binary copied into place.
    postInstall = ''
      lbug_dir="$out/lib/node_modules/gitnexus/node_modules/@ladybugdb/core"
      node "$lbug_dir/install.js"

      # @huggingface/transformers hardcodes .cache/ relative to its module dir.
      # Patch both src and bundled dist to use $HOME/.cache/huggingface/transformers at runtime.
      hf_dir="$out/lib/node_modules/gitnexus/node_modules/@huggingface/transformers"

      # Use sed for both files — pattern varies between src and bundled dist
      for f in "$hf_dir/src/env.js" "$hf_dir/dist/transformers.node.mjs"; do
        sed -i "s|\.join(dirname__, '/.cache/')|.join(process.env.HOME \|\| '/tmp', '.cache/huggingface/transformers')|g" "$f"
      done
    '';
  };
in
{
  home.packages = [
    gitnexus
  ];
}
