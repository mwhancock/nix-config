{ ... }: {
services.apache-kafka = {
    enable = true;
    # Replace with a randomly generated uuid. You can get one by running:
    # kafka-storage.sh random-uuid
    clusterId = "xxxxxxxxxxxxxxxxxxxxxx";
    formatLogDirs = true;
    settings = {
      listeners = [
        "PLAINTEXT://:9092"
        "CONTROLLER://:9093"
      ];
      # Adapt depending on your security constraints
      "listener.security.protocol.map" = [
        "PLAINTEXT:PLAINTEXT"
        "CONTROLLER:PLAINTEXT"
      ];
      "controller.quorum.voters" = [
        "1@127.0.0.1:9093"
      ];
      "controller.listener.names" = ["CONTROLLER"];

      "node.id" = 1;
      "process.roles" = ["broker" "controller"];

      # I prefer to use this directory, because /tmp may be erased
      "log.dirs" = ["/var/lib/apache-kafka"];
      "offsets.topic.replication.factor" = 1;
      "transaction.state.log.replication.factor" = 1;
      "transaction.state.log.min.isr" = 1;
    };
  };

  # Set this so that systemd automatically create /var/lib/apache-kafka
  # with the right permissions
  systemd.services.apache-kafka.unitConfig.StateDirectory = "apache-kafka";
}
