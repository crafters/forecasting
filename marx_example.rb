require 'date'
require_relative 'main'
require_relative 'queue_disciplines'


lts = [1, 1, 1, 2, 2, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 7, 8, 8, 11, 15] #Lead Time Sample

today = Date.parse(Time.now.strftime('%Y/%m/%d'))

project_specs = [
    ['A', [*12..17], [today - 7, today - 5, today - 6]],
    ['B', [*23..27], [today - 10, today - 4, today - 2]],
    ['C', [*16..23], [today - 9, today - 3, today - 5, today - 8, today - 3]],
    ['D', [*20..30], []]]

MonteCarlo.new(lts, project_specs, MarxDiscipline).run!
