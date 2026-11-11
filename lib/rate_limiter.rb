class RateLimiter
  def initialize(interval:, clock: -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) }, sleeper: ->(seconds) { sleep(seconds) })
    @interval = interval
    @clock = clock
    @sleeper = sleeper
    @mutex = Mutex.new
    @available_at = -Float::INFINITY
  end

  def wait
    @mutex.synchronize do
      now = @clock.call
      @sleeper.call(@available_at - now) if @available_at > now
      @available_at = [ now, @available_at ].max + @interval
    end
  end
end
