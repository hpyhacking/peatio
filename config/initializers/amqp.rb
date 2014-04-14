AMQP_CONFIG = Hashie::Mash.new YAML.load_file(Rails.root.join('config', 'amqp.yml'))
