$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'ubc_monitor/report'
require 'ubc_monitor/monitor'

#
# Monitor /proc/user_beancounters and send an email to the systems
# administrator if failcnt has increased since last time ubc_monitor
# was run.
#
# ubc_monitor uses a file (by default ~/.ubc_monitor) to keep track of
# user_beancounter fail counts. When running without this file (such
# as the first run) any fail count except 0 will be reported.
#
module UbcMonitor
  VERSION = '1.1.0'
end
