require "b/version"
require "b/output_plugins"
require "hitimes"
require "blockenspiel"

module B
  class SanityViolation < RuntimeError; end

  DEFAULT_ROUNDS = 50

  def self.enchmark(id='Untitled Benchmark', opts={}, &block)
    opts = {:output => ConsoleWriter.new}.merge(opts)
    opts[:parent] = opts[:output]
    em = Enchmark.new(id, opts)
    Blockenspiel.invoke(block, em)
    em.run!
  end
 
  # B::Ase
  class Ase
    include Blockenspiel::DSL
    attr_reader :opts

    dsl_methods false

    def run!
      @children.map {|c| c.run! unless c.nil?} unless @children.nil?
      post_run if self.respond_to? :post_run
      @children.nil? ? [] : @children.map(&:to_h)
    end

    def register(job)
      @parent.register(job) if @parent.respond_to? :register
    end

    def start(job)
      @parent.start(job) if @parent.respond_to? :start
    end

    def finish(job)
      @parent.finish(job) if @parent.respond_to? :finish
    end
  end

  # B::Enchmark
  class Enchmark < B::Ase
    attr_reader :id

    def job(id, opts={}, &block)
      if opts[:rounds] and @compare
        raise SanityViolation, "Can not override :rounds on job '#{id}' when comparing on :#{@compare}!"
      end
      if opts[:compare]
        raise SanityViolation, "Can not override :compare in a job ('#{id}')"
      end
      opts = @opts.merge(opts)
      (@children ||= []) << Job.new(self, id, opts, block)
      self
    end

    dsl_methods false
    def initialize(id, opts={})
      @opts = {:rounds => DEFAULT_ROUNDS, :compare => nil}.merge(opts)
      @parent = opts[:parent]
      @id, @rounds, @compare = id, opts[:rounds], opts[:compare]
      @buffer = []
    end

    def post_run
      if @compare
        @buffer.sort! do |a,b|
          a.send(@compare) <=> b.send(@compare)
        end
      end
      @buffer.each do |job|
        job.x = job.send(@compare) / @buffer[0].send(@compare)
      end
      until @buffer.empty? do
        @parent.start @buffer[0]
        @parent.finish @buffer.shift
      end
    end

    def start(job)
      @compare.nil? ? super : @buffer << job
    end

    def finish(job)
      super if @compare.nil?
    end

    # B::Enchmark::Job
    class Job < B::Ase
      ATTRIBUTES = [:group, :id, :rounds, :rate, :mean, :max, :min, :stddev, :x, :compare]
      attr_reader *ATTRIBUTES
      attr_writer :x

      dsl_methods false
      def initialize(parent, id, opts, block)
        @opts = parent.opts.merge(opts)
        @parent, @block, @group, @id, @rounds, @compare = parent, block, parent.id, id, @opts[:rounds], @opts[:compare]
        @parent.register(self)
      end

      def run!
        tm = Hitimes::TimedMetric.new(nil)
        @parent.start self
        @opts[:rounds].times do
          tm.start
          @block.call
          tm.stop
        end
        @rate, @mean, @max, @min, @stddev = tm.rate, tm.mean, tm.max, tm.min, tm.stddev
        finish self
      end

      def to_h
        ATTRIBUTES.reduce({}) { |m,e|
          m[e] = instance_variable_get('@'+e.to_s)
          m
        }
      end
    end
  end
end

