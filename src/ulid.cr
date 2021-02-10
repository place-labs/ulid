require "./ulid/*"

module ULID
  extend self

  # Crockford's Base32
  private ENCODING     = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
  private ENCODING_LEN = ENCODING.size.to_i64
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
    # Incorrect length && Invalid chars
    ulid.size == TIME_LEN + RANDOM_LEN && ulid.upcase.chars.all? &.in?(ENCODING)
  end

  # Validate a string is a ULID
  #
  # ```
  # ULID.valid!("01B3EAF48P97R8MP9WS6MHDTZ3")
  # # => nil (or exception)
  # ```
  def validate!(ulid : String) : Nil
    # Incorrect length
    raise IncorrectLength.new() unless ulid.size == TIME_LEN + RANDOM_LEN
    # Invalid chars
    raise InvalidChars.new() unless ulid.upcase.chars.all? &.in?(ENCODING)

    nil
  end

  class IncorrectLength < Exception
    def initialize(message = "ULIDs must be 26 characters.")
      super(message)
    end
  end

  class InvalidChars < Exception
    def initialize(message = "Invalid characters found.")
      super(message)
    end
  end

  # Decode ULID seedtime
  #
  # ```
  # ULID.seed_time("01EX37YR1AAECCK45H5BXSCCN2")
  # # => 2021-01-28 00:58:08.810000000 UTC
  # ```
  def seed_time(ulid : String) : Time
    sum = ulid[0..TIME_LEN-1].reverse
      .each_char
      .with_index
      .sum(0_i64) do |char, i|
        ord = ENCODING.index(char) || raise InvalidChars.new("Character: #{char} not part of Crockford's Base32.")
        ord.to_i64 * (ENCODING_LEN ** i)
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
