with open("homeManagerModules/apps/desktop-apps.nix", "r") as f:
    content = f.read()

apps_to_add = ["firefox", "freecad", "kicad", "thunderbird", "bambu-studio", "orca-slicer", "arduino-ide"]
add_str = "    " + "\n    ".join(apps_to_add) + "\n  ];"
content = content.replace("  ];", add_str)

with open("homeManagerModules/apps/desktop-apps.nix", "w") as f:
    f.write(content)
