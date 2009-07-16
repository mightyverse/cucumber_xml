xml.instruct!
xml.projects do
  xml.total @projects.length
  @projects.each do |project|
    xml.project do
      xml.name project.name
      xml.notes project.notes
      xml.complete project.complete
    end
  end
end