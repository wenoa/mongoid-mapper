# MongoDB driver aggregations did not participate in the sessions Mongoid created for its
# transactions, so they could not see the changes pending commit. TransactionAwareCollection injects
# the active transaction's session into every aggregation, ensuring they all see the changes pending
# in the active transaction.
RSpec.describe(MongoidMapper::TransactionAwareCollection) {
  let(:a_document_class) {
    Class.new {
      include Mongoid::Document

      store_in collection: "documents"

      field :value
    }
  }

  let(:a_document) { a_document_class.create!(value: "a") }

  it("aggregations see the changes pending in the transaction") {
    Mongoid.transaction {
      a_document.update!(value: "b")

      updated_document = a_document_class.collection.aggregate([]).first

      expect(updated_document["value"]).to eq("b")
    }
  }

  it("respects the session explicitly provided in the options") {
    a_document

    result = a_document_class.collection.aggregate([], session: nil).to_a

    expect(result.first["value"]).to eq("a")
  }
}
