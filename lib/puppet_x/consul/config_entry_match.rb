require 'puppet_x'

module PuppetX::Consul
  # Compares the desired state of a config entry with what Consul returns.
  #
  # Consul adds fields of its own (CreateIndex, ModifyIndex, Hash, defaults inside
  # list elements, ...) and sorts some lists (intention sources by precedence), so
  # this is a subset match instead of an equality check.
  module ConfigEntryMatch
    # @param should [Object] desired value
    # @param is [Object] value returned by Consul
    # @param unordered_keys [Array<String>] keys holding arrays that are compared regardless of order
    # @param key [String, nil] key under which `should` was found, used to look up unordered_keys
    # @return [Boolean] true when `is` contains everything specified in `should`
    def self.subset?(should, is, unordered_keys = [], key = nil)
      case should
      when Hash
        return false unless is.is_a?(Hash)

        should.all? { |k, v| subset?(v, is[k], unordered_keys, k) }
      when Array
        return false unless is.is_a?(Array) && is.length == should.length

        if unordered_keys.include?(key)
          unordered_match?(should, is, unordered_keys)
        else
          should.each_with_index.all? { |v, i| subset?(v, is[i], unordered_keys) }
        end
      else
        should == is || duration_match?(should, is)
      end
    end

    DURATION = %r{\A(?:\d+(?:\.\d+)?(?:ns|us|µs|ms|s|m|h))+\z}.freeze
    DURATION_UNITS = { 'ns' => 1, 'us' => 1_000, 'µs' => 1_000, 'ms' => 1_000_000, 's' => 1_000_000_000, 'm' => 60_000_000_000, 'h' => 3_600_000_000_000 }.freeze

    # Consul takes durations like `30s` but returns them as nanoseconds
    def self.duration_match?(should, is)
      return false unless should.is_a?(String) && is.is_a?(Integer) && DURATION.match?(should)

      should.scan(%r{(\d+(?:\.\d+)?)(ns|us|µs|ms|s|m|h)}).sum { |amount, unit| amount.to_f * DURATION_UNITS[unit] }.round == is
    end

    # Pairs every element of `should` with a distinct element of `is`; backtracks as a
    # lenient `should` element can match more than one element of `is`.
    def self.unordered_match?(should, is, unordered_keys)
      return true if should.empty?

      head, *rest = should
      is.each_index.any? do |i|
        subset?(head, is[i], unordered_keys) && unordered_match?(rest, is.reject.with_index { |_, j| j == i }, unordered_keys)
      end
    end
  end
end
