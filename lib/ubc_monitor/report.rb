# Namespace for the UbcMonitor script
module Ubc

  # The Ubc::Report object holds information on the current state of failcounts in the
  # /proc/user_beancounts table
  #
  # The Report is able to generate different views of the data it represents. It can use a
  # file to log reports between uses in order to only report on failcounts that have increased
  # since its last run.
  #
  # The log file contains sections for each VPS currently having failcounts. The VPS id introduces
  # the section, followed by a newline and then resource: <failcount> pairs, one on each line.
  # The VPS block is terminated by a double newline.
  #
  # Example file:
  #
  #  101
  #  privvmpages: 2
  #  kmemsize: 4
  #
  #  102
  #  privvmpages: 3
  #
  class Report
    attr_accessor :updated

    # Setup a new Report
    def initialize
      @resource_counts = {}
      @updated = false
    end

    # Parse the ubc_monitor logfile and return a UbcMonitor::Report object
    def self.load(file)
      report = Report.new
      vps = nil

      return report if file.nil? || !File.exist?(file)

      IO.read(file).each do |line|
        if line =~ /^\s*$/
          # This is a blank line separating VPS instances. Reset vps
          vps = nil
        elsif vps.nil?
          # If the VPS has been reset, this line is expected to contain a new VPS id
          vps = line.strip.to_sym
        else
          # Otherwise, this is a resource: <value> line belonging to the current VPS
          resource, failcnt = line.split(':')
          report[vps, resource.to_sym] = { :failcnt => failcnt.to_i }
        end
      end

      return report
    end

    # Dump the report back to file
    def dump!(file)
      File.open(file, 'w+') do |f|
        @resource_counts.each_pair do |vps, content|
          # Each VPS in its own section, starting with the VPS id and followed by all the
          # resources currently keeping a failcount, then terminated by a blank line.
          # Resources whose failcounts are 0 are not dumped
          str = ''
          content.each_pair { |resource, numbers| str += "#{resource}: #{numbers[:failcnt]}\n" unless numbers[:failcnt] == 0 }
          f.puts vps, str, '' unless str == ''
        end
      end
    end

    # Add a resource failcount. If resource and failcnt are nil, only allocate room for
    # the VPS. Returns the VPS symbol
    #
    # +vps+ and +resource+ are both symbols while +limits+ should be a hash (unless
    # +resource+ and +limits+ are both +nil+ in which case no resource/limits pair
    # is actually appended). The hash can contain the following values:
    # :held, :maxheld, :barrier, :limit, :failcnt
    def []=(vps, resource, limits)
      @resource_counts[vps] = {} if @resource_counts[vps].nil?
      @resource_counts[vps][resource] = limits
      vps
    end

    # Fetch the ubc numbers array for a given VPS
    def [](vps, resource = nil)
      has_vps = @resource_counts.key? vps
      has_resource = has_vps && @resource_counts[vps].key?(resource)

      return resource.nil? ?
        (has_vps ? @resource_counts[vps] : nil) :
          (has_resource ? @resource_counts[vps][resource] : nil)
    end

    # Returns true if no VPS's has any reported failcounts
    def empty?
      return length == 0
    end

    # Returns the number of VPSs in the report
    def length
      return @resource_counts.length
    end

    # Alias of +Ubc::Monitor#length+
    alias size length

    # Return a nicely formatted report
    def to_s
      str = ''

      @resource_counts.dup.each do |vps, content|
        str += "VPS #{vps} has increased fail counts:\n"
        str += "#{'resource'.rjust(20)}#{'held'.rjust(15)}#{'maxheld'.rjust(15)}" +
               "#{'barrier'.rjust(15)}#{'limit'.rjust(15)}#{'failcount'.rjust(15)}\n"

        content.each_pair do |resource, report|
          str += resource.to_s.rjust(20)
          [:held, :maxheld, :barrier, :limit, :failcnt].each { |sym| str += report[sym].to_s.rjust(15) }
          str += "\n"
        end

        str += "\n"
      end

      str
    end
  end
end
