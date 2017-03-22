require 'date'
require_relative 'main'
require_relative 'queue_disciplines'

today = Date.new(2017, 3, 20)

project = Project.new ['A', [*6..6], [today - 7, today - 1, today - 2]], [1,2,3], today

RSpec.describe Project do
    it "should initialize" do
        expect(project.backlog.count).to eq 6
        expect(project.started.count).to eq 3
    end

    it "backlog should hold non-started items with lead times" do
        project.backlog.each do |demand|
            expect(demand.started_at).to be_nil
            expect(demand.lead_time).to be_between(1, 3).inclusive
        end
    end

    it "started items should hold start dates" do
        project.started.each do |demand|
            expect(demand.started_at).not_to be_nil
        end
    end

    it "should calculate lead times correctly for started items" do
        expect(project.started[0].lead_time).to eql 8
        expect(project.started[1].lead_time).to be_between(1,3).inclusive
        expect(project.started[2].lead_time).to be_between(2,3).inclusive
    end

end

lt_test_sample = [3]

project_specs = [
    ['A', [*6..6], [today - 2, today - 2, today - 2]],
    ['B', [*5..5], []]]

RSpec.describe Kanban do

    it "should create with backlog and wip" do
        projectA = Project.new project_specs[0], lt_test_sample, today
        projectB = Project.new project_specs[1], lt_test_sample, today
        
        projects = [projectA, projectB]

        kanban = Kanban.new projects, lt_test_sample, MarxDiscipline.new(projects)
        expect(kanban.backlog.count).to eql 11
        expect(kanban.wip.count).to eql 3
    end

    it "should after 3 days 'move'" do
        projectA = Project.new project_specs[0], lt_test_sample, today
        projectB = Project.new project_specs[1], lt_test_sample, today

        projects = [projectA, projectB]

        kanban = Kanban.new projects, lt_test_sample, MarxDiscipline.new(projects)
        
        kanban.run! today
        kanban.run! today + 1
        kanban.run! today + 2
        
        expect(kanban.backlog.count).to eql 8
        expect(kanban.finished.count).to eql 3
    end

   it "should finish" do
        projectA = Project.new project_specs[0], lt_test_sample, today
        projectB = Project.new project_specs[1], lt_test_sample, today
        
        projects = [projectA, projectB]

        kanban = Kanban.new projects, lt_test_sample, MarxDiscipline.new(projects)
        
        kanban.start! today

        expect(kanban.backlog.count).to eql 0
        expect(kanban.finished.count).to eql 14
    end
end