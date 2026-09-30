# gmc — https://github.com/samzong/gmc
#
# Not in nixpkgs, and upstream ships no flake.nix, so it is built from the
# release tag here. Pinned to v0.10.1; bump `version` and both hashes together.
{ lib, buildGoModule, fetchFromGitHub, ... }:

buildGoModule rec {
  pname = "gmc";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "samzong";
    repo = "gmc";
    rev = "v${version}";
    hash = "sha256-w1503RxV6Wfu0Ne+5xY0Cob6BZx2XLP+F2mRFKlfBsI=";
  };

  # Hash of the Go module download cache, checked against the repo's go.sum.
  # Recompute with `nix-build` and paste the reported SRI value on a bump.
  vendorHash = "sha256-goEBvLaUcHfOo/3DbyoRathtxe8ljVigfv1oia60GWY=";

  # Resolve modules through the Go module proxy rather than a checked-out
  # vendor/ directory.
  proxyVendor = true;

  # Upstream runs its own test suite; the Nix build only needs the binary.
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/samzong/gmc/cmd.Version=${version}"
    "-X github.com/samzong/gmc/cmd.BuildTime=1970-01-01T00:00:00Z"
  ];

  meta = {
    description = "Parallel worktrees for parallel AI agents, plus AI-generated commits";
    homepage = "https://github.com/samzong/gmc";
    license = lib.licenses.mit;
    mainProgram = "gmc";
    platforms = lib.platforms.unix;
  };
}
