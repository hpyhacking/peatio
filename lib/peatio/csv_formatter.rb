class CSVFormatter
  def self.call(object, env)
    object.to_csv
  end
end
