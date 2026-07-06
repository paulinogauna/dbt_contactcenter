# Advanced dbt Analytics Engineering Certification Mock Exam

## Question 1
A CI job runs:

`dbt build --select state:modified+ --state artifacts/prod --defer`

A changed mart model depends on an unchanged intermediate model that is not selected in CI. The intermediate model exists in production.

What is the best explanation for why the mart model can still build?

A. `state:modified+` automatically rebuilds all unchanged parents in the CI schema.  
B. `--defer` allows unresolved upstream references for unselected nodes to point to relations from the state environment.  
C. `--state` rewrites every `ref()` to production regardless of selection.  
D. `dbt build` ignores missing parents when a manifest is supplied.

## Question 2
An incremental model uses:

```sql
{{ config(materialized='incremental', incremental_strategy='merge', unique_key='order_id') }}

select *
from {{ ref('stg_orders') }}
{% if is_incremental() %}
where updated_at >= (select max(updated_at) from {{ this }})
{% endif %}
```

Late corrections arrive with an `updated_at` older than the current maximum in the target table.

What is the best conclusion?

A. The model will still capture all corrections because `merge` updates matching keys.  
B. The model will fail because `merge` requires strictly increasing timestamps.  
C. Some corrected rows may be missed unless the incremental filter is changed.  
D. dbt automatically switches to microbatch behavior for late-arriving rows.

## Question 3
You are on a feature branch. Teammates have merged several changes into `main`. You want to inspect remote updates before deciding whether to merge or rebase.

What is the best first step?

A. `git pull`  
B. `git fetch`  
C. `git checkout main`  
D. `git push --force-with-lease`

## Question 4
A model contains:

```sql
select *
from analytics.stg_orders
```

There is also a dbt model file named `stg_orders.sql`. In clean environments, build order is inconsistent.

What is the best fix?

A. Replace `analytics.stg_orders` with `{{ source('analytics', 'stg_orders') }}`  
B. Add `depends_on` in `dbt_project.yml`  
C. Replace `analytics.stg_orders` with `{{ ref('stg_orders') }}`  
D. Materialize `stg_orders` as `ephemeral`

## Question 5
A legacy SQL query references raw tables `customers`, `orders`, `nation`, and `region`, all from the same database and schema.

How should these raw dependencies typically be declared?

A. One source with four tables  
B. Four sources with one table each  
C. One source with one table and three seeds  
D. Four sources with four tables each

## Question 6
You want to materialize `my_model` and only its direct parent models.

Which command is correct?

A. `dbt run --select +my_model`  
B. `dbt compile --select 1+my_model`  
C. `dbt run --select 1+my_model`  
D. `dbt run --select +1 my_model`

## Question 7
A CI pipeline runs `dbt build --empty`. A `unique` test passes even though production data contains duplicates.

Why?

A. `--empty` skips generic tests entirely.  
B. The test ran against an empty relation, so no duplicate rows existed to fail the assertion.  
C. `unique` tests validate only YAML metadata under `--empty`.  
D. `--empty` downgrades uniqueness failures to warnings.

## Question 8
A table model has an enforced contract. The SQL now returns `integer` for `customer_id`, but the YAML contract still declares `string`.

What is the expected behavior?

A. dbt silently casts the output to match the contract.  
B. The model may fail because the enforced contract checks the built model shape against the declared schema.  
C. The model succeeds, but `dbt docs generate` fails later.  
D. Only downstream models fail if they use `ref()`.

## Question 9
A model is versioned with `latest_version: 2`. Downstream models still call `ref('dim_customer')` without specifying a version.

What happens by default?

A. They fail until every `ref()` is pinned.  
B. They resolve to version 1 until deprecation is enforced.  
C. They resolve to the latest version unless explicitly pinned.  
D. They resolve nondeterministically if multiple versions are enabled.

## Question 10
A singular test checks that no invoice has `amount < 0`. The team wants failed rows persisted for inspection.

What is the best approach?

