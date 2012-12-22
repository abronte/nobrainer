module NoBrainer::Base::Persistance
  extend ActiveSupport::Concern

  included do
    extend ActiveModel::Callbacks
    define_model_callbacks :create, :update, :save
  end

  def initialize(attrs={})
    @new_record = true
  end

  def new_record?
    @new_record
  end

  def persisted?
    !new_record?
  end

  def save
    run_callbacks(new_record? ? :create : :update) do
      run_callbacks :save do
        if new_record?
          result = NoBrainer.run { table.insert(attributes) }
          @attributes['id'] = result['generated_keys'].first
          @new_record = false
        else
          NoBrainer.run { selector.update { attributes } }
        end
        true
      end
    end
  end

  module ClassMethods
    def create(*args)
      new(*args).tap { |model| model.save }
    end
  end
end
