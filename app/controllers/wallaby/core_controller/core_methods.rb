module Wallaby::CoreController::CoreMethods
  extend ActiveSupport::Concern

  included do
    helper_method \
      :model_class,
      :resources_name, :resource_name,
      :model_decorator, :decorator,
      :collection, :resource,
      :id, :resource_params
  end

  class_methods do
    def resources_name condition = self < Wallaby::ResourcesController
      if condition
        Wallaby::Utils.to_resources_name name.gsub('Controller', '')
      end
    end

    def model_class target_resources_name = resources_name, condition = self < Wallaby::ResourcesController
      if condition
        Wallaby::Utils.to_model_name(target_resources_name).constantize
      end
    end
  end

  def resources_name
    self.class.resources_name || params[:resources]
  end

  def resource_name
    resources_name.singularize
  end

  def model_class
    self.class.model_class || self.class.model_class(resource_name, true)
  end

  def model_decorator model = nil
    if model
      Wallaby::DecoratorFinder.find_model model
    else
      @model_decorator ||= Wallaby::DecoratorFinder.find_model model_class
    end
  end

  def decorator
    @decorator ||= Wallaby::DecoratorFinder.find_resource model_class
  end

  def collection
    @collection ||= model_decorator.collection
  end

  def resource
    @resource ||= model_decorator.find_or_initialize id
  end

  def id
    params[:id]
  end

  def resource_params
    # can be overridden
    white_list_fields = model_class.column_names.reject{ |v| v == 'id' }
    params.require(resource_name).permit *white_list_fields
  end

  protected
  def build_up_view_paths
    lookup_context.prefixes = Wallaby::PrefixesBuilder.new(self).build
  end
end