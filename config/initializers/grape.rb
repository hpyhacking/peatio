# encoding: UTF-8
# frozen_string_literal: true

# Make Grape support lambdas in «description» field.

require 'grape-swagger/doc_methods/parse_params'
require 'grape_entity/exposure/delegator_exposure'

class Grape::Entity::Exposure::Base
  def documentation
    @documentation.respond_to?(:call) ? @documentation.call : @documentation
  end
end

class << GrapeSwagger::DocMethods::ParseParams
  def document_description(settings)
    description = settings[:desc].presence || settings[:description].presence
    description = description.respond_to?(:call) ? description.call : description
    description = '' unless description.kind_of?(String) && description.present?
    @parsed_param[:description] = description
  end
end
