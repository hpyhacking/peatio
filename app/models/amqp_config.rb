class AMQPConfig
  class <<self
    def data
      @data ||= Hashie::Mash.new YAML.load_file(Rails.root.join('config', 'amqp.yml'))
    end

    def connect
      data[:connect]
    end

    def binding_exchange(id)
      data[:binding][id][:exchange] &&
        exchange(data[:binding][id][:exchange])
    end

    def binding_queue(id)
      queue data[:binding][id][:queue]
    end

    def queue(id)
      name = data[:queue][id][:name]
      settings = {}
      [name, settings]
    end

    def exchange(id)
      type = data[:exchange][id][:type]
      name = data[:exchange][id][:name]
      [type, name]
    end
  end
end
