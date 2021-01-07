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
  def valid?(ulid : String)
    # is ulid the correct size AND only contain valid characters?
    ulid.size == TIME_LEN + RANDOM_LEN && (ulid =~ /[^0123456789ABCDEFGHJKMNPQRSTVWXYZ]/).nil?
  end

  # TODO #valid!(ulid : String) => returns nil, raise appropriate errors in invalid

  def seed_time(ulid : String)
    # decode and return the time that the ulid was created

    # e.g. ulid = "01B3EAF48P97R8MP9WS6MHDTZ3"
    # ulid[0..9] #=> "01B3EAF48P"
    # decode_time(ulid[0..9], TIME_LEN)
    time = Time.utc
    time.epoch_ms(ulid[0..9].to_i64(32))
  end

  def decode_time(string : String, len : Int32 = 10)
    # base64.decode(string)

    # take each letter in the string, find the index where it appears in ENCODING
    pp! chars = string.chars
    indexes = chars.map { |char|
      ENCODING.index(char)
    # char.index(ENCODING)
    }



    puts indexes
    ms = 0
    counter = len
    indexes.map do |index|
      pp! multiplier = (32.as(BigInt) ** counter.as(BigInt))
      counter -= 1
      # index * multiplier
      # pp! add = index.try &.* multiplier

      # mod = ms % ENCODING_LEN
      # pp! ms += ms + mod

    end
    puts "ms is #{ms}"
    # this is the base value - then covers to base10
    # this is the time in ms - covert that to a Time

  end

  def from_base32(data, map : Hash(Char, Int)) : Slice(UInt8)
    # mio = IO::Memory.new((data.bytesize / 8) * 5)
    mio = IO::Memory.new()

    # data.to_slice.select { |s| !['\n'.ord, '\r'.ord, '='.ord].includes?(s) }.each_slice(8) do |slice|
    data.to_slice.each_slice(8) do |slice|
      bits = 0_u64
      0.to(slice.size - 1) do |j|
        bits = bits | (map[slice[j].chr].to_u64 << (7 - j)*5)
      end

      mask = 0xFF_u64 << 32
      4.to(0) do |i|
        num = (bits & mask) >> i*8
        mio.write_byte(num.to_u8)
        mask = (mask >> 8)
      end
    end

    # Exclude trailing zero bytes
    sl = mio.to_slice
    while sl[-1] == 0
      sl = sl[0, sl.size - 1]
    end if sl.size > 0
    sl
  end

  private def encode_time(now : Time, len : Int32) : String
    pp! ms = now.to_unix_ms

    String.build do |io|
      len.times do
        pp! mod = ms % ENCODING_LEN
        io << ENCODING[mod]
        pp! ms = (ms - mod) // ENCODING_LEN
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
