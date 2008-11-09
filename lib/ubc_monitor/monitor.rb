require 'net/smtp'
require 'ostruct'

# Namespace for the UbcMonitor script
module UbcMonitor

  # The Monitor provides an interface for inspecting /proc/user_beancounters as well
  # as a number of ways to report numbers that exceed given limits
  class Monitor

    def initialize(options = {})
      @options = ({ :file => nil }).merge(options)
    end

    # Run the monitor. Uses a UbcMonitor::Report object to track runs so as to not
    # report back errors that have already been reported
    def run
      filename = @options[:file]

      # Fetch data from the previous run, this will be the baseline
      report = filename.nil? ? Report.new : Report.load(filename)

      # Update the report by scanning /proc/user_beancounters
      report = scan(report)

      # Log report back to file and return report
      report.dump!(filename) unless filename.nil? || report.length == 0

      report
    end

    # Generate the /proc/user_beancounters report by running cat on it.
    # The method takes a UbcMonitor::Report object and returns a fresh report containing
    # only VPS's that have increased failcounts
    def scan(report = Report.new)
      vps = nil
      nrep = Report.new

      proc_user_beancounters.split("\n").each do |line|
        if line =~ /^\s+(\d+):/
          vps = $1.to_sym
        end

        # If the VPS is set, and the line (that is, the failcount) does not end with
        # a 0, set the resource/failcount pair
        unless vps.nil? || line =~ /\s0$/
          pieces = line.gsub(/^\s*(\d+:)?\s*/, '').split(/\s+/)
          resource = pieces[0].to_sym

          if report[vps, resource].nil? || report[vps, resource][:failcnt].nil? ||
             pieces[5].to_i > report[vps, resource][:failcnt]
            nrep[vps, resource] = { :held => pieces[1].to_i, :maxheld => pieces[2].to_i,
                                    :barrier => pieces[3].to_i, :limit => pieces[4].to_i,
                                    :failcnt => pieces[5].to_i }

            # Mark report as updated if failcount has increased
            nrep.updated = true if report[vps, resource].nil? || pieces[5].to_i > report[vps, resource][:failcnt]
          end
        end
      end

      nrep
    end

   private

    # Reading /proc/user_beancounters itself is separated to allow for better testability
    def proc_user_beancounters
      unless File.readable? '/proc/user_beancounters'
        puts "Unable to \'cat /proc/user_beancounters\'. Are you root?"
        exit
      end

      `cat /proc/user_beancounters`
    end
  end
end
