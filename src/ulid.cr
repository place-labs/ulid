require "./ulid/*"

module ULID
  extend self

  # Crockford's Base32
  private ENCODING     = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
  private ENCODING_LEN = ENCODING.size
  private TIME_LEN     = 10
  private RANDOM_LEN   = 16

  # Generate a ULID
  #
  # ```
  # ULID.generate
  # # => "01B3EAF48P97R8MP9WS6MHDTZ3"
  # ```
  def generate(seed_time : Time = Time.utc) : String
    encode_time(seed_time, TIME_LEN) + encode_random(RANDOM_LEN)
  end

  # Validate a string is a ULID
  #
  # ```
  # ULID.valid?("01B3EAF48P97R8MP9WS6MHDTZ3")
  # # => true
  # ```
  def valid?(ulid : String) : Bool
    # Incorrect length
    return false unless ulid.size == TIME_LEN + RANDOM_LEN
    # Invalid chars
    return false unless ulid.chars.all? &.in?(ENCODING)
    
    return true
  end

  # TODO #valid!(ulid : String) => returns nil, raise appropriate errors in invalid

  # Decode ULID seedtime
  #
  # ```
  # ULID.seed_time("01EVDK4C0Q275A7AHHEVX02DCG")
  # # => 2021-02-25 22:14:43.994000000 UTC
  # ```
  def seed_time(ulid : String) : Time
    Time.unix_ms(ulid[0..9].to_i64(32))
  end

  private def encode_time(now : Time, len : Int32) : String
    ms = now.to_unix_ms

    String.build do |io|
      len.times do
        mod = ms % ENCODING_LEN
        io << ENCODING[mod]
        ms = (ms - mod) // ENCODING_LEN
      end
    end.reverse
  end

  private def encode_random(len : Int32) : String
    String.build do |io|
      len.times do
        rand = Random.rand(ENCODING_LEN)
        io << ENCODING[rand]
      end
    end.reverse
  end
end
