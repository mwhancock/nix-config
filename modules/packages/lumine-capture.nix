# LumineCapture: fast Wayland screenshot tool with annotations and OCR.
# Not in nixpkgs, so built from source from the flake's git input.
#
# The build's one non-obvious piece is ONNX Runtime. oar-ocr enables ort's
# `download-binaries` feature, whose build script fetches prebuilt ORT
# binaries from the network -- which the Nix sandbox does not have. Setting
# ORT_LIB_LOCATION makes that script link against a given ORT install
# instead of downloading, so it points at nixpkgs' onnxruntime. That copy is
# 1.27, which matches the api-27 feature set `ort` defaults to, so the
# symbols the bindings expect are present. ORT_PREFER_DYNAMIC_LINK=1 keeps
# it from hunting for a static libonnxruntime.a, which nixpkgs does not ship.
#
# OCR models themselves are downloaded at first use by the app, at runtime;
# that is unaffected by any of this.
{ lib
, stdenv
, rustPlatform
, pkg-config
, libclang
, openssl
, wayland
, pipewire
, libxkbcommon
, onnxruntime
, lumine-capture
}:

rustPlatform.buildRustPackage {
  pname = "lumine-capture";
  version = "0.3.0";

  src = lumine-capture;

  cargoLock.lockFile = "${lumine-capture}/Cargo.lock";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    wayland
    pipewire
    libxkbcommon
    onnxruntime
  ];

  env = {
    ORT_LIB_LOCATION = "${lib.getLib onnxruntime}/lib";
    ORT_PREFER_DYNAMIC_LINK = "1";
    LIBCLANG_PATH = lib.makeLibraryPath [ libclang ];
    # pipewire-sys/libspa-sys generate bindings with bindgen, and libclang on
    # NixOS does not search glibc's include directory on its own -- without
    # this the build dies on "'inttypes.h' file not found".
    BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${lib.getInclude stdenv.cc.libc}/include";
  };

  doCheck = false;

  postInstall = ''
    substituteInPlace assets/lumine-capture.desktop \
      --replace-fail '/usr/bin/lumine-capture' "$out/bin/lumine-capture"
    install -Dm644 assets/lumine-capture.desktop -t "$out/share/applications"
    mkdir -p "$out/share/icons"
    cp -r assets/hicolor "$out/share/icons/"
  '';

  meta = {
    description = "Fast, lightweight Wayland screenshot tool with annotations and OCR";
    homepage = "https://github.com/Netflate/LumineCapture";
    license = with lib.licenses; [ mit asl20 ];
    mainProgram = "lumine-capture";
    platforms = lib.platforms.linux;
  };
}
