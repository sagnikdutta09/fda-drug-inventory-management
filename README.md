FDA Drug Inventory & Distribution Management System

Status: In Progress (~50% complete) — Target completion: Aug 15, 2026
Stack: Salesforce (Apex, SOQL, Lightning Web Components) · SFDX

Overview

A Salesforce application built to manage pharmaceutical inventory, drug batch tracking, clinic-level stock, prescriptions, and dispensing workflows in a regulated environment. Modeled after real-world GxP/pharma operational patterns drawn from production experience at a life-sciences client, this project focuses on translating that domain knowledge into a from-scratch Apex and LWC implementation — data model, business logic, and UI — rather than admin-configured automation alone.

What's built
Data model: Seven custom objects covering drug batches, inventory, clinics, prescriptions, and dispensing records, connected via Lookup and Master-Detail relationships.
Trigger architecture: Bulkified Apex triggers built on the trigger handler pattern (one trigger per object, logic delegated to handler and service classes) enforcing batch lifecycle rules, inventory synchronization, and dispensing validation.
Service layer: Reusable Apex service classes handling inventory updates, status-transition validation, and cross-object data integrity — built with SOQL/DML best practices (bulk-safe queries, governor-limit-aware design).
Testing: Apex test data factory pattern with positive, negative, and bulk test coverage, currently at 90%+ code coverage across triggers and service classes.
In progress
Lightning Web Components for inventory dashboards and prescription dispensing — using @wire, Lightning Data Service, and Apex controllers for data retrieval/updates.
Additional bulk-scenario test coverage as UI components come online.
Why this project

Built to demonstrate hands-on Apex and LWC development ability beyond administration — applying real GxP-domain operational knowledge (batch tracking, dispensing controls, audit-relevant data integrity) to a ground-up technical build.