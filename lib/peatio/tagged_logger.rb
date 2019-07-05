# Examples:
# logger = TaggedLogger(Rails.logger, app: 'peatio')
# logger.info 'order processed'
# # I, [2019-07-04T18:56:02.977542 #7987]  INFO -- : {:app=>"peatio", :message=>"order processed"}

# with json format
# logger = TaggedLogger.new(Rails.logger, app: 'peatio')
# logger_extended = TaggedLogger.new(logger, version: '2.2', branch: 'master')
#
# logger.info 'order processed'
# # {"app":"peatio","message":"order processed","level":"INFO","time":"2019-07-04 18:59:01"}
#
# logger_extended.info 'order processed'
# # {"app":"peatio","version":"2.2","branch":"master","message":"order processed","level":"INFO","time":"2019-07-04 18:59:09"}

class TaggedLogger
  def initialize(logger, tags)
    @logger = logger.dup
    @tags = tags
  end

  [:fatal, :error, :warn, :info, :debug].each do |log_method|
    define_method(log_method) do |msg|
      if msg.is_a? Hash
        msg = @tags.merge msg
      else
        msg = @tags.merge(message: msg)
      end

      @logger.method(log_method).call(msg)
    end
  end
end
