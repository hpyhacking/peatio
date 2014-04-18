class AMQPQueue
  class <<self
    def queues
      @queues ||= Hash.new {|h, k| h[k] = [] }
    end

    def enqueue(qid, payload)
      queues[qid] << payload
    end

    def publish(eid, payload, attrs={})
      # do nothing
    end
  end
end

