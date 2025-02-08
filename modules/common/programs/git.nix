{pkgs, ...}: {
  programs.git = {
    enable = true;
    config = {
      user.name = "nyooNyoo";
    };
  };
}
