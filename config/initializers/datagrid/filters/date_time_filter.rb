class Datagrid::Filters::DateTimeFilter < Datagrid::Filters::BaseFilter
  def parse(value)
    if value.respond_to?(:utc)
      value = value.utc
    end

    if value.is_a?(String)
      return value
    else
      return value.to_s(:db)
    end
  end
end


