# dbt Engineer Certification Exam Study Guide + Mock Exam

## What you must know for the exam

### 1. Core project structure and dependency logic
- Understand the role of `models/`, `seeds/`, `snapshots/`, `tests/`, `macros/`, and YAML property files.
- Know when to use `ref()` versus `source()`.
- Understand how dbt builds the DAG from references and source declarations.
- Be able to reason about upstream and downstream selection with graph operators.
- Know that execution order is driven by dependencies, not folder order.

### 2. Layering and modeling design
- Know the purpose of staging, intermediate, and mart layers.
- Be able to identify the correct layer for renaming, type standardization, joins, business logic, and final reporting outputs.
- Understand grain clearly and validate that every model has a defined grain.
- Apply DRY and modularity principles without over-fragmenting models.

### 3. Materializations and performance tradeoffs
- Know when to use `view`, `table`, `ephemeral`, and `incremental`.
- Understand tradeoffs between compute cost, storage cost, rebuild time, and query latency.
- Know how `ephemeral` models behave at compile time.
- Understand incremental requirements such as `unique_key`, filtering logic, and adapter-specific strategies.
- Know when `--full-refresh` is required and when it is not.
- Be familiar with advanced incremental concepts such as microbatch and strategy selection by data shape.

### 4. Commands, flags, and execution behavior
- Distinguish `dbt build` from `dbt run`, `dbt test`, `dbt seed`, `dbt snapshot`, `dbt docs`, `dbt show`, `dbt clone`, and `dbt retry`.
- Know that `dbt build` orchestrates multiple resource types and tests, while `dbt run` only builds models.
- Understand how `--select`, `--exclude`, `--state`, `--defer`, `--empty`, `--sample`, `--full-refresh`, and `--fail-fast` change behavior.
- Know the difference between state selectors, result selectors, graph expansion, config selectors, path selectors, and tag selectors.
- Understand what `dbt show` does versus commands that persist objects.

### 5. Tests and quality controls
- Know generic tests, singular tests, custom generic tests, and source tests.
- Understand `not_null`, `unique`, `relationships`, and `accepted_values`.
- Know when a requirement needs a reusable generic test versus a one-off singular test.
- Understand test configs such as `severity`, `warn_if`, `error_if`, `where`, `limit`, and `store_failures`.
- Be able to reason about how tests behave inside `dbt build` and how failures affect downstream execution.

### 6. YAML properties, documentation, and governance
- Know how to define model, source, snapshot, and column properties in YAML.
- Understand model contracts, `enforced`, and platform constraints.
- Know model versioning concepts: `versions`, `latest_version`, and deprecation.
- Understand `grants`, `access`, and `group` at a conceptual level.
- Be able to troubleshoot YAML compilation issues caused by indentation, invalid property placement, or schema structure mistakes.

### 7. Snapshots, sources, and external dependencies
- Know snapshot purpose and how it differs from incremental models.
- Understand snapshot configs such as `strategy`, `updated_at`, `check_cols`, and `unique_key`.
- Know how to define sources and source freshness with `loaded_at_field`, `warn_after`, and `error_after`.
- Understand exposures conceptually and how they document downstream dependencies.

### 8. Macros, packages, and overrides
- Understand practical Jinja usage in dbt.
- Know how macros support reuse and standardization.
- Understand package usage and macro resolution basics.
- Be familiar with override patterns such as `generate_schema_name`, `generate_schema_name_for_env`, `generate_database_name`, and `generate_alias_name`.
- Understand dispatch concepts well enough to distinguish local overrides from package macro dispatch behavior.

### 9. Debugging and troubleshooting
- Read dbt error messages carefully and identify whether the issue is parse-time, compile-time, test-time, or warehouse execution-time.
- Use compiled SQL to troubleshoot model logic.
- Understand common YAML parsing and compilation failures.
- Know how flags can change debugging behavior and execution scope.
- Understand failure points in DAG execution and when `dbt retry` or state-aware workflows are appropriate.

### 10. State-aware workflows and CI reasoning
- Understand what dbt state means and how artifacts are used in state comparison.
- Know practical uses of `--state` and `--defer`.
- Distinguish state selection from ordinary node selection.
- Understand when `dbt clone` is useful in environment promotion or fast environment setup workflows.
- Know that exam questions often test artifact semantics, rerun logic, and subtle selector behavior.

## High-priority exam traps
- Confusing `ref()` with `source()`.
- Confusing `dbt build` with `dbt run` plus separate testing behavior.
- Confusing generic test definitions with test configuration.
- Confusing snapshot use cases with incremental model use cases.
- Confusing compile-time behavior with warehouse runtime behavior.
- Confusing state selectors, result selectors, and graph operators.
- Assuming folder order controls execution.
- Misreading whether a failure came from model execution or test execution.
- Using a real dbt term correctly in isolation but incorrectly for the scenario.

---

# Mock Exam

**Instructions:** Choose the single best answer for each question. No answers are shown in this file.

## Question 1
A team has three models: `stg_orders`, `int_order_metrics`, and `fct_orders`. The developer places them in the correct folders but forgets to reference `int_order_metrics` inside `fct_orders`, instead querying the physical relation name directly. The project still compiles in the developer environment. Which is the most important exam-relevant consequence of this implementation?

A. dbt will still infer the dependency because the model is in the `intermediate` folder.
B. dbt will build the DAG without the intended dependency edge, which can affect execution order and lineage.
C. dbt will automatically convert the physical relation reference into a `ref()` during compilation.
D. dbt will fail parsing because direct relation references are not allowed in model SQL.

