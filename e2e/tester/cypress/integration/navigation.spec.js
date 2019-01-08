/// <reference types="Cypress" />

context("Navigation", () => {
  beforeEach(() => {
    cy.visit("/#anonymous");
  });

  it("shows navbar", () => {
    cy.get("#navbar")
      .should("be.visible");
  });

  it("shows cluster panel", () => {
    cy.contains("status")
      .should("be.visible");
    cy.contains("nodes")
      .should("be.visible");
  });

  it("navigates to cluster panel", () => {
    cy.get("#navbar-item-cluster")
      .should("be.visible")
      .click()
      .should("have.class", "active");

    cy.contains("status")
      .should("be.visible");
    cy.contains("nodes")
      .should("be.visible");
  });

  it("navigates to query panel", () => {
    cy.get("#navbar-item-query")
      .should("be.visible")
      .click()
      .should("have.class", "active");

    cy.contains("Query the database")
      .should("be.visible");
  });

  it("logs out", () => {
    cy.get("#navbar-item-logout")
      .should("be.visible")
      .click();

    cy.contains("You are not logged in")
      .should("be.visible");
  });
});
