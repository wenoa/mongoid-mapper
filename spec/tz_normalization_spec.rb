RSpec.describe("TZ normalization") {
  it("derives the application clock from the operating system TZ") {
    expect(Time.zone.name).to eq(ENV.fetch("TZ"))
  }

  it("serializes a recovered time the same as the domain Time it was persisted from") {
    klass = Class.new {
      include Mongoid::Document

      store_in collection: "documents"
      field :at, type: Time
    }
    domain_time = Time.now # a plain Time, as the domain clock hands it over

    stored = klass.create!(at: domain_time)
    recovered = klass.find(stored._id)

    expect(recovered.at).to be_a(ActiveSupport::TimeWithZone) # Mongoid hands back a TimeWithZone
    expect(recovered.at.to_json).to eq(domain_time.to_json)
  }
}
