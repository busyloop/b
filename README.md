# B::enchmark [![Build Status](https://travis-ci.org/busyloop/b.png?branch=master)](https://travis-ci.org/busyloop/b) [![Dependency Status](https://gemnasium.com/busyloop/b.png)](https://gemnasium.com/busyloop/b) [![Gem Version](https://badge.fury.io/rb/b.svg)](https://badge.fury.io/rb/b)

A small, convenient benchmark-library.

## Features

* Displays relative performance; "B was 1.4x slower than A"

* Returns benchmark-results as Array of Hashes (for easy integration with your unit-tests or CI)

* Output can be customized with a simple Plugin-API (ships with plugins for TSV and HTML)

* High precision (via [hitimes](https://github.com/copiousfreetime/hitimes))


## Installation

`gem install b`

## Example

```ruby
#!/usr/bin/env ruby

require 'b'

B.enchmark('Sleep "performance"', :rounds => 10, :compare => :mean) do
  job '300ms' do
    sleep 0.3
  end

  job '100ms' do
    sleep 0.1
  end

  job '200ms' do
    sleep 0.2
  end
end
```

### Output:

```
-- Sleep "performance" ---------------------------------------------------------------
        rounds         r/s        mean         max         min    ± stddev      x mean
100ms       10        9.99      100.13      100.17      100.11        0.02        1.00
200ms       10        5.00      200.14      200.17      200.11        0.02        2.00
300ms       10        3.33      300.13      300.18      300.11        0.02        3.00
```

## Getting started

For advanced usage beyond the above example please look at the included demos:

1. Run `ruby -r b/demo -e0`
2. [demo.rb](https://github.com/busyloop/b/blob/master/lib/b/demo.rb)

## License (MIT)

Copyright (c) 2013 moe@busyloop.net

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
