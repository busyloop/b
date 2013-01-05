module B
  # print results in TSV format
  class TsvWriter
    COLUMNS = [:group, :id, :rounds, :rate, :mean, :max, :min, :stddev, :x]
    def initialize(out=$stdout)
      @out = out
      printf COLUMNS.join("\t") + "\n"
    end

    def finish(job)
      printf COLUMNS.map { |c| job.send(c) }.join("\t") + "\n"
    end

    private
    def printf(*a)
      @out.printf *a
    end
  end

  # print results as a HTML table
  class HtmlWriter
    COLUMNS = [:group, :id, :rounds, :rate, :mean, :max, :min, :stddev, :x]

    def register(job)
      @todo = (@todo||0) +1
    end

    def initialize(out=$stdout)
      @out = out
      printf "<table>\n<tr>"
      COLUMNS.map { |c| printf "<th>#{c}</th>" }
      printf "</tr>\n"
    end

    def finish(job)
      @done = (@done||0) +1
      printf "<tr>"
      COLUMNS.map { |c| printf "<td>#{job.send(c)}</td>" }
      printf "</tr>\n"

      printf "</table>\n" if @done == @todo
    end

    private
    def printf(*a)
      @out.printf *a
    end
  end

  # print results in human friendly tabular format
  #
  # usage hints:
  # * set :multiply=>1 if you want output in seconds instead of milliseconds
  # * increase :column_width if you see indendation issues with wide values
  # * increase :max_label_width if you want to see more of your labels
  #
  class ConsoleWriter
    C_ID, C_LABEL, C_WIDTH, C_ROUND, C_MUL = *(0..4)

    def initialize(opts={})
      @opts = opts = { :out => $stderr, :multiply => 1000, :round => 2, 
                       :column_width => 11, :max_label_width => 20 }.merge(opts)

      @out = opts[:out]
      @max_label_width = opts[:max_label_width]

      @columns = [
        # C_ID    C_LABEL          C_WIDTH              C_ROUND       C_MUL
        [:id,     '',                               -1,          nil,             nil],
        [:rounds, 'rounds',                         -1,            0,               0],
        [:rate,   'r/s',           opts[:column_width], opts[:round],               1],
        [:mean,   'mean',          opts[:column_width], opts[:round], opts[:multiply]],
        [:max,    'max',           opts[:column_width], opts[:round], opts[:multiply]],
        [:min,    'min',           opts[:column_width], opts[:round], opts[:multiply]],
        [:stddev, "\u00b1 stddev", opts[:column_width], opts[:round], opts[:multiply]]
      ]

    end

    def register(job)
      # adjust width of first column (label) to fit longest label
      @columns[0][C_WIDTH] = [@columns[0][C_WIDTH], [job.id.length+2,@max_label_width].min].max
      # adjust width of second column (rounds) to fit widest value
      @columns[1][C_WIDTH] = [@columns[1][C_WIDTH], @columns[1][C_LABEL].length, job.rounds.to_s.length].max
    end

    def start(job)
      if @header_printed.nil?
        @header_printed = true

        # add :x column if this is a comparison
        if job.compare
          @columns << [:x, "x #{job.compare}", @opts[:column_width], @opts[:round], 1]
        end

        # print header
        header = '-' * (@columns.transpose[C_WIDTH].reduce(&:+) + @columns.length - 1)
        header[2..3+job.group.length] = " #{job.group} "
        printf header + "\n"
        @columns.each_with_index do |col, i|
          printf col[C_LABEL].rjust(col[C_WIDTH]) + ' '
        end
        printf "\n"
      end
      # print job.label
      printf "#{job.id[0..@columns[0][C_WIDTH]-1].ljust(@columns[0][C_WIDTH])} "
      # print rounds
      printf "%#{@columns[1][C_WIDTH]}d ", job.send(:rounds)
    end

    def finish(job)
      @columns.each_with_index do |col, i|
        next if 2 > i # first two columns were already printed in start()
        value = job.send(col[C_ID]) * col[C_MUL]

        printf "%#{col[C_WIDTH]}.#{col[C_ROUND]}f ", value
      end
      printf "\n"
    end

    private
    def printf(*a)
      @opts[:out].printf *a
    end
  end
end

