Feature: Project Create XML API
  In order to create projects
  As a device or client application using the XML REST interface
  I want to make POST requests to the /projects URL

Scenario: Create Project with all fields that a client may define
  When I send an XML POST to /projects and HTTP header: Accept=application/xml and post body:
  """
    <project>
      <name>Awesome</name>
      <notes>super cool nifty</notes>
      <complete >false</complete>
    </project>
  """
  And I get a 201 (created) status result
  And a Project instance with name="Awesome" exists on the server
  Then I get an 'application/xml' response

