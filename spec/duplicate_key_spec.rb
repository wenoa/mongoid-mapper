RSpec.describe(MongoidMapper::DuplicateKeyDetection) {
  let(:a_document_class) {
    Class.new {
      include Mongoid::Document

      store_in collection: "documents"

      field :value
    }
  }

  it("raises DuplicateKey when a write violates a unique index") {
    a_document_class.create!(_id: 1)

    expect { a_document_class.create!(_id: 1) }.to raise_error(Mongo::Error::DuplicateKey)
  }

  it("leaves other operation failures untouched") {
    expect { a_document_class.collection.aggregate([{ "$unknownStage" => 1 }]).to_a }
      .to raise_error(Mongo::Error::OperationFailure) { |error|
        expect(error).not_to be_a(Mongo::Error::DuplicateKey)
      }
  }
}
