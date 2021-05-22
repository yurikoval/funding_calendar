require 'icalendar'
require 'active_support/core_ext/numeric/time.rb'

Exchange = Struct.new(:name, :url, :funding_timings, keyword_init: true)

# Funding timings are in UTC
exchanges = [
  Exchange.new(name: "Bitmex", url: "https://www.bitmex.com/", funding_timings: ["04:00", "12:00", "20:00"]),
  Exchange.new(name: "OkEx", url: "https://www.okex.com/", funding_timings: ["00:00", "08:00", "16:00"]),
  Exchange.new(name: "Binance.com", url: "https://www.binance.com/", funding_timings: ["00:00", "08:00", "16:00"]),
  Exchange.new(name: "FTX", url: "https://www.ftx.com/", funding_timings: (0..23).map {|i| "#{ i.to_s.rjust(2, '0')}:00"})
]

cal = Icalendar::Calendar.new

exchanges.each do |ex|
  ex.funding_timings.each.with_index(1) do |funding_timing, index|
    h, m = funding_timing.split(":").map(&:to_i)
    cal.event do |e|
      start = DateTime.civil(2021, 1, 1, h, m)
      e.dtstart = start
      e.dtend = start + 30.minutes
      e.summary = "#{ex.name} Funding #{index}"
      e.url = ex.url
      e.rrule = Icalendar::Values::Recur.new("FREQ=DAILY")
    end
  end
end

puts cal.to_ical
