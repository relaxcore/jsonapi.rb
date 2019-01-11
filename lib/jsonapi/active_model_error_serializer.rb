require 'jsonapi/error_serializer'

module JSONAPI
  # [ActiveModel::Errors] serializer
  class ActiveModelErrorSerializer < ErrorSerializer
    set_id :object_id
    set_type :error

    attribute :status do
      '422'
    end

    attribute :title do
      Net::HTTP::STATUS_CODES[422]
    end

    attribute :code do |object|
      _, error_hash = object
      error_hash[:error]
    end

    attribute :detail do |object, params|
      error_key, error_hash = object
      errors_object = params[:model].errors
      message = errors_object.generate_message(error_key, error_hash[:error])
      errors_object.full_message(error_key, message)
    end

    attribute :source do |object, params|
      error_key, _ = object
      model_serializer = params[:model_serializer]

      if model_serializer.attributes_to_serialize.keys.include?(error_key)
        { pointer: "/data/attributes/#{error_key}" }
      elsif model_serializer.relationships_to_serialize.keys.include?(error_key)
        { pointer: "/data/relationships/#{error_key}" }
      else
        { pointer: '' }
      end
    end
  end
end