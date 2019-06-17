class JSONLogFormatter < ::Logger::Formatter
  def call(severity, time, _progname, msg)
      begin
        obj = JSON.parse msg
      rescue StandardError
        obj = msg
      end
      if obj.is_a? Hash
        JSON.dump(obj.merge({ level: severity, time: time })) + "\n"
      else
        JSON.dump(level: severity, time: time, message: msg) + "\n"
      end
  end
end
