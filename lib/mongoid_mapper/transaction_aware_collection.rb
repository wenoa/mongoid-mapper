# MongoDB driver aggregations did not participate in the sessions Mongoid created for its
# transactions, so they could not see the changes pending commit. This module injects the active
# transaction's session into every aggregation, ensuring they all see the changes pending in the
# active transaction.
module MongoidMapper
  module TransactionAwareCollection
    def aggregate(pipeline, options = {})
      session = Mongoid::Threaded.get_session(client:)
      options.merge!(session:) unless options.key?(:session)

      super
    end
  end

  Mongo::Collection.prepend(TransactionAwareCollection)
end
