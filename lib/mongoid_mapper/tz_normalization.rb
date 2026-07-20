# Default Time.zone to the OS TZ.
# Mongoid reads Time.zone (unless use_utc is on), and Time.now uses that
# same TZ, so read-back values and domain Times agree.
Time.zone_default = Time.find_zone!(ENV.fetch("TZ"))

# Serialize a read-back TimeWithZone like the equivalent domain Time.
module ActiveSupport
  class TimeWithZone
    def as_json(*, **)
      to_time
    end
  end
end
