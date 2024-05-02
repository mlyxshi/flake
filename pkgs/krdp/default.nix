{ lib
, stdenv
, fetchFromGitLab
, extra-cmake-modules
, kconfig 
, kdbusaddons 
, kpipewire
}:

stdenv.mkDerivation {
  pname = "krdp";
  version = "unstable-2024-04-29";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma";
    repo = "krdp";
    rev = "5bc4a1f8ab916b830caf6d0fb2c8dff552240d54";
    hash = "sha256-51q8V7R5vQ6FHFiBDUq+7rIrw7qbLxLTYyT6lqO3ruY=";
  };

  nativeBuildInputs = [ extra-cmake-modules ];
  buildInputs = [
    kconfig 
    kdbusaddons 
    kpipewire
    # knotifications kwallet kwidgetsaddons
    # kwindowsystem kxmlgui kwayland 
    # qtx11extras
    # pipewire
    # plasma-wayland-protocols
    # wayland
  ];

  meta = with lib; {
    description = "Library and examples for creating an RDP server";
    homepage = "https://invent.kde.org/plasma/krdp";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
