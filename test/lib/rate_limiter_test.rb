require "test_helper"
require "rate_limiter"

class RateLimiterTest < ActiveSupport::TestCase
  setup do
    @now = 100.0
    @sleeps = []
    @limiter = RateLimiter.new(
      interval: 1.0,
      clock: -> { @now },
      sleeper: ->(seconds) { @sleeps << seconds; @now += seconds }
    )
  end

  test "lets the first call through immediately" do
    @limiter.wait

    assert_empty @sleeps
  end

  test "waits out the rest of the interval between calls" do
    @limiter.wait
    @now += 0.25
    @limiter.wait

    assert_equal [ 0.75 ], @sleeps
  end

  test "spaces back-to-back calls one interval apart" do
    3.times { @limiter.wait }

    assert_equal [ 1.0, 1.0 ], @sleeps
  end

  test "doesn't wait once the interval has passed" do
    @limiter.wait
    @now += 5
    @limiter.wait

    assert_empty @sleeps
  end
end
