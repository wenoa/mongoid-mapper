# Mongoid Mapper

DataMapper-style persistence layer over `Mongoid`.

```ruby
gem "mongoid_mapper", github: "wenoa/mongoid-mapper"
```

When the gem is required, `Mongoid::Document` is reopened to inject extra capabilities into any class
that includes it:

- `field` removes the previously defined methods before redefining a field.
- `persisted_method` persists a method's result into a field via `before_save`.
- `autosave_on` saves the document after invoking a method.
- Forces Mongoid's `initialize`, for domain models with their own constructors.

In addition, `TransactionAwareCollection` makes MongoDB driver aggregations participate in the active
transaction, so they see the changes pending commit.

## Tests

The suite expects a MongoDB replica set running on the default port:

```sh
docker run --rm -p 27017:27017 --hostname localhost mongodb/mongodb-atlas-local:8.0.4
```
