require "./spec_helper"

describe ULID do
  describe ".generate : String" do
    it "should not raise an error" do
      begin
        ULID.generate
      rescue err
        err.should be_nil
      end
    end

    it "should return correct length" do
      ULID.generate.size.should eq 26
    end

    it "should contain only correct chars" do
      (ULID.generate =~ /[^0123456789ABCDEFGHJKMNPQRSTVWXYZ]/).should be_nil
    end

    it "should be in upcase" do
      res = ULID.generate

      res.should eq res.upcase
    end

    it "should be unique" do
      len = 1000
      arr = [] of String

      len.times do
        arr << ULID.generate
      end

      arr.uniq!

      arr.size.should eq len
    end

    it "should be sortable" do
      1000.times do
        ulid_1 = ULID.generate
        sleep 1.millisecond
        ulid_2 = ULID.generate

        (ulid_2 > ulid_1).should be_true
      end
    end

    it "should be seedable" do
      1000.times do
        ulid_1 = ULID.generate
        sleep 1.millisecond
        ulid_2 = ULID.generate(Time.utc - 1.second)

        (ulid_2 < ulid_1).should be_true
      end
    end

    it "validator should return true if a string is a valid ulid" do
      validator = ULID.valid?("01B3EAF48P97R8MP9WS6MHDTZ3")
      validator.should eq true
    end

    it "should not valdate invalid strings" do
      ULID.valid?("0").should eq false
      ULID.valid?("01B3EAF48P97R8MP9WS6MHDTZ32").should eq false
      ULID.valid?("01b3EAF48P97R8MP9WS6MHDTZ3").should eq false
      ULID.valid?("01B3EAF48P97R8MP9WS6MHDTZ").should eq false
      ULID.valid?("!@#$%^&*(").should eq false
      ULID.valid?("abcde").should eq false
      ULID.valid?("1234567890").should eq false
      ULID.valid?("01!3EAF48P97R8MP9WS8MHDTZ3").should eq false
    end

    # test time decode method
    it "should correctly decode a ulid's seed time", focus: true do
      # characters = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
      # map = {'0' => 0}
      # characters.chars.map { |char|
      #   map[char] = characters.index(char) if characters.index(char)
      # }
      # pp map

      # map = {'0' => 0,
      #        '1' => 1,
      #        '2' => 2,
      #        '3' => 3,
      #        '4' => 4,
      #        '5' => 5,
      #        '6' => 6,
      #        '7' => 7,
      #        '8' => 8,
      #        '9' => 9,
      #        'A' => 10,
      #        'B' => 11,
      #        'C' => 12,
      #        'D' => 13,
      #        'E' => 14,
      #        'F' => 15,
      #        'G' => 16,
      #        'H' => 17,
      #        'J' => 18,
      #        'K' => 19,
      #        'M' => 20,
      #        'N' => 21,
      #        'P' => 22,
      #        'Q' => 23,
      #        'R' => 24,
      #        'S' => 25,
      #        'T' => 26,
      #        'V' => 27,
      #        'W' => 28,
      #        'X' => 29,
      #        'Y' => 30,
      #        'Z' => 31 }

      # # hello = ULID.generate
      # # seedtime = ULID.seed_time(hello)
      # ms = ULID.from_base32("01B3EAF48P", map)
      # puts ms
      # puts ms.hexstring
      # puts ms.hexstring.to_i64(16)
      # ms2 = "01B3EAF48P".to_i64(32)
      # pp! ms2

      ms = ULID.seed_time("01EVDRF3VB5VD3211Z4DA112V9")
      puts ms
      # seedtime = ULID.seed_time("01B3EAF48P97R8MP9WS6MHDTZ3")
      # seedtime2 = ULID.seed_time("01EVDK4C0Q275A7AHHEVX02DCG")
      # .should be_a Time
      # ULID.seed_time("").should eq "your fave time"
    end
  end
end