A. Add `store_failures: true` to the test configuration.  
B. Convert the singular test into a seed.  
C. Add `limit: 0` so all failures are stored.  
D. Use `dbt show` instead of `dbt test`.

## Question 11
A local macro and a package macro share the same name. The project calls the macro without a namespace.

What is the most likely behavior?

A. dbt always prefers the package macro unless `dispatch` is configured.  
B. dbt errors because duplicate macro names are not allowed.  
C. The local project macro overrides the package macro in normal resolution order.  
D. Both macros execute and the last compiled result wins.

## Question 12
An incremental model uses `merge` with `unique_key='id'`, but the incoming batch contains duplicate `id` values.

What is the best conclusion?

A. dbt automatically deduplicates the incoming batch before merging.  
B. The run may fail or behave adapter-specifically because the merge key is not unique in the source batch.  
C. dbt truncates the target table before the merge.  
D. dbt converts the model to append mode for that run.

## Question 13
A developer runs:

`dbt run --select tag:nightly`

They expect tests on those models to run too.

Why is that expectation incorrect?

A. `tag:` selectors never include tests.  
B. `dbt run` builds models but does not execute tests; `dbt build` would orchestrate both.  
C. Tests only run when selected by path.  
D. Generic tests require `dbt docs generate` first.

## Question 14
A source freshness config is:

```yaml
loaded_at_field: ingested_at
freshness:
  warn_after: {count: 12, period: hour}
  error_after: {count: 24, period: hour}
```

The latest record is 18 hours old.

What is the best interpretation?

A. Freshness passes because it is below `error_after`.  
B. Freshness warns because it exceeded `warn_after` but not `error_after`.  
C. Freshness errors because any threshold breach is an error.  
D. Freshness is skipped unless the source also has tests.

## Question 15
A model using `{{ ref('stg_payments') }}` compiles successfully, but runtime fails with:

`Database Error: relation "analytics_dev.stg_payments" does not exist`

What is the best explanation?

A. `ref()` creates lineage and naming abstraction, but it does not guarantee the referenced relation exists in the current target environment.  
B. `ref()` should have been replaced with `source()`.  
C. `ref()` validates physical existence at parse time, so this error cannot happen.  
D. This can only happen when the parent is ephemeral.

## Question 16
A team wants to validate SQL logic and schema compatibility in CI without scanning full datasets.

Which command best fits?

A. `dbt show --select state:modified+`  
B. `dbt build --empty --select state:modified+`  
C. `dbt docs generate --empty`  
D. `dbt test --sample`

## Question 17
A model is materialized as `ephemeral` and referenced by three downstream models.

What is the most accurate implication?

A. dbt creates one shared physical table for the ephemeral model.  
B. The ephemeral SQL is inlined into each downstream model at compile time.  
C. Ephemeral models can be tested directly in the warehouse after `dbt run`.  
D. Ephemeral models always improve performance compared with tables.

## Question 18
A model YAML includes platform constraints and also generic tests on the same column.

What is the best statement?

A. Constraints and tests are interchangeable, so one should be removed.  
B. Constraints can enforce integrity at the platform level, while tests still provide dbt-level validation semantics.  
C. Generic tests are ignored when constraints exist.  
D. Constraints only affect docs, not execution.

## Question 19
You run:

`dbt build --select model_a+ --fail-fast`

`model_a` builds successfully, but a downstream test fails.

What is the best expectation?

A. dbt continues building all remaining downstream nodes because only model failures trigger `--fail-fast`.  
B. dbt stops after the first failure, including test failures.  
C. dbt reruns `model_a` automatically with `dbt retry`.  
D. dbt skips only singular tests under `--fail-fast`.

## Question 20
A snapshot is defined in YAML using the `check` strategy. A column not listed in `check_cols` changes upstream.

What happens?

A. A new snapshot row is created because any column change is tracked.  
B. No new snapshot row is created solely because that untracked column changed.  
C. dbt errors because `check` requires all columns to be listed.  
D. dbt converts the snapshot to `timestamp` strategy.

