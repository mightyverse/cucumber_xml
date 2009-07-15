Feature: Project XML API
  In order to read project data data
  As a device or client application using the XML REST interface
  I want to make GET requests to the /projects URL

  Scenario: Get Medium
    When I send an XML GET to /projects.xml
    Then I get a 200 (success) status result
    And the response header Content-Type matches application/xml
    And the response should be a superset of the file: "xml/projects.xml"

