# Reopens Mongoid::Document to inject extra persistence capabilities into every class that includes
# it, geared towards the DataMapper pattern (persistence decoupled from the domain model).
#
# A second `included` block cannot be added to Mongoid::Document because ActiveSupport::Concern
# forbids it (MultipleIncludedBlocks). Instead its `included` hook is intercepted by prepending a
# module to its singleton: each `include Mongoid::Document` installs the class methods and the
# `initialize` override on the including class.
module MongoidMapper
  module Initialize
    def initialize(*, **)
      Mongoid::Document.instance_method(:initialize).bind(self).call(*, **)
    end
  end

  module ClassMethods
    def field(name, options = {})
      remove_method name if method_defined?(name, false) || private_method_defined?(name, false)
      remove_method "#{name}=" if method_defined?("#{name}=", false) || private_method_defined?("#{name}=", false)
      super
    end

    def persisted_method(method_name, options = {})
      field_name = :"_#{options[:as] || method_name}"
      before_save { self[field_name] = send method_name }
      field(field_name, options)
    end

    private

    def autosave_on(method_name)
      old_method = instance_method(method_name)
      define_method(method_name) { |*args, **kwargs|
        old_method.bind(self).call(*args, **kwargs).tap { save! }
      }
    end

    def inherited(subclass)
      super
      subclass.prepend(Initialize)
      subclass.subclasses.each(&method(:inherited))
    end
  end

  module DocumentHook
    def included(base)
      super
      base.singleton_class.prepend(ClassMethods)
      base.prepend(Initialize)
      base.subclasses.each(&base.method(:inherited))
    end
  end
end

Mongoid::Document.singleton_class.prepend(MongoidMapper::DocumentHook)
