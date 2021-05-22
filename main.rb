require 'icalendar'
require 'active_support/core_ext/numeric/time.rb'
require 'fileutils'

Exchange = Struct.new(:name, :url, :funding_timings, keyword_init: true)

def write_cal(name, cal)
  cal.to_ical
  FileUtils.mkdir_p 'docs/calendars'
  File.write("docs/calendars/#{name}.ics", cal.to_ical)
end

# Funding timings are in UTC
exchanges = [
  Exchange.new(name: "Bitmex", url: "https://www.bitmex.com/", funding_timings: ["04:00", "12:00", "20:00"]),
  Exchange.new(name: "OkEx", url: "https://www.okex.com/", funding_timings: ["00:00", "08:00", "16:00"]),
  Exchange.new(name: "Binance.com", url: "https://www.binance.com/", funding_timings: ["00:00", "08:00", "16:00"]),
  Exchange.new(name: "FTX", url: "https://www.ftx.com/", funding_timings: (0..23).map {|i| "#{ i.to_s.rjust(2, '0')}:00"})
]

all_cal = Icalendar::Calendar.new

exchanges.each do |ex|
  ex_cal = Icalendar::Calendar.new
  ex.funding_timings.each.with_index(1) do |funding_timing, index|
    h, m = funding_timing.split(":").map(&:to_i)
    start = DateTime.civil(2021, 1, 1, h, m)
    event = Icalendar::Event.new
    event.dtstart = start
    event.dtend = start + 30.minutes
    event.summary = "#{ex.name} Funding #{index}"
    event.url = ex.url
    event.rrule = Icalendar::Values::Recur.new("FREQ=DAILY")

    ex_cal.add_event(event)
    all_cal.add_event(event)
  end

  write_cal(ex.name, ex_cal)
end

write_cal("all", all_cal)