## Question 2
A model is materialized incrementally and processes billions of event rows. The warehouse supports multiple incremental strategies. New records arrive continuously, and updates to older rows are rare but possible within a short correction window. Which implementation choice is most aligned with dbt exam best practice?

A. Use a view materialization because dbt views always avoid full scans.
B. Use an incremental model with a well-defined filter and choose the incremental strategy based on warehouse support and update pattern.
C. Use an ephemeral model so dbt can cache prior results between runs.
D. Use a snapshot instead of an incremental model because snapshots are the default optimization pattern for large fact tables.

## Question 3
A developer runs `dbt build --select marts.finance` and sees that a model builds successfully, but a downstream test on that model fails. Which statement best describes dbt behavior in this scenario?

A. `dbt build` ignores test failures if the model itself succeeded.
B. `dbt build` runs only models, so the failure must come from a separate command.
C. `dbt build` includes tests for selected resources, and test failures can affect downstream execution behavior.
D. Tests run only for sources and snapshots during `dbt build`.

## Question 4
A team wants to validate SQL logic and schema definitions in a dry-run style workflow without processing full data volumes. Which flag is specifically associated with this exam objective?

A. `--defer`
B. `--empty`
C. `--fail-fast`
D. `--full-refresh`

## Question 5
A project defines a reusable test that checks whether a timestamp column is always greater than a created date across many models. The team wants to configure it in YAML on multiple columns. What is the best dbt implementation?

A. A singular test in `tests/` because singular tests are the only tests that can compare two columns.
B. A custom generic test macro so it can be reused and configured in YAML.
C. A source freshness block because freshness checks support cross-column assertions.
D. A post-hook on each model because hooks are the standard way to express reusable assertions.

## Question 6
A model contract is enabled and enforced. The SQL compiles, but the selected columns do not match the declared schema in YAML. What is the best interpretation?

A. dbt will ignore the mismatch because contracts only document intent.
B. dbt will enforce the declared model shape according to platform support, making schema mismatch a relevant failure condition.
C. Contracts apply only to seeds and snapshots, not models.
D. Contracts replace the need for tests and therefore cannot fail independently.

## Question 7
A developer is troubleshooting a failing model and wants to inspect the exact SQL sent to the warehouse after Jinja rendering and macro expansion. What is the most appropriate debugging approach?

A. Inspect the compiled SQL artifact for the model.
B. Read only the YAML properties file because compilation errors never involve SQL rendering.
C. Re-run `dbt docs generate` because docs artifacts contain the executed SQL text for debugging.
D. Inspect the seed CSV files because dbt stores compiled SQL there during execution.

## Question 8
A source table is expected to land every hour. The team wants dbt to warn after a smaller delay and error after a larger delay based on the source load timestamp column. Which configuration area is most relevant?

A. Model contract with `enforced: true`
B. Source freshness using `loaded_at_field`, `warn_after`, and `error_after`
C. Generic tests with `severity: warn` only
D. Snapshot strategy with `updated_at`

## Question 9
A package provides a macro used across the project, but the team needs warehouse-specific override behavior while preserving package-based resolution patterns. Which concept is most relevant to this scenario?

A. `adapter.dispatch` and dispatch configuration
B. `source()` because sources override package macros
C. `store_failures` because test storage controls macro precedence
D. `latest_version` because versioned models resolve macro dispatch

## Question 10
A team uses Slim CI and compares the current project against prior artifacts. They need to select nodes based on changes relative to a previous state, not just by path or tag. Which concept is being tested?

A. Ordinary node selection only
B. State-aware selection using `--state`
C. Source freshness selection
D. Exposure execution selection

## Question 11
A developer uses `dbt show` while evaluating a new transformation. Which statement is most accurate?

A. `dbt show` is intended to inspect query results without persisting the model as a built relation in the warehouse in the same way as a normal build command.
B. `dbt show` always creates permanent tables before displaying rows.
C. `dbt show` is equivalent to `dbt seed` for temporary inspection.
D. `dbt show` updates `sources.yml` automatically based on query output.

## Question 12
A project has a custom `generate_schema_name` macro. The team is asked which nearby concept is often preferable in environment-aware scenarios and therefore exam-relevant to distinguish from a manual override. Which option is best?

A. `generate_schema_name_for_env`
B. `accepted_values`
C. `dbt retry`
D. `loaded_at_field`

## Question 13
A snapshot is configured in YAML. The business requirement is to track changes to customer status over time, preserving historical versions. Why is a snapshot generally more appropriate than a standard incremental model for this requirement?

A. Because incremental models automatically preserve every prior row version by default.
B. Because snapshots are designed for change tracking over time and historical state preservation.
C. Because snapshots are faster than all incremental strategies on every warehouse.
D. Because snapshots replace the need for unique keys.

## Question 14
A developer runs a command with graph operators and gets more nodes than expected because parents and children were expanded around the selected node set. What exam concept is most directly being tested?

A. The distinction between selector syntax and actual selection behavior at runtime
B. The difference between seeds and snapshots
C. The difference between contracts and constraints
D. The difference between docs blocks and descriptions

## Question 15
A pipeline failed partway through a large dbt workflow. The team wants to reason about rerun behavior using dbt state rather than simply rerunning everything. Which command is explicitly in scope for this exam area?

A. `dbt retry`
B. `dbt parse`
C. `dbt init`
D. `dbt source snapshot`
