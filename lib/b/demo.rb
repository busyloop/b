#!/usr/bin/env ruby

require 'b'

puts "Source-code is here: #{__FILE__}"
puts

# Basic sleep benchmark
results = B.enchmark("Nap time; output in milliseconds", :rounds => 3) do
  job('sleep 0.1', :rounds => 10) { sleep 0.1 }
  job('sleep 0.5') { sleep 0.5 }
  job('sleep 1.0') { sleep 1.0 }
end

# Results are also returned as an Array of Hashes
#puts results

puts

# Same as above but display results in seconds instead of ms.
# HINT: You may also set :writer => nil if you want no output at all.
cw = B::ConsoleWriter.new({:multiply=>1, :round=>6})
result B.enchmark("Nap time; output in seconds", :output => cw, :rounds => 3) do
  job('sleep 0.1', :rounds => 10) { sleep 0.1 }
  job('sleep 0.5') { sleep 0.5 }
  job('sleep 1.0') { sleep 1.0 }
end

#puts results
puts

# Fibonacci snippets taken from http://stackoverflow.com/questions/6418524/fibonacci-one-liner
B.enchmark("Compare fibonacci implementations", :rounds => 500, :compare => :mean) do
  job 'fibonacci lambda A' do
    f = lambda { |x| x < 2 ? x : f.call(x-1) + f.call(x-2) }
    (0..16).each { |i| f.call(i) }
  end

  job 'fibonacci lambda B' do
    f = lambda { |n| (0..n).inject([1,0]) { |(a,b), _| [b, a+b] }[0] }
    (0..16).each { |i| f.call(i) }
  end

  job 'fibonacci hash' do
    f = Hash.new{ |h,k| h[k] = k < 2 ? k : h[k-1] + h[k-2] }
    (0..16).each { |i| f[i] }
  end
end

puts

B.enchmark('Compare string-concat methods (50k per round)', :rounds => 10, :compare => :mean) do
  job 'x = a << b << c' do
    50_000.times do
      a, b, c = 'a', 'b', 'c'
      x = a << b << c
    end
  end

  job 'x = "#{a}#{b}#{c}"' do
    50_000.times do
      a, b, c = 'a', 'b', 'c'
      x = "#{a}#{b}#{c}"
    end
  end

  job 'x = a+b+c' do
    50_000.times do
      a, b, c = 'a', 'b', 'c'
      x = a+b+c
    end
  end
end

