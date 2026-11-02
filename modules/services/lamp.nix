# LAMP, for the school database course.
#
# MySQL rather than MariaDB on purpose. The course material is MySQL, and
# while MariaDB is a drop-in replacement for most DDL/DML, the two differ in
# ways that show up in an intro course: SHOW CREATE TABLE output, default
# collations, JSON/functional-index syntax, and error messages. 8.4 is the
# current LTS line. Switching to MariaDB is `package = pkgs.mariadb;` below
# and nothing else, if the course ever changes its mind.
#
# What listens where, all of it loopback only:
#
#   127.0.0.1:3306   mysqld            (services.mysql)
#   127.0.0.1:80     Apache            (services.httpd)
#   /run/phpfpm/web.sock  PHP-FPM       (services.phpfpm)
#
# Nothing is opened in the firewall. If MySQL Workbench ends up running on
# the Windows box instead of this machine, see the note at the bottom -- that
# is the one change that needs a firewall edit, and it should be deliberate.
{ config, lib, pkgs, ... }:

let
  # The vhost docroot. Deliberately a real directory rather than a Nix store
  # path: coursework means editing files in place, and a store path is
  # read-only. Created by tmpfiles on activation, so it is declared here and
  # not something you have to recreate after a rebuild.
  docroot = "/var/www";

  # The PHP-FPM pool's socket. Read from the pool definition instead of
  # writing the path twice, so the Apache handler and the pool cannot drift
  # apart.
  phpSocket = config.services.phpfpm.pools.web.socket;
in
{
  # ------------------------------------------------------------- MySQL 8.4
  #
  # bind-address is loopback, not 0.0.0.0. mysqld is the one service here
  # whose exposure actually matters: an open 3306 on a laptop is how a
  # database ends up in a botnet's scan results. DBeaver, Adminer and the
  # mysql client all reach it over 127.0.0.1.
  #
  # The root account is not passwordless over TCP. NixOS gives root
  # auth_socket, so `sudo mysql` works and nothing else does; the course
  # account is created separately after activation (see below), because a
  # password in this repository is a password in git history.
  services.mysql = {
    enable = true;
    package = pkgs.mysql84;

    settings.mysqld = {
      bind-address = "127.0.0.1";
      port = 3306;

      # MySQL 8 also starts the X Protocol plugin on 33060, and that one
      # ignores bind-address: it listens on every interface unless told
      # otherwise. Nothing here uses X Protocol (DBeaver and Adminer speak
      # the classic protocol), so pin it to loopback as well rather than
      # leaving a second database port on the LAN.
      mysqlx-bind-address = "127.0.0.1";

      # Course files will contain more than ASCII eventually. utf8mb4 is
      # MySQL 8's default anyway; stating it makes the intent explicit.
      character-set-server = "utf8mb4";
      collation-server = "utf8mb4_0900_ai_ci";
    };
  };

  # ------------------------------------------------------ PHP-FPM (pool web)
  #
  # mod_php is deliberately NOT used (services.httpd.enablePHP): that path
  # builds PHP with ZTS, which is a large rebuild from source and a slower
  # request path. PHP-FPM + mod_proxy_fcgi is the standard arrangement and
  # needs no special PHP build.
  #
  # The pool runs as wwwrun -- the same account Apache runs as -- because
  # the socket is 0660 and both sides have to be in on it.
  services.phpfpm.pools.web = {
    user = "wwwrun";
    group = "wwwrun";

    settings = {
      "listen.owner" = "wwwrun";
      "listen.group" = "wwwrun";
      "listen.mode" = "0660";

      "pm" = "dynamic";
      "pm.max_children" = 10;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;

      # Without this, warnings from a script vanish into the journal with no
      # request context, which makes a broken assignment hard to debug.
      "catch_workers_output" = "yes";
    };
  };

  services.phpfpm.phpOptions = {
    # Do not advertise the exact PHP version in response headers.
    expose_php = "off";
  } // lib.optionalAttrs (config.time.timeZone != null) {
    # PHP ignores $TZ, so this has to be set in php.ini or date() is UTC.
    "date.timezone" = config.time.timeZone;
  };

  # ----------------------------------------------------------------- Apache
  services.httpd = {
    enable = true;
    adminAddr = "mark@localhost";

    # mod_proxy_fcgi is not in the module's default list; proxy and
    # proxy_http are. Only this one has to be added.
    extraModules = [ "proxy_fcgi" ];

    virtualHosts."localhost" = {
      hostName = "localhost";
      documentRoot = docroot;
      serverAliases = [ "127.0.0.1" ];

      # Loopback only. Drop this line (or add a second listen entry) to
      # serve the LAN, and then open 80 in networking.firewall.
      listen = [ { ip = "127.0.0.1"; port = 80; } ];

      extraConfig = ''
        DirectoryIndex index.php index.html

        <Directory "${docroot}">
          Options Indexes FollowSymLinks
          # AllowOverride All so .htaccess works -- some course material
          # ships one and expects it to be honoured.
          AllowOverride All
          Require all granted
        </Directory>

        # Every .php request goes to the FPM pool over its unix socket.
        # Placed in the vhost so it applies both to the docroot and to the
        # Adminer alias below.
        <FilesMatch "\.php$">
          SetHandler "proxy:unix:${phpSocket}|fcgi://localhost/"
        </FilesMatch>

        # Adminer: the whole database UI is that one PHP file. Used instead
        # of phpMyAdmin because nixpkgs does not package phpMyAdmin and
        # Adminer is a single file with no writable state of its own.
        # Reachable at http://localhost/adminer.php
        Alias /adminer.php ${pkgs.adminer}/adminer.php
        <Directory "${pkgs.adminer}">
          Require all granted
        </Directory>
      '';
    };
  };

  # ------------------------------------------------------------ Filesystem
  #
  # 2775: setgid, so every file you create in /var/www is group wwwrun and
  # Apache can read it without a chmod after each save. Owned by mark, so
  # editing coursework never needs sudo.
  systemd.tmpfiles.rules = [
    "d ${docroot} 2775 mark wwwrun - -"
  ];

  # ------------------------------------------------------------ Post-rebuild
  #
  # The course account is not declared here -- see the header. Created once
  # after the first switch, then it lives in mysql.user and survives every
  # rebuild:
  #
  #   sudo mysql
  #
  #   CREATE DATABASE school CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
  #   CREATE USER 'mark'@'localhost' IDENTIFIED BY 'pick-a-password';
  #   CREATE USER 'mark'@'127.0.0.1' IDENTIFIED BY 'pick-a-password';
  #   GRANT ALL PRIVILEGES ON *.* TO 'mark'@'localhost' WITH GRANT OPTION;
  #   GRANT ALL PRIVILEGES ON *.* TO 'mark'@'127.0.0.1' WITH GRANT OPTION;
  #   FLUSH PRIVILEGES;
  #
  # *.* rather than school.* on purpose: course exercises create databases,
  # and a standard MySQL install gives its main account that power. root
  # stays socket-only, so admin work is still `sudo mysql`.
  #
  # Both host entries are created because MySQL resolves 127.0.0.1 to
  # "localhost" only while name resolution is on; the explicit entry means
  # the JDBC connection works either way. DBeaver connects to:
  #
  #   host 127.0.0.1, port 3306, database school
  #
  # and Adminer to the same host/port with the same credentials.
}