## Question 21
A developer wants to inspect the result of a model query without creating or replacing warehouse objects.

Which command is best?

A. `dbt run`  
B. `dbt build`  
C. `dbt show`  
D. `dbt docs generate`

## Question 22
A project uses `generate_schema_name` to isolate developer schemas. In CI, the team wants unchanged upstream references to resolve to production while changed nodes build in the CI schema.

Which combination best supports that behavior?

A. `--state` only  
B. `--defer` with a valid state manifest  
C. `--full-refresh` with `--empty`  
D. `dbt clone` without state artifacts

## Question 23
A model contract is enforced. A new nullable column is added in SQL but not declared in YAML.

What is the best expectation?

A. The model may fail because the actual shape no longer matches the declared contract.  
B. dbt automatically appends undeclared nullable columns to the contract.  
C. The model succeeds because contracts only validate existing declared columns.  
D. Only `dbt docs generate` notices the mismatch.

## Question 24
A team wants a reusable test that checks whether `closed_at >= opened_at` across many models, with configurable column names.

What is the best implementation?

A. A singular test copied into each model folder  
B. A custom generic test macro with arguments configured in YAML  
C. A seed plus `accepted_values`  
D. A snapshot with `check_cols`

## Question 25
A developer sees this error during parsing:

`Compilation Error in model int_orders (models/intermediate/int_orders.sql)
  'dict object' has no attribute 'name'`

The failing line references `{{ var('region').name }}`.

What is the best conclusion?

A. The warehouse returned a malformed column named `name`.  
B. The variable likely does not have the expected object structure at compile time.  
C. The model built successfully but the test failed.  
D. `var()` can only be used in `dbt_project.yml`.

## Question 26
A project uses `dbt build --select state:modified+ --state prod_artifacts`. A test on an unchanged upstream source is failing in production, but that source is not modified.

Why might the CI run not surface that failure?

A. State selection can exclude unchanged nodes even if they are still problematic.  
B. `dbt build` never runs source tests in CI.  
C. `state:modified+` includes only models, not tests.  
D. `--state` suppresses failures from upstream nodes.

## Question 27
You want to grant `select` on a mart model to an analyst role as part of dbt configuration.

What is the best mechanism?

A. `access: public`  
B. `grants` config on the model  
C. `group` property in YAML  
D. `meta` property with role names

## Question 28
A model is incremental and very large. The team wants to test only recent rows for `not_null` in CI.

Which configuration best fits?

A. `limit` on the model config  
B. `where` on the test configuration  
C. `store_failures` on the model  
D. `error_if` on the source

## Question 29
A developer runs:

`dbt build --select result:error --state previous_run_artifacts`

What is the intent of this selector?

A. Build only nodes whose SQL contains the word `error`  
B. Build nodes that errored in the prior run represented by the supplied artifacts  
C. Build all tests with severity error  
D. Build only models with contract violations

## Question 30
A feature branch is behind `main`. You want to update your local knowledge of remote branches without changing your working tree.

Which Git command best fits?

A. `git fetch`  
B. `git merge origin/main`  
C. `git pull`  
D. `git rebase main`

## Question 31
A model references a raw table with `ref()` instead of `source()`. The raw table is not built by dbt.

What is the main issue?

A. `ref()` is only valid in snapshots.  
B. dbt will treat the raw object as a managed dbt node dependency, which is incorrect if it is not a project model.  
C. `source()` cannot be used for external tables.  
D. `ref()` and `source()` are interchangeable if the relation exists.

## Question 32
A team wants to use `dbt clone` in a workflow.

Which scenario is the best fit?

A. They want to generate docs for exposures.  
B. They want to create zero-copy or metadata-based copies of existing relations in a target environment, where supported, to accelerate environment setup.  
C. They want to rerun only failed tests.  
D. They want to compare manifests between branches.

## Question 33
A model has:

```yaml
tests:
  - unique:
      config:
        severity: warn
        error_if: ">10"
        warn_if: ">0"
```

