module Worker
  class PusherMember

    def process(payload, metadata, delivery_info)
      member = Member.find payload['member_id']
      event  = payload['event']
      data   = JSON.parse payload['data']
      member.notify event, data
    end

  end
end
