/// <reference types="Cypress" />

context("Login", () => {
  it("shows login panel", () => {
    cy.visit("/");
    cy.contains("You are not logged in")
      .should("be.visible");
  });

  it("logins anonymously", () => {
    cy.visit("/#anonymous");
    cy.get("#logo")
      .should("be.visible");
  });
});
