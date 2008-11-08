require File.dirname(__FILE__) + '/test_helper.rb'

class TestUbcReport < Test::Unit::TestCase

  def test_init_report
    report = Ubc::Report.new
    assert_not_nil report
    assert report.empty?
  end

  def test_append
    report = Ubc::Report.new
    assert report.empty?

    assert :'196', report[:'196', :privvmpages] = { :failcnt => 4 }
    assert !report.empty?
  end

  def test_getter
    report = Ubc::Report.new
    numbers = { :failcnt => 4 }
    vps = :'196'
    report[vps, :privvmpages] = numbers
    assert_equal numbers, report[:'196', :privvmpages]

    # More complex hash
    numbers = { :held => 1000, :maxheld => 1012, :barrier => 4000, :limit => 4050, :failcnt => 4 }
    report[vps, :privvmpages] = numbers
    assert_equal numbers, report[vps, :privvmpages]

    assert !report.empty?
  end

  def test_load_dump
    filename = '.ubc_test_file'
    contents = <<-EOF
196
privvmpages: 4

197
kmemsize: 6
privvmpages: 5

      EOF

    File.open(filename, 'w') { |f| f.puts contents }

    report = Ubc::Report.load filename
    assert_equal 1, report[:'196'].length, report[:'196'].inspect
    assert_equal 1, report[:'196'][:privvmpages].length
    assert_equal 2, report[:'197'].length

    assert_equal 4, report[:'196'][:privvmpages][:failcnt]
    assert_equal 5, report[:'197'][:privvmpages][:failcnt]
    assert_equal 6, report[:'197'][:kmemsize][:failcnt]

    assert_equal 2, report.length
    assert_equal 2, report.size

    report[:'197', :kmemsize] = { :held => 1000, :maxheld => 1050, :barrier => 4000, :limit => 4000, :failcnt => 8 }
    assert_equal 8, report[:'197'][:kmemsize][:failcnt]

    report.dump! filename
    assert_equal "197\nprivvmpages: 5\nkmemsize: 8\n\n196\nprivvmpages: 4\n\n", IO.read(filename)
    File.delete filename
  end
end
