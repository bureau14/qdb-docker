/// <reference types="Cypress" />

const btcusd_query = "select * from btcusd in range(2016-01-09T13:55:00Z, 2016-01-09T16:00:00Z);";

context("Performing btcusd Query", () => {
  before(() => {
    cy.visit("/#anonymous");
    cy.get("#navbar-item-query")
      .click();
    cy.get(".CodeMirror textarea")
      .type(btcusd_query, {force: true}); // because textarea is covered
    cy.contains("Submit")
      .click();
  });

  it("shows executed query", () => {
    cy.get(".ui.read-only .CodeMirror")
      .contains(btcusd_query)
      .should("be.visible");
  });

  it("shows table label", () => {
    cy.get(".ui.ribbon.label")
      .should("contain", "btcusd");
  });

  it("shows table header", () => {
    const expected_headers = ["timestamp", "close", "high", "low", "open", "volume"];
    cy.get(".ui.table thead tr")
      .children()
      .each(($th, ix) => {
        cy.wrap($th).should("contain", expected_headers[ix]);
      });
  });

  it("shows results table", () => {
    const expected_first_row_values = ["2016-01-09T13:55:00Z", "450.48", "450.48", "450.48", "450.48", "0"];
    cy.get(".ui.table tbody")
      .children()
      .first()
      .children()
      .each(($td, ix) => {
        cy.wrap($td).should("contain", expected_first_row_values[ix]);
      });

    const expected_last_row_values = ["2016-01-09T14:04:00Z", "448.36", "449.82", "448.36", "449.82", "0.15"];
    cy.get(".ui.table tbody")
      .children()
      .last()
      .children()
      .each(($td, ix) => {
        cy.wrap($td).should("contain", expected_last_row_values[ix]);
      });
  });

  it("shows number of rows", () => {
    cy.contains("10 of 125 rows shown")
      .should("be.visible");
  });

  it("shows chart executed query", () => {
    cy.contains("Show results as chart")
      .click();
    cy.get(".ui.read-only .CodeMirror")
      .contains(btcusd_query)
      .should("be.visible");
  });

  it("shows chart header", () => {
    cy.contains("Show results as chart")
      .click();
    cy.get(".ui.ribbon.label")
      .should("contain", "btcusd");
  });
});

context("Performing btcusd Query & expanding", () => {
  before(() => {
    cy.visit("/#anonymous");
    cy.get("#navbar-item-query")
      .click();
    cy.get(".CodeMirror textarea")
      .type(btcusd_query, {force: true}); // because textarea is covered
    cy.contains("Submit")
      .click();
    cy.contains("a", "expand")
      .click();
  });

  it("shows results table, expanded", () => {
    const expected_first_row_values = ["2016-01-09T13:55:00Z", "450.48", "450.48", "450.48", "450.48", "0"];
    cy.get(".ui.table tbody")
      .children()
      .first()
      .children()
      .each(($td, ix) => {
        cy.wrap($td).should("contain", expected_first_row_values[ix]);
      });

    const expected_last_row_values = ["2016-01-09T15:34:00Z", "448.71", "448.71", "448.71", "448.71", "0"];
    cy.get(".ui.table tbody")
      .children()
      .last()
      .children()
      .each(($td, ix) => {
        cy.wrap($td).should("contain", expected_last_row_values[ix]);
      });
  });

  it("shows number of rows, expanded", () => {

    cy.contains("100 of 125 rows shown")
      .should("be.visible");
  });
});