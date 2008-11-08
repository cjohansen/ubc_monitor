require 'optparse'

module UbcMonitor
  #
  # Run the monitor
  #
  class CLI
    def self.execute(arguments=[])
      options = { :file => File.expand_path('~/.ubc_monitor'),
                  :email_recipient => nil,
                  :email_subject => 'User beancounters has new errors' }

      OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          Monitor /proc/user_beancounters and send an email to the systems
          administrator if failcnt has increased since last time ubc_monitor
          was run.

          ubc_monitor uses a file (by default ~/.ubc_monitor) to keep track of
          user_beancounter fail counts. When running without this file (such
          as the first run) any fail count except 0 will be reported.

          Usage: #{File.basename(__FILE__)} [options]
        BANNER
        opts.on("-f", "--file [FILE]", "Log failcounts to this file, default\n" +
                "                                     is #{options[:file]}") { |f| options[:file] = File.expand_path f }
        opts.on("-n", "--no-log", "Don't log fail counts") { |r| options[:file] = nil }
        opts.on("-t", "--email-recipient [EMAIL]", "The recipient of report emails.\n" +
                "                                     If this is not set, no email is sent") { |r| options[:email_recipient] = r }
        opts.on("-s", "--email-subject [SUBJECT]", "Email subject. Default\n" +
                "                                     'value is #{options[:email_subject]}'") { |s| options[:email_subject] = s }
      end.parse!

      monitor =Ubc::Monitor.new(options)
      report = monitor.run

      if report.updated && !options[:email_recipient].nil?
        `echo '"#{report.to_s}"' | mail -s "#{options[:email_subject]}" "#{options[:email_recipient]}"`
      elsif report.updated
        puts report.to_s
      else
        puts "All's swell!"
      end
    end
  end
end
