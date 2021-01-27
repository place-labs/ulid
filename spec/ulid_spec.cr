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

    describe ".valid? : Bool" do
      it "validate a valid string" do
        ULID.valid?("01B3EAF48P97R8MP9WS6MHDTZ3").should be_true
      end

      it "should not validate invalid strings" do
        ULID.valid?("0").should be_false
        ULID.valid?("01B3EAF48P97R8MP9WS6MHDTZ32").should be_false
        ULID.valid?("01b3EAF48P97R8MP9WS6MHDTZ3").should be_true # ulids are not case sensitive
        ULID.valid?("01B3EAF48P97R8MP9WS6MHDTZ").should be_false
        ULID.valid?("!@#$%^&*(").should be_false
        ULID.valid?("abcde").should be_false
        ULID.valid?("1234567890").should be_false
        ULID.valid?("01!3EAF48P97R8MP9WS8MHDTZ3").should be_false
        ULID.valid?("").should be_false
      end
    end

    describe ".seedtime : Time" do
      it "should correctly decode seed time" do
        seedtime = ULID.seed_time("01B3EAF48P97R8MP9WS6MHDTZ3")
        seedtime.should be_a Time
        seedtime.should eq Time.utc(2016, 12, 8, 4, 18, 39, nanosecond: 1000000)

        seedtime1 = ULID.seed_time("01EVDRF3VB5VD3211Z4DA112V9")
        seedtime1.should be_a Time
        seedtime1.should eq Time.utc(2021, 2, 26, 0, 22, 56, nanosecond: 235000000)

        seedtime2 = ULID.seed_time("01EVDK4C0Q275A7AHHEVX02DCG")
        seedtime2.should be_a Time
        seedtime2.should eq Time.utc(2021, 2, 25, 22, 14, 43, nanosecond: 994000000)
      end
    end
  end
end
