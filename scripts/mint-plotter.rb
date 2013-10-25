#!/usr/bin/env ruby

require "rubygems"
require "rubyvis"
require "csv"

USAGE = "#{$0} path/to/transactions.csv > path/to/output.svg"

csv = ARGV.first || abort(USAGE)
transactions = CSV.read(csv)

# remove header and sort in ascending date order
transactions = transactions.drop(1).reverse

class String
  def to_date
    # Start by assuming the values are in this order, separated by /
    month, day, year = self.split('/').map(&:to_i)
    ::Date.new(year, month, day)
  end
end

# parse csv rows
data = transactions.map do |components|
  is_expense = (components[4] == "debit")
  amount = components[3].to_f
  amount = -amount if is_expense
  OpenStruct.new({:date => components[0].to_date, :amount => amount })
end

# coalesce days into one point
data_by_date = data.group_by do |txn|
  txn.date
end

coalesced_data = []
data_by_date.each_pair do |date, txns|
  delta = txns.reduce(0) do |delta, txn|
    delta + txn.amount
  end
  coalesced_data << OpenStruct.new({:date => date, :delta => delta})
end

number_of_days = coalesced_data[-1].date - coalesced_data[0].date

data = []
last_day = nil
x = 0
running_total = 0
coalesced_data.each do |day|
  while !last_day.nil? && day.date - last_day.date != 1
    data << OpenStruct.new({:x => x, :y => running_total})
    x += 1
    last_day.date = last_day.date + 1
  end
  running_total += day.delta
  data << OpenStruct.new({:x => x, :y => running_total})
  last_day = day
  x += 1
end

w = 800
h = 600

x = pv.Scale.linear(data, lambda {|d| d.x}).range(0, w)
y = pv.Scale.linear(data, lambda {|d| d.y}).range(0, h);

# The root panel
vis = pv.Panel.new() do
  width(w)
  height(h)
  bottom(20)
  left(50)
  right(50)
  top(20)

  # Y-axis and ticks
  rule do
    data y.ticks()
    bottom(y)
    stroke_style {|d| d!=0 ? "#eee" : "#000"}
    label(:anchor=>"left") {
      text y.tick_format
    }
  end

  # X-axis and ticks.
  rule do
    data x.ticks()
    left(x)
    bottom(-5)
    height(5)
    label(:anchor=>'bottom') {
      text(x.tick_format)
    }
  end
end

vis.add(pv.Line)
  .data(data)
  .line_width(3)
  .left(lambda {|d| x.scale(d.x)})
  .bottom(lambda {|d| y.scale(d.y)})

vis.render()

# pipe the output of this script to an SVG file
puts vis.to_svg

