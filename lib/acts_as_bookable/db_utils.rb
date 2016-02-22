module ActsAsBookable
  module DBUtils
    class << self
      def connection
        ActsAsBookable::Booking.connection
      end

      def using_postgresql?
        connection && connection.adapter_name == 'PostgreSQL'
      end

      def using_mysql?
        #We should probably use regex for mysql to support prehistoric adapters
        connection && connection.adapter_name == 'Mysql2'
      end

      def using_sqlite?
        connection && connection.adapter_name == 'SQLite'
      end

      def active_record4?
        ::ActiveRecord::VERSION::MAJOR == 4
      end

      def active_record5?
        ::ActiveRecord::VERSION::MAJOR == 5
      end

      def like_operator
        using_postgresql? ? 'ILIKE' : 'LIKE'
      end

      ##
      # Compare times according to the DB
      #
      def time_comparison (query, field, operator, time)
        if using_postgresql?
          query.where("#{field}::timestamp #{operator} ?::timestamp", time.to_time.utc.to_s)
        elsif using_sqlite?
          query.where("Datetime(#{field}) #{operator} Datetime('#{time.to_time.utc.iso8601}')")
        else
          query.where("#{field} #{operator} ?", time.to_time)
        end
      end

      # escape _ and % characters in strings, since these are wildcards in SQL.
      def escape_like(str)
        str.gsub(/[!%_]/) { |x| '!' + x }
      end
    end
  end
end
