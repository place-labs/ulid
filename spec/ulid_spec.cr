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

    # test seed_time method
    it "should correctly decode a ulid's seed time" do
      seedtime = ULID.seed_time("01B3EAF48P97R8MP9WS6MHDTZ3")
      seedtime.should be_a Time
      # seedtime.should eq (2016-12-08 04:18:39.001000000 UTC)

      seedtime1 = ULID.seed_time("01EVDRF3VB5VD3211Z4DA112V9")
      seedtime1.should be_a Time
      # seedtime1.should eq 2021-02-26 00:22:56 UTC

      seedtime2 = ULID.seed_time("01EVDK4C0Q275A7AHHEVX02DCG")
      seedtime2.should be_a Time
      # seedtime2.should eq 2021-02-25 22:14:43 UTC
    end
  end
end
