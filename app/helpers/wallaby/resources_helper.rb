module Wallaby::ResourcesHelper
  include Wallaby::FormHelper

  def decorate(resource)
    if resource.respond_to? :map # collection
      decorator = Wallaby::DecoratorFinder.find_resource resource.first.class
      resource.map do |item|
        decorator.decorate item
      end
    else
      decorator = Wallaby::DecoratorFinder.find_resource resource.class
      decorator.decorate resource
    end
  end

  def model_decorator(model_class)
    Wallaby::DecoratorFinder.find_model model_class
  end

  def type_partial_render(options = {}, locals = {}, &block)
    decorated   = locals[:object]
    field_name  = locals[:field_name].to_s

    fail ArgumentError unless field_name.present? && decorated.is_a?(Wallaby::ResourceDecorator)

    options   = "#{ action_name }/#{ options }" if options.is_a? String

    locals[:metadata] = decorated.metadata_of field_name
    locals[:value]    = decorated.send field_name

    render options, locals, &block or locals[:value]
  end

  def show_title(decorated)
    fail ArgumentError unless decorated.is_a? Wallaby::ResourceDecorator
    [ to_model_label(decorated.model_class), decorated.to_label ].compact.join ': '
  end
end
