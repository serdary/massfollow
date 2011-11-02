Feature: Handle user followees
  In order to handle my followees
  As a user
  I want to login and manage followees
    
  Scenario: Login via Twitter API
    When I go to the “homepage”
    And I follow “Login via Twitter”
    And Twitter authorizes me
    Then I should see my followees
  
  Scenario: Followees List
    Given I have followees
    When I go to the list of my followees on app
    Then I should see "person1"
    And I should see "person2"