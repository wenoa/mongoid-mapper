module MongoidMapper
  module DuplicateKeyDetection
    def operation_failure_class
      return Mongo::Error::DuplicateKey if parser.code == 11_000

      super
    end
  end

  Mongo::Operation::Result.prepend(DuplicateKeyDetection)
end
