/// <reference types="Cypress" />

const btcusd_query = "select * from 'fx.btcusd' in range(2016-01-09T13:55:00, 2016-01-09T14:10:00);";

context("Performing btcusd Query, view as chart", () => {
  before(() => {
    cy.visit("/#anonymous");
    cy.get("#navbar-item-query")
      .click();
    cy.get("#charted-cb")
      .check({ force: true });
    cy.get(".CodeMirror textarea")
      .type(btcusd_query, { force: true }); // because textarea is covered
    cy.contains("Submit")
      .click();
  });

  it("shows chart executed query", () => {
    cy.get(".ui.read-only .CodeMirror")
      .contains(btcusd_query)
      .should("be.visible");
  });

  it("shows chart header", () => {
    cy.get(".ui.ribbon.label")
      .should("contain", "btcusd");
  });

  it("shows chart", () => {
    cy.get("svg .recharts-layer.recharts-line")
      .should("be.visible");
  });

  it("show x axis", () => {
    cy.contains("2016-01-09T14:05:00.000Z")
      .should("be.visible");
  })
});
