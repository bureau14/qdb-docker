/// <reference types="Cypress" />

context("Query Panel", () => {
  before(() => {
    cy.visit("/#anonymous");
    cy.get("#navbar-item-query")
      .click();
  });

  it("shows query form", () => {
    cy.get("#query")
      .should("be.visible")
      .get(".CodeMirror textarea")
      .should("be.visible");
    cy.contains("Submit")
      .should("be.visible");
  });

  it("shows chart toggle", () => {
    cy.contains("Show results as chart")
      .should("be.visible");
  });
});
