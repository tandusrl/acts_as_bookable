module ActsAsBookable
  ##
  # Provide helper functions to manage operations and queries related to times
  # and schedules
  #
  module TimeHelpers
    class << self
      ##
      # Check if time is included in a time interval. The ending time is excluded
      #
      # @param time The time to check
      # @param interval_start The beginning time of the interval to match against
      # @param interval_end The ending time of the interval to match against
      #
      def time_in_interval? (time, interval_start, interval_end)
        time >= interval_start && time < interval_end
      end

      ##
      # Check if there is an occurrence of a schedule that contains a time interval
      #
      # @param schedule The schedule
      # @param interval_start The beginning Time of the interval
      # @param interval_end The ending Time of the interval
      # @return true if the interval falls within an occurrence of the schedule, otherwise false
      #
      def interval_in_schedule?(schedule, interval_start, interval_end)
        # Check if interval_start and interval_end falls within any occurrence
        return false if(!time_in_schedule?(schedule,interval_start) || !time_in_schedule?(schedule,interval_end))

        # Check if both interval_start and interval_end falls within the SAME occurrence
        between = schedule.occurrences_between(interval_start, interval_end, true)
        contains = false
        between.each do |oc|
          oc_end = oc + schedule.duration
          contains = true if (time_in_interval?(interval_start,oc,oc_end) && time_in_interval?(interval_end,oc,oc_end))
          break if contains
        end

        contains
      end

      ##
      # Check if there is an occurrence of a schedule that contains a time
      # @param schedule The schedule
      # @param time The time
      # @return true if the time falls within an occurrence of the schedule, otherwise false
      #
      def time_in_schedule?(schedule, time)
        return schedule.occurring_at? time
      end
    end
  end
end