The test returns 3 failing rows.

What is the best outcome?

A. Error, because any failure in `unique` is always an error  
B. Warn, because failures exceed `warn_if` but not `error_if`  
C. Pass, because 3 is below 10  
D. Error, because `severity: warn` is ignored when `error_if` is present

## Question 34
A package provides a macro used by many models. You need adapter-specific behavior without changing every call site.

What is the best concept to use?

A. `adapter.dispatch` / dispatch configuration  
B. `ref(version=...)`  
C. `store_failures`  
D. `group`

## Question 35
A developer runs `dbt run --full-refresh --select my_incremental_model`.

What is the best interpretation?

A. dbt will ignore the model’s incremental materialization and rebuild it from scratch for that run.  
B. dbt will append all rows twice.  
C. dbt will rebuild only if `is_incremental()` returns true.  
D. `--full-refresh` affects snapshots, not models.

## Question 36
A YAML file contains:

```yaml
models:
  - name: fct_orders
    columns:
      - name: order_id
        tests:
          - unique
          - not_null
      - name: status
    tests:
      - relationships:
          to: ref('dim_status')
          field: status
```

Compilation fails.

What is the best diagnosis?

A. `relationships` is misplaced because it should usually be attached to a column, not the model-level `tests` block in this form.  
B. `unique` and `not_null` cannot be combined.  
C. `ref()` cannot be used in YAML.  
D. Model-level tests are never allowed.

## Question 37
A team wants to run only a representative subset of data for faster development validation.

Which flag is intended for that purpose?

A. `--empty`  
B. `--sample`  
C. `--defer`  
D. `--fail-fast`

## Question 38
A model `mart_revenue` depends on `int_orders`, which depends on `stg_orders`. You run:

`dbt run --select +mart_revenue`

What is selected?

A. Only `mart_revenue`  
B. `mart_revenue` and all its downstream children  
C. `mart_revenue` and all upstream parents  
D. Only direct parents of `mart_revenue`

## Question 39
A developer sees:

`Runtime Error
  Database Error in model mart_customer_ltv
  column "customer_segment" does not exist`

The compiled SQL in `target/compiled` still references `customer_segment`, even though the upstream staging model was edited to rename it to `segment`.

What is the best next step?

A. Inspect the downstream compiled SQL and lineage to find where the old column reference still exists.  
B. Delete `manifest.json`; dbt never recompiles otherwise.  
C. Replace all `ref()` calls with hard-coded schemas.  
D. Run `dbt docs generate` because docs compilation fixes SQL references.

## Question 40
A project has both source freshness and source tests configured. The team runs `dbt build`.

What should they expect?

A. `dbt build` includes freshness checks automatically.  
B. `dbt build` runs source tests, but freshness is a separate command concern.  
C. `dbt build` runs freshness only if tests pass.  
D. `dbt build` skips all source-related nodes.

## Question 41
A model version is deprecated but still available. A downstream model explicitly calls `ref('dim_product', version=1)`.

What is the best statement?

A. The ref fails immediately because deprecated versions cannot be referenced.  
B. The ref can still resolve if that version remains defined and enabled.  
C. dbt silently upgrades the ref to the latest version.  
D. Versioned refs are only supported in Python models.

## Question 42
A team wants to rerun only nodes that failed in the immediately previous invocation, without manually reconstructing selectors.

Which command best fits?

A. `dbt retry`  
B. `dbt clone`  
C. `dbt show`  
D. `dbt seed --full-refresh`

## Question 43
A Python model is introduced into a project. A developer assumes it can be used anywhere a SQL model can be used, regardless of adapter support.

What is the best correction?

A. Python models depend on adapter/platform support and are not universally available in every dbt execution context.  
B. Python models are compiled into SQL automatically on unsupported adapters.  
C. Python models can only be used for seeds.  
D. Python models cannot reference other dbt nodes.

## Question 44
A test is configured with:

```yaml
config:
  severity: error
  warn_if: ">0"
  error_if: ">100"
```

