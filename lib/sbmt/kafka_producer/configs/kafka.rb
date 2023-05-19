# frozen_string_literal: true

module Sbmt
  module KafkaProducer
    module Configs
      class Kafka < Anyway::Config
        SERVERS_REGEXP = /^[\w\d.\-:,]+$/.freeze

        config_name :kafka_producer_kafka
        attr_config :servers,
          connect_timeout: 1,
          ack_timeout: 1,
          required_acks: 1,
          max_retries: 2,
          retry_backoff: 1,
          kafka_config: {}

        required :servers
        coerce_types servers: {type: :string, array: false}

        on_load :ensure_options_are_valid

        def to_kafka_options
          kafka_config.merge(
            "bootstrap.servers": servers,
            "socket.connection.setup.timeout.ms": connect_timeout.to_f * 1000,
            "request.timeout.ms": ack_timeout.to_f * 1000,
            "request.required.acks": required_acks,
            "message.send.max.retries": max_retries,
            "retry.backoff.ms": retry_backoff.to_f * 1000
          ).symbolize_keys
        end

        private

        def ensure_options_are_valid
          raise_validation_error "invalid servers: #{servers}, should be in format: \"host1:port1,host2:port2,...\"" unless SERVERS_REGEXP.match?(servers)
        end
      end
    end
  end
end
