require "./ulid/*"
require "big"

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
    return false unless ulid.upcase.chars.all? &.in?(ENCODING)

    return true
  end

  # Validate a string is a ULID
  #
  # ```
  # ULID.valid!("01B3EAF48P97R8MP9WS6MHDTZ3")
  # # => nil (or exception)
  # ```
  def valid!(ulid : String) : Nil
    # Incorrect length
    raise IncorrectLength.new("ULIDs must be 26 characters.") unless ulid.size == TIME_LEN + RANDOM_LEN
    # Invalid chars
    raise InvalidChars.new("Invalid characters found.") unless ulid.upcase.chars.all? &.in?(ENCODING)

    return nil
  end

  # Decode ULID seedtime
  #
  # ```
  # ULID.seed_time("01EX37YR1AAECCK45H5BXSCCN2")
  # # => 2021-01-28 00:58:08.810000000 UTC
  # ```
  def seed_time(ulid : String) : Time
    sum = ulid[0..9].reverse
      .each_char
      .with_index
      .sum(BigInt.new(0)) do |char, i|
        place_value = ENCODING.index(char) || 0
        BigInt.new(place_value.to_i64 * (32.to_big_i ** i))
      end
    Time.unix_ms(sum)
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