The test returns 5 failing rows.

What is the best outcome?

A. Error, because severity is error and there are failures  
B. Warn, because 5 exceeds `warn_if` but not `error_if`  
C. Pass, because 5 is below 100  
D. Compilation error, because `warn_if` and `error_if` cannot be combined

## Question 45
A developer wants to compare their branch with remote `main` and then integrate changes while preserving a linear history.

Which Git action is most aligned with that goal after fetching?

A. Merge `origin/main` into the branch  
B. Rebase the branch onto `origin/main`  
C. Force-push `main` into the branch  
D. Cherry-pick the latest manifest

## Question 46
A model uses `on_schema_change='append_new_columns'`. An upstream source adds a new column.

What is the best interpretation?

A. dbt may append the new column to the target relation during incremental processing, depending on adapter behavior and materialization context.  
B. dbt always backfills historical values for the new column.  
C. dbt ignores the new column until full refresh.  
D. This config applies only to snapshots.

## Question 47
A team wants a clean DAG where business logic is reusable and marts stay focused on presentation-level outputs.

Which layering choice is best?

A. Put all joins and business rules directly in marts to reduce model count  
B. Use staging for source cleanup, intermediate for reusable business transformations, and marts for final business-facing outputs  
C. Use only ephemeral models to keep the DAG small  
D. Put raw source declarations in marts to keep lineage close to consumers

## Question 48
A developer runs:

`dbt build --select state:modified+ --defer`

but forgets to provide a valid state manifest path.

What is the best conclusion?

A. `--defer` can still work because dbt infers state from the current target schema.  
B. Deferral behavior depends on state artifacts; without valid state, the intended deferred resolution cannot work correctly.  
C. dbt automatically downloads the latest production manifest.  
D. `state:modified+` replaces the need for state artifacts.

## Question 49
A source test and a model test both fail during `dbt build`. The team wants to understand why some downstream nodes never started.

What is the best explanation?

A. `dbt build` orchestrates across node types, and failures can block downstream execution according to DAG dependencies and run order.  
B. Only model failures affect downstream execution; test failures are informational.  
C. Source tests run after all downstream models complete.  
D. dbt always builds the full DAG before evaluating any tests.

## Question 50
A developer sees:

`Compilation Error in schema file models/mart/orders.yml
  while parsing a block mapping
  expected <block end>, but found '-'`

What is the most likely issue?

A. A warehouse adapter returned malformed YAML.  
B. The YAML indentation or list structure is invalid.  
C. A model contract failed at runtime.  
D. A singular test returned multiple columns.

## Question 51
A team wants to document a downstream dashboard that depends on a mart model and indicate ownership.

What dbt construct best fits?

A. Exposure  
B. Seed  
C. Snapshot  
D. Constraint

## Question 52
A model references `{{ this }}` inside an incremental filter.

What does `{{ this }}` represent in that context?

A. The upstream parent relation selected by `ref()`  
B. The current model’s relation in the target database/schema  
C. The compiled SQL text of the current model  
D. The manifest entry for the current node

## Question 53
A project uses `dbt build --select state:modified+ --state prod_artifacts --defer` in Slim CI. A changed model has an unchanged child test node.

Why might that test still run?

A. Because graph expansion from selected modified nodes can include associated downstream test nodes relevant to selected resources  
B. Because `--defer` forces all tests in the project to run  
C. Because unchanged tests are always excluded in state selection  
D. Because tests ignore selectors and always run after models

## Question 54
A developer wants to override package behavior only for one adapter while preserving default behavior elsewhere.

What is the best approach?

A. Rename every macro call in the project  
B. Use dispatch / adapter-specific macro resolution  
C. Replace the package with seeds  
D. Use `grants` in `dbt_project.yml`

## Question 55
A model is configured as incremental with microbatch strategy support on the adapter. The dataset is extremely large and naturally partitioned by event time.

Why might microbatch be preferable to a single large incremental merge?

