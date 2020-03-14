@javascript
Feature: search information about suppliers
  A user can search for factories and get information about which companies
  a factory supplies.

  Scenario: search by name
    When I search for name "Texgr"
    Then I should see "Texgroup S.A." in the factory list
    When I open "Texgroup S.A."
    Then I should see that it supplied "VF Corporation" in "2017"

  Scenario: search by address
    When I search for address "Zuidstraat"
    Then I should see "Lano Carpets" in the factory list
    When I open "Lano Carpets"
    Then I should see that it supplied "The Walt Disney Company" in "2016"

  Scenario: search by country
    When I search for country "California"
    Then I should see "3D Systems" in the factory list
    And I should see "Callaway Golf Company" in the factory list
    When I open "3D Systems"
    Then I should see that it supplied "The Walt Disney Company" in "2016"

  Scenario: search by name and country
    When I search for name "Sys"
    And I search for country "California"
    Then I should see "3D Systems" in the factory list
    And I should not see "Callaway Golf Company" in the factory list

