# This queue discipline tries to maximize feedback among projects by minimizing takt time
class FeedbackerDiscipline
    
    def initialize projects
        @projects = projects.clone
        @index = 0
    end

    def next
        projects = (@projects.select {|project| project.backlog.count > 0}).sort do |a,b| 
            ar = a.finished.count > 0 ? a.finished.last.lead_time : 9999
            br = b.finished.count > 0 ? b.finished.last.lead_time : 9999   
            br <=> ar
        end
        
        #str = ""
        #projects.each {|x| str += "#{x.id}:" + (x.finished.count > 0 ? x.finished.last.leadtime : 9999).to_s + ", "  }
        #puts str

        return nil if projects.count == 0
        return projects.first 
    end
end

# This queue discipline tries to equalize projects by backlog size
class MarxDiscipline
    
    def initialize projects
        @projects = projects.clone
        @index = 0
    end

    def next
        projects = @projects.sort {|a,b| a.backlog.count <=> b.backlog.count}
        
        return nil if projects.last.backlog.count == 0
        # puts "#{projects.last.id}"
        return projects.last 
    end
end

# This queue discipline simply randomly selects a project...
class VegasDiscipline
    
    def initialize projects
        @projects = projects.clone
    end

    def next
        (@projects.select {|project| project.backlog.count > 0}).sample
    end
end

# First in, first out
class FifoDiscipline
    
    def initialize projects
        @projects = projects.clone
    end

    def next
        (@projects.select {|project| project.backlog.count > 0}).first
    end
end