A. It can process data in smaller time-based chunks, which may improve manageability and performance characteristics on supported platforms.  
B. It guarantees zero cost.  
C. It removes the need for a unique key in all cases.  
D. It behaves identically to `view` materialization but faster.

## Question 56
A developer runs `git pull` on a feature branch with local commits and gets conflicts immediately.

Why might `git fetch` have been a safer first step?

A. `git fetch` updates remote-tracking information without modifying the current branch working state.  
B. `git fetch` automatically resolves merge conflicts.  
C. `git fetch` rebases local commits by default.  
D. `git fetch` deletes stale local branches.

## Question 57
A model test uses:

```yaml
- not_null:
    config:
      where: "loaded_at >= current_date - 1"
```

What is the main effect?

A. The model itself is filtered to one day of data before materialization.  
B. The test evaluates only rows matching that condition.  
C. The source freshness window is reduced to one day.  
D. The test stores failures for one day only.

## Question 58
A team wants to ensure a model’s columns and types remain stable for downstream consumers, while also introducing a new version for breaking changes.

Which combination best fits?

A. Contracts for shape enforcement, plus model versioning for controlled breaking changes  
B. Exposures plus seeds  
C. Source freshness plus `dbt clone`  
D. `store_failures` plus `warn_if`

## Question 59
A developer runs:

`dbt build --select 1+fct_revenue`

What is selected?

A. `fct_revenue` and only its first-degree parents  
B. `fct_revenue` and all parents recursively  
C. Only first-degree children of `fct_revenue`  
D. `fct_revenue`, its parents, and its tests only

## Question 60
A debugging session shows:

`Database Error in test relationships_fct_orders_customer_id__customer_id__ref_dim_customers_
  insert or update on table violates foreign key constraint`

The team already has both a `relationships` test and a platform constraint.

What is the best interpretation?

A. The dbt test and the platform constraint are redundant, so one of them must be invalid.  
B. Both mechanisms can surface related integrity issues from different enforcement layers.  
C. The error proves the generic test passed.  
D. Constraints prevent dbt tests from running.

## Question 61
A team wants to use `dbt_project.yml` to set default materialization for all models in `models/intermediate/`, while allowing one model to override it locally.

What is the best statement?

A. Local model config can override broader project-level defaults.  
B. `dbt_project.yml` always overrides model-level config.  
C. Folder-level config applies only to seeds.  
D. Materialization cannot be configured by path.

## Question 62
A CI job uses `state:modified` without `+`. A changed intermediate model builds, but its downstream mart does not.

Why?

A. `state:modified` selects modified nodes only; without graph expansion, unchanged downstream dependents are not included.  
B. `state:modified` always includes children, but marts are excluded by default.  
C. `state:modified` works only with tests.  
D. `--defer` is required for any downstream selection.

## Question 63
A developer wants to validate that a source table is fresh enough before stakeholders rely on a dashboard, and also document that dashboard in the project.

Which pair best fits?

A. Source freshness and exposure  
B. Snapshot and seed  
C. Contract and version  
D. Retry and clone

## Question 64
A project has a custom generic test macro. A developer places the macro correctly, but dbt says the test is undefined when referenced in YAML.

What is the best likely cause?

A. The macro name and the YAML test name do not align with dbt’s expected custom generic test naming pattern.  
B. Custom generic tests can only be defined in `dbt_project.yml`.  
C. Generic tests cannot accept arguments.  
D. The model must be materialized as table, not view.

## Question 65
A CI pipeline uses:

`dbt build --select state:modified+ --state prod_artifacts --defer --empty`

A changed mart model, an unchanged upstream parent, and several tests are involved. The run succeeds, but a developer concludes this proves the full production data path is valid.

What is the best correction?

A. Correct, because `--empty` validates both logic and full data quality semantics against production-sized data.  
B. Incorrect, because this setup is useful for structural and dependency validation, but it does not prove full data-volume behavior or all data-quality outcomes.  
C. Correct, because `--defer` guarantees production-equivalent execution.  
D. Incorrect only if the model is incremental.
