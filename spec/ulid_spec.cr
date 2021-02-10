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
  end

  describe ".valid?" do
    it "should validate a valid string" do
      ULID.valid?("01B3EAF48P97R8MP9WS6MHDTZ3").should be_true
    end

    it "should be case insensitive" do
      ULID.valid?("01b3EAF48P97R8MP9WS6MHDTZ3").should be_true
    end

    it "should detect incorrect length" do
      ["0", "01B3EAF48P97R8MP9WS6MHDTZ32", "01B3EAF48P97R8MP9WS6MHDTZ32", "!@#$%^&*(", "abcde", "1234567890", ""].each { |i|
        ULID.valid?(i).should be_false
      }
    end

    it "should detect invalid characters" do
      ["01!3EAF48P97R8MP9WS8MHDTZ3", "01I3EAF48P97R8MP9WS8MHDTZ3", "01O3EAF48P97R8MP9WS8MHDTZ3"].each { |i|
        ULID.valid?(i).should be_false
      }
    end
  end

  describe ".validate!" do
    it "should validate a valid string" do
      ULID.validate!("01B3EAF48P97R8MP9WS6MHDTZ3").should be_nil
    end

    it "should be case insensitive" do
      ULID.validate!("01b3EAF48P97R8MP9WS6MHDTZ3").should be_nil
    end

    it "should detect incorrect length" do
      ["0", "01B3EAF48P97R8MP9WS6MHDTZ32", "01B3EAF48P97R8MP9WS6MHDTZ32", "!@#$%^&*(", "abcde", "1234567890", ""]. each { |i|
        expect_raises(ULID::IncorrectLength) { ULID.validate!(i) }
      }
    end

    it "should detect invalid characters" do
      ["01!3EAF48P97R8MP9WS8MHDTZ3", "01I3EAF48P97R8MP9WS8MHDTZ3", "01O3EAF48P97R8MP9WS8MHDTZ3"].each { |i|
        expect_raises(ULID::InvalidChars) { ULID.validate!(i) }
      }
    end
  end

  describe ".seed_time" do
    it "should correctly decode seed time" do
      seedtime = ULID.seed_time("01B3EAF48P97R8MP9WS6MHDTZ3")
      seedtime.should be_a Time
      seedtime.should eq Time.unix_ms(1481170718998)

      seedtime1 = ULID.seed_time("01EVDRF3VB5VD3211Z4DA112V9")
      seedtime1.should be_a Time
      seedtime1.should eq Time.unix_ms(1610000863083)

      seedtime2 = ULID.seed_time("01EX37YR1AAECCK45H5BXSCCN2")
      seedtime2.should be_a Time
      seedtime2.should eq Time.unix_ms(1611795488810)
    end

    it "should encode and decode a specific seed time" do 
      time = Time.unix_ms(1481170718998)
      ulid = ULID.generate(time)
      ULID.seed_time(ulid).should eq time

      time2 = Time.unix_ms(1610000863083)
      ulid2 = ULID.generate(time2)
      ULID.seed_time(ulid2).should eq time2
    end
  end
end
