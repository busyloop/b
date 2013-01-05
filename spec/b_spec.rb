require 'spec_helper'

describe B do
  describe :enchmark do
    before (:each) do
      StdioTrap.trap!
    end

    after (:each) do
      StdioTrap.release!
    end

    describe 'with opts={}' do
      let(:test_opts) { {} }
      describe :job do
        it 'raises SanityViolation when trying to override :compare' do
          lambda {
            B.enchmark do
              job('a', {:compare => :min}) {}
            end
          }.should raise_error B::SanityViolation
        end
  
        it 'is called B::DEFAULT_ROUNDS times by default' do
          a = mock(:a)
          a.should_receive(:call).exactly(B::DEFAULT_ROUNDS).times
          B.enchmark do
            job('a') { a.call }
          end
        end

        it 'can override :rounds' do
          a, b, c, d = mock(:a), mock(:b), mock(:c), mock(:d)
          a.should_receive(:call).exactly(B::DEFAULT_ROUNDS).times
          b.should_receive(:call).exactly(5).times
          c.should_receive(:call).exactly(B::DEFAULT_ROUNDS).times
          d.should_receive(:call).exactly(10).times
          B.enchmark do
            job('a')                { a.call }
            job('b', :rounds => 5)  { b.call }
            job('c')                { c.call }
            job('d', :rounds => 10) { d.call }
          end
        end
      end

      describe "return value" do
        it "is an Array of well-formed Hashes" do
          results = B.enchmark do
            job('a') {}
            job('b') {}
          end
          results.length.should == 2
          results.each do |h|
            h.should be_a Hash
            B::Enchmark::Job::ATTRIBUTES.each do |a|
              h.should have_key a
            end
          end
        end

        it "retval[*][:x] is nil" do
          results = B.enchmark do
            job('a') {}
            job('b') {}
          end
          results.each do |h|
            B::Enchmark::Job::ATTRIBUTES.each do |a|
              h[:x].should == nil
            end
          end
        end

        it "looks about correct (timing)" do
          results = B.enchmark('', test_opts) do
            job('a', :rounds => 2 ) { sleep 0.5 }
            job('b', :rounds => 1 ) { sleep 1 }
          end
          results.length.should == 2

          results[0][:rounds].should == 2
          results[0][:mean].should be >= 0.5
          results[0][:mean].should be <= 1.0

          results[1][:rounds].should == 1
          results[1][:mean].should be >= 1.0
          results[1][:mean].should be <= 1.5
        end
      end

      describe "stdout" do
        it "is empty" do
          B.enchmark do
            job('a') {}
          end
          StdioTrap.stdout.should == ''
        end
      end

      describe "stderr" do
        it "looks like output from the default ConsoleWriter" do
          B.enchmark do
            job('a') {}
          end
          StdioTrap.stderr.should match /^-- Untitled Benchmark/
          StdioTrap.stderr.should match /rounds/
          StdioTrap.stderr.should match /stddev/
          StdioTrap.stderr.lines.count.should == 3
        end
      end
    end

    describe 'with opts={:compare => :mean, :rounds => 1}' do
      let(:test_opts) { {:compare => :mean, :rounds => 1} }

      describe :job do
        it 'raises SanityViolation when trying to override :compare' do
          lambda {
            B.enchmark('', test_opts) do
              job('a', {:compare => :min}) {}
            end
          }.should raise_error B::SanityViolation
        end

        it 'raises SanityViolation when trying to override :rounds' do
          lambda {
            B.enchmark('', test_opts) do
              job('a', :rounds => 2) {}
            end
          }.should raise_error B::SanityViolation
        end
      end

      describe "return value" do
        it "is an Array of well-formed Hashes" do
          results = B.enchmark('', test_opts) do
            job('a') {}
            job('b') {}
          end

          results.length.should == 2
          results.each do |h|
            h.should be_a Hash
            B::Enchmark::Job::ATTRIBUTES.each do |a|
              h.should have_key a
            end
          end
        end

        it "retval[*][:x] is not nil" do
          results = B.enchmark('', test_opts) do
            job('a') {}
            job('b') {}
          end
          results.each do |h|
            B::Enchmark::Job::ATTRIBUTES.each do |a|
              h.should_not == nil
            end
          end
        end

        it "is sorted on :mean (and :x)" do
          results = B.enchmark('', test_opts) do
            job('b') { sleep 0.3 }
            job('a') { sleep 0.1 }
            job('d') { sleep 0.9 }
            job('c') { sleep 0.6 }
          end
          as_returned = results.collect {|e| [e[:mean], e[:id]]}
          sorted = as_returned.sort_by {|e| e[0]}
          sorted.collect {|e| e[1]}.should == ['a', 'b', 'c', 'd']

          as_returned = results.collect {|e| [e[:x], e[:id]]}
          sorted = as_returned.sort_by {|e| e[0]}
          sorted.collect {|e| e[1]}.should == ['a', 'b', 'c', 'd']
        end

     end
    end

    describe 'with opts={:output => nil}' do
      let(:test_opts) { { :output=> nil } }

      it 'doesn\'t write to stdout nor stderr' do
        B.enchmark('', test_opts) do
          job('a') {}
        end
        StdioTrap.stdout.should == ''
        StdioTrap.stderr.should == ''
      end
    end
  end

  describe 'TsvWriter' do
    before (:each) do
      StdioTrap.trap!
      output = B::TsvWriter.new
      B.enchmark('foobar', :output => output) do
        job('a') {}
      end
      @stdio = StdioTrap.release!
    end

    describe "stdout" do
      it "looks like output from TsvWriter" do
        @stdio[:stdout].should match /^group\tid\trounds\trate\tmean\tmax\tmin\tstddev\tx\n/
        @stdio[:stdout].split("\n")[1].should match /^foobar\t/
        @stdio[:stdout].lines.count.should == 2
      end
    end

    describe "stderr" do
      it "is empty" do
        @stdio[:stderr].should == ''
      end
    end
  end

  describe 'HtmlWriter' do
    before (:each) do
      StdioTrap.trap!
      output = B::HtmlWriter.new
      B.enchmark('foobar', :output => output) do
        job('a') {}
      end
      @stdio = StdioTrap.release!
    end

    describe "stdout" do
      it "looks like output from TsvWriter" do
        @stdio[:stdout].should match /^<table>\n<tr><th>/
        @stdio[:stdout].split("\n")[2].should match /^<tr><td>foobar<\/td>/
        @stdio[:stdout].lines.count.should == 4
      end
    end

    describe "stderr" do
      it "is empty" do
        @stdio[:stderr].should == ''
      end
    end

  end
end
