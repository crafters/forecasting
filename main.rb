require 'date'

class DemandRepository

    @@next_id = 0
    @@demands = []

    def self.create(project, started_at, lead_time)
        demand = Demand.new(project, started_at, lead_time)
        @@demands << demand
        return demand
    end

    def list
        @@demands
    end

    def self.next_id
       @@next_id += 1
    end

    def self.demand_sample
        demands = []
        1000.times do
            demands << @@demands.sample        
        end
        return demands
    end
end


class Demand
    attr_reader :id, :finished_at, :lead_time, :project
    attr_accessor :started_at

    def initialize(project, started_at, lead_time)
        @project = project
        @id = DemandRepository.next_id
        @started_at = started_at
        @lead_time = lead_time

        #puts "#{@id}: #{@started_at} | #{@lead_time}"
    end

    def finish! day
        @finished_at = day 
        @project.finish! self, day
    end

end

class Kanban
    attr_reader :backlog, :wip, :finished, :projects
    
    def initialize(projects, lts, queue_discipline)
        @projects = projects

        @backlog = []
        @wip = []
        @finished = []
        
        @projects.each do |project| 
            project.started.each {|demand| @wip << demand}
            project.backlog.each {|demand| @backlog << demand}
        end

        @lts = lts
        @wip_limit = @wip.count     #I'm assuming initial wip == wip limits
        @queue_discipline = queue_discipline;
        
        # puts "Kanban Initialized:" + @backlog.collect {|x| x.project.id + x.id.to_s }.to_s + "" + @wip.collect {|x| x.project.id + x.id.to_s}.to_s + "" + @finished.collect {|x| x.project.id + x.id.to_s}.to_s

    end

    def finished?
        @backlog.count == 0 && @wip.count == 0
    end

    def finish!(demand, day)
        @wip.delete demand
        @finished << demand
        demand.finish! day
    end

    def start! day
        started_at = day
        while !self.finished? 
            unless day.saturday? || day.sunday?
                #puts "Day #{day} Kanban:" + self.backlog.collect {|x| x.project.id + x.id.to_s }.to_s + "" + self.wip.collect {|x| x.project.id + x.id.to_s}.to_s + "" + self.finished.collect {|x| x.project.id + x.id.to_s}.to_s
                self.run! day
            end
            day += 1
            raise "600 limit days reached! Problem with your sim?" if (day - started_at).to_i > 599
        end
    end

    def run!(day)
        # run the board
        @wip.each do |demand|
            self.finish!(demand, day) if demand.started_at.mjd + demand.lead_time <= day.mjd 
        end

        #report
        #@projects.each {|project| puts "Day #{day} #{project.id}: [#{project.backlog.count} / #{project.started.count} / #{project.finished.count}]"}
        
        #replenish
        (@wip_limit - @wip.count).times {self.replenish! day}

    end

    protected

    def replenish!(day)
        project = @queue_discipline.next
        if project
            demand = project.pull!
            demand.started_at = day
            @backlog.delete demand
            @wip << demand
        end
    end

end

class Project 
    
    attr_reader :id, :backlog, :started, :finished, :delivered_at

    def initialize(project_spec, lead_time_sample, day)
        
        @id = project_spec[0]
        @backlog_size = project_spec[1].sample  #simulate backlog size from range
        
        @backlog = []
        @started = []
        @finished = []
        
        # for demand on backlog use lead time sample
        @backlog_size.times { @backlog << DemandRepository.create(self, nil, lead_time_sample.sample) }
        
        # for started demand use the lead time sample "tail" (or current time + 1 day)
        project_spec[2].each do |started_at|
            
            days_on_cycle = day.mjd - started_at.mjd
            lead_time_tail_sample = lead_time_sample.select {|i| i >= days_on_cycle}
            lead_time = lead_time_tail_sample.sample || days_on_cycle + 1
            @started << DemandRepository.create(self, started_at, lead_time)
        end
        
        #puts "Project #{@id}:" + self.backlog.collect {|x| x.project.id + x.id.to_s }.to_s + " | " + self.started.collect {|x| x.project.id + x.id.to_s}.to_s + " | " + self.finished.collect {|x| x.project.id + x.id.to_s}.to_s

    end

    def finish!(demand, day)
        @started.delete demand
        @finished << demand
        @delivered_at = day if @backlog.count == 0 && @started.count == 0 
    end

    def pull!
        demand = @backlog.first
        raise "Backlog is empty" unless demand
        @backlog.delete demand
        @started << demand

        return demand
    end

end

class MonteCarlo
    
    def initialize(lead_time_sample, project_specs, queue_discipline_class)

        @today = Date.parse(Time.now.strftime('%Y/%m/%d'))
        @lead_time_sample = lead_time_sample.sort {|a,b| a <=> b}
        @deliver_distribution = {}
        @project_specs = project_specs        
        @queue_discipline_class = queue_discipline_class

    end

    def run!
        
        1000.times do

            projects = []
            @project_specs.each {|project_spec| projects << Project.new(project_spec, @lead_time_sample, @today)}

            kanban = Kanban.new(projects, @lead_time_sample, @queue_discipline_class.new(projects))

            kanban.start! @today

            kanban.projects.each do |project| 
                (@deliver_distribution[project.id] ||= []) << project.delivered_at
            end
        end

        @deliver_distribution.each do |k, v| 
            str = "#{k};"
            v.sort.each {|day| str += "#{day};"}
            puts str
        end

        str = "GLTS;"
        @lead_time_sample.each {|lt| str += "#{lt};"}
        puts str
        
        str = "OLTS;"
        DemandRepository.demand_sample.each {|demand| str += "#{demand.lead_time};"}
        puts str

    end
end
