require File.dirname(__FILE__) + '/test_helper.rb'

# Mock cat /proc/user_beancounters
module Ubc
  class Monitor
    def proc_user_beancounters
      <<-EOF
Version: 2.5
       uid  resource                     held              maxheld              barrier                limit              failcnt
      101:  kmemsize                  1477444              2608200              8192000              9011200                    3
            lockedpages                     0                    0                 2048                 2048                    4
            numtcpsock                      4                    6                  250                  250                    0
            numflock                        5                    6                  200                  220                    0
            numpty                          0                    0                   32                   32                   13
            numsiginfo                      0                    2                  256                  256                    0
            tcpsndbuf                   69504                90168              2682880              5242880                    0
            tcprcvbuf                   65536                    0              2682880              5242880                    0
      102:  kmemsize                  5749546              6930244             18000000             48000000                    0
            lockedpages                     0                    0                 2048                 2048                    0
            tcprcvbuf                   81920                    0              2682880              5242880                    0
            othersockbuf                 4592                11200               751616             20311616                    0
            dgramrcvbuf                     0                 8440               131072               131072                  345
            numothersock                    3                   10                  250                  250                    0
            dcachesize                      0                    0              2097152              2158592                    0
      103:  kmemsize                  5749546              6930244             18000000             48000000                    0
            lockedpages                     0                    0                 2048                 2048                    0
            tcprcvbuf                   81920                    0              2682880              5242880                    0
      EOF
    end
  end
end

class TestUbcMonitor < Test::Unit::TestCase

  def test_init_monitor
    monitor = Ubc::Monitor.new
    assert_not_nil monitor
  end

  def test_monitor_scan
    monitor = Ubc::Monitor.new
    report = monitor.scan

    assert_equal 2, report.length
    assert_equal 3, report[:'101'].length
    assert_equal 1, report[:'102'].length

    report[:'101', :kmemsize] = { :failcnt => 0 }
    report[:'101', :numpty] = { :failcnt => 4 }
    nrep = monitor.scan report

    assert_equal 1, nrep.length
    assert_equal 2, nrep[:'101'].length
    assert_equal 13, nrep[:'101', :numpty][:failcnt]
    assert_equal 3, nrep[:'101', :kmemsize][:failcnt]
  end

  def test_run
    monitor = Ubc::Monitor.new
    report = monitor.run

    assert_equal 2, report.length
    assert_equal 3, report[:'101'].length
    assert_equal 1, report[:'102'].length

    filename = '.ubc_test_file'
    monitor = Ubc::Monitor.new :file => filename
    report = monitor.run

    assert_equal 2, report.length
    assert_equal 3, report[:'101'].length
    assert_equal 1, report[:'102'].length

    contents = <<-EOF
101
kmemsize: 3
lockedpages: 4
numpty: 13

102
dgramrcvbuf: 345

    EOF

    assert_equal contents.split("\n").sort, IO.read(filename).split("\n").sort

    # Again, this time the report should be empty, and the file unchanged
    atime = File.new(filename).atime
    monitor = Ubc::Monitor.new :file => filename
    report = monitor.run

    assert_equal 0, report.length
    assert_equal atime, File.new(filename).atime

    File.delete filename
  end

  def test_to_s
    monitor = Ubc::Monitor.new
    report = monitor.run

    content = <<-EOF
VPS 101 has increased fail counts:
            resource           held        maxheld        barrier          limit      failcount
            kmemsize        1477444        2608200        8192000        9011200              3
         lockedpages              0              0           2048           2048              4
              numpty              0              0             32             32             13

VPS 102 has increased fail counts:
            resource           held        maxheld        barrier          limit      failcount
         dgramrcvbuf              0           8440         131072         131072            345

    EOF

    assert_equal content.split("\n").sort, report.to_s.split("\n").sort
  end
end
