RSpec.describe(MongoidMapper, "reopened Mongoid::Document") {
  def document(&)
    Class.new { include Mongoid::Document }.tap { |klass|
      klass.class_eval(&)
    }
  end

  describe("initialize") {
    it("uses Mongoid's initialize even when the class defines its own") {
      klass = document {
        store_in collection: "documents"
        field :name

        # :nocov:
        def initialize(*)
          raise("should not be invoked")
        end
        # :nocov:
      }

      a_document = klass.create!(name: "z")

      expect(a_document.name).to eq("z")
    }

    it("uses Mongoid's initialize in subclasses even when they define their own") {
      base = document {
        store_in collection: "documents"
        field :name
      }
      subclass = Class.new(base) {
        # :nocov:
        def initialize(*)
          super
          raise("should not be invoked")
        end
        # :nocov:
      }

      a_document = subclass.create!(name: "s")

      expect(a_document.name).to eq("s")
    }

    it("uses Mongoid's initialize in subclasses that existed before the include") {
      base = Class.new
      subclass = Class.new(base) {
        # :nocov:
        def initialize(*)
          super
          raise("should not be invoked")
        end
        # :nocov:
      }

      base.class_eval {
        include Mongoid::Document

        store_in collection: "documents"
        field :name
      }

      a_document = subclass.create!(name: "s")

      expect(a_document.name).to eq("s")
    }
  }

  describe("field") {
    it("reclaims value and value= defined as public methods before the class is reopened") {
      klass = Class.new {
        # :nocov:
        def value
          raise("should not be invoked")
        end

        def value=(_)
          raise("should not be invoked")
        end
        # :nocov:
      }

      klass.class_eval {
        include Mongoid::Document

        store_in collection: "documents"
        field :value
      }

      a_document = klass.create!(value: "a")

      expect(a_document.value).to eq("a")
    }

    it("reclaims value and value= defined as private methods before the class is reopened") {
      klass = Class.new {
        # :nocov:
        def value
          raise("should not be invoked")
        end

        def value=(_)
          raise("should not be invoked")
        end
        # :nocov:

        private :value, :value=
      }

      klass.class_eval {
        include Mongoid::Document

        store_in collection: "documents"
        field :value
      }

      a_document = klass.create!(value: "a")

      expect(a_document.value).to eq("a")
    }
  }

  describe("persisted_method") {
    it("persists the method result into a field prefixed with an underscore") {
      klass = document {
        store_in collection: "documents"

        def initials
          "AB"
        end

        persisted_method :initials
      }

      a_document = klass.create!
      stored = klass.collection.find(_id: a_document._id).first

      expect(stored["_initials"]).to eq("AB")
    }

    it("uses the :as option to name the persisted field") {
      klass = document {
        store_in collection: "documents"
        field :name
        persisted_method :name, as: :normalized_name
      }

      a_document = klass.create!(name: "Acme")
      stored = klass.collection.find(_id: a_document._id).first

      expect(stored["_normalized_name"]).to eq("Acme")
    }
  }

  describe("autosave_on") {
    it("saves the document after invoking the method") {
      klass = document {
        store_in collection: "documents"
        field :size, default: 1

        def resize(new_size)
          self.size = new_size
        end

        autosave_on :resize
      }

      a_document = klass.create!
      a_document.resize(5)
      stored = klass.collection.find(_id: a_document._id).first

      expect(stored["size"]).to eq(5)
    }

    it("returns the original method result") {
      klass = document {
        store_in collection: "documents"
        field :size, default: 1

        def resize(new_size)
          self.size = new_size
        end

        autosave_on :resize
      }

      expect(klass.create!.resize(5)).to eq(5)
    }
  }
}
