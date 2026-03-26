{...}: {
  networking.wg-quick.interfaces.wg0 = {
    autostart = false;
    address = ["10.73.186.95/32"];
    dns = ["1.1.1.1"];

    peers = [
      {
        publicKey = "TUCaQc26/R6AGpkDUr8A8ytUs/e5+UVlIVujbuBwlzI=";
        allowedIPs = ["0.0.0.0/0"];
        endpoint = "146.70.198.66:51820";
        persistentKeepalive = 25;
      }
    ];
  };
}
