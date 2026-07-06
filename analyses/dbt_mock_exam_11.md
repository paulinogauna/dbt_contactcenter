# Advanced dbt Mock Exam 11

## Question 1
A CI job runs `dbt build --select state:modified+ --state path/to/prod_artifacts --defer`. A changed mart model depends on an unchanged intermediate model that is not selected in CI.

Why can the mart model still resolve its upstream dependency?

A. `state:modified+` automatically rebuilds all unchanged parents in the CI schema before execution.

B. `--defer` allows unresolved references for unselected upstream nodes to point to relations from the state environment.

C. `--state` rewrites all `ref()` calls to production relations regardless of selection.

D. `dbt build` ignores missing upstream relations whenever a manifest is supplied.

## Question 2
An incremental model uses `incremental_strategy='merge'`, `unique_key='order_id'`, and this filter:

```sql
{% if is_incremental() %}
where updated_at >= (select max(updated_at) from {{ this }})
{% endif %}
```

Some corrected source rows arrive late with an `updated_at` older than the current maximum in the target table.

What is the best conclusion?

A. The model will fail because `merge` requires monotonically increasing timestamps.

B. The model will still capture all corrections because `unique_key` guarantees historical reprocessing.

C. Some corrected rows may be missed unless the incremental filter or strategy is adjusted.

D. dbt automatically switches to `microbatch` when it detects late-arriving updates.

## Question 3
You are on a feature branch and want to inspect remote changes from `main` before deciding whether to merge or rebase.

What is the best first step?

A. `git fetch`

B. `git pull`

C. `git push --force-with-lease`

D. `git checkout main`

## Question 4
A model contains:

```sql
select *
from analytics.stg_orders
```

There is a project model named `stg_orders.sql`, but build order is inconsistent in clean environments.

What change best fixes the dependency issue?

A. Replace `analytics.stg_orders` with `{{ source('analytics', 'stg_orders') }}`

B. Replace `analytics.stg_orders` with `{{ ref('stg_orders') }}`

C. Add `depends_on: ['stg_orders']` in `dbt_project.yml`

D. Materialize `stg_orders` as `ephemeral`

## Question 5
A legacy query references raw tables `customers`, `orders`, `nation`, and `region`, all from the same database and schema.

How should these dependencies typically be declared in `sources.yml`?

A. Four sources with one table each

B. One source with four tables

C. One source with one table and three exposures

D. Four sources with four tables each

## Question 6
You want to materialize `my_model` and only its direct parent models.

Which command is correct?

A. `dbt run --select 1+my_model`

B. `dbt run --select +1my_model`

C. `dbt run --select +my_model`

D. `dbt compile --select +1my_model`

## Question 7
A CI pipeline runs `dbt build --empty`. A `unique` test passes even though production data contains duplicates.

Why?

A. The test ran against an empty relation, so no duplicate rows existed to fail the assertion.

B. `--empty` skips all generic tests.

C. `unique` tests validate only YAML metadata under `--empty`.

D. `--empty` downgrades all test failures to warnings.

## Question 8
A table model has an enforced contract. The SQL now returns `integer` for `customer_id`, but the YAML contract still declares `string`.

What is the expected behavior?

A. dbt silently casts the warehouse output to match the YAML contract.

B. The model may fail because the enforced contract checks the built model shape against the declared schema.

C. The model succeeds, but `dbt docs generate` fails later.

D. Only downstream models fail if they use `ref()`.

## Question 9
A model is versioned with `latest_version: 2`. Existing downstream models still call `ref('dim_customer')` without specifying a version.

What happens by default?

A. They fail until every `ref()` is updated.

B. They resolve to version 1 until the old version is deprecated.

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

C. dbt truncates the target table before the merge to avoid ambiguity.

D. dbt converts the model to append mode for that run.

## Question 13
A developer runs `dbt run --select tag:nightly` and expects tests on those models to run too.

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
A model using `{{ ref('stg_payments') }}` compiles successfully, but runtime fails with “relation does not exist”.

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
A model YAML includes:

```yaml
constraints:
  - type: not_null
    columns: [customer_id]
```

What is the best statement?

A. This always replaces the need for a `not_null` test.

B. This may enforce integrity at the platform level depending on adapter support, but it is not identical to dbt test behavior.

C. Constraints are documentation only.

D. Constraints can only be declared on sources.

## Question 19
A CI pipeline uses `state:modified` against a previous manifest. A developer changes only a macro used by many models.

What is the best expectation?

A. Only the macro node is selected.

B. Models affected by the macro change can be selected as modified.

C. `state:modified` works only for YAML changes.

D. Macro changes are ignored unless `--full-refresh` is set.

## Question 20
A snapshot uses `strategy: timestamp`, `updated_at: updated_at`, and `unique_key: customer_id`. Some source rows change without updating `updated_at`.

What is the most likely issue?

A. The snapshot still detects all changes because `unique_key` is present.

B. The snapshot may miss changes because timestamp strategy depends on the tracked timestamp changing.

C. dbt automatically falls back to `check` strategy.

D. The snapshot fails compilation because `updated_at` cannot be nullable.

## Question 21
A team wants to rerun only nodes that failed in the immediately previous invocation.

Which command best fits?

A. `dbt retry`

B. `dbt clone`

C. `dbt show --state target/`

D. `dbt docs generate --select result:error`

## Question 22
A model contains:

```sql
{{ config(materialized='incremental', unique_key='order_id') }}

select *
from {{ ref('stg_orders') }}
{% if is_incremental() %}
where order_date >= current_date - 7
{% endif %}
```

The business later requires corrections to orders older than 7 days to be reflected.

What is the best conclusion?

A. The current logic may miss older corrected rows unless the filter or reprocessing strategy changes.

B. `unique_key` guarantees all historical corrections are merged automatically.

C. `is_incremental()` causes dbt to scan the full source before applying the filter.

D. `dbt build` ignores the `where` clause on incremental runs.

## Question 23
A developer sees:

```text
Compilation Error
  Model 'model.contact_center.int_orders' depends on a source named 'stripe.payments' which was not found
```

What should be verified first?

A. Whether `stripe.payments` exists physically in the warehouse

B. Whether the source is declared with the correct source name and table name in YAML and the YAML file is in a parsed project path

C. Whether `dbt deps` was run

D. Whether the model should be incremental instead

## Question 24
A model uses `grants` to provide `select` access to an analyst role. The model builds, but the analyst still cannot query it.

What is the best explanation?

A. `grants` only affects docs metadata.

B. The adapter or warehouse may not support the grants behavior as configured, or the executing role may lack permission to grant privileges.

C. `grants` only works on views.

D. `grants` requires `contract.enforced: true`.

## Question 25
A team wants to inspect the result of a model query without materializing a persistent object.

Which command is best?

A. `dbt show --select my_model`

B. `dbt build --select my_model --empty`

C. `dbt docs generate --select my_model`

D. `dbt clone --select my_model`

## Question 26
A model is configured as `table` in `dbt_project.yml`, but the SQL file contains `{{ config(materialized='view') }}`.

Which materialization applies?

A. The project-level config always wins.

B. The inline model config wins because it is more specific.

C. dbt errors on conflicting materializations.

D. The warehouse default applies.

## Question 27
A team runs `dbt build --fail-fast`. An upstream model fails early.

What is the best interpretation?

A. dbt continues running tests for skipped downstream nodes.

B. dbt stops execution as soon as practical after the failure rather than continuing through the remaining selected nodes.

C. `--fail-fast` only affects tests.

D. `--fail-fast` converts warnings into errors.

## Question 28
A team wants to compare current code against production artifacts, build only changed nodes, and resolve unchanged parents from production if they are not rebuilt.

Which combination is best?

A. `--select state:modified --state prod_artifacts --defer`

B. `--select result:error --defer`

C. `--select +tag:prod --empty`

D. `--select state:new --full-refresh`

## Question 29
A unit test is added for a transformation. Another engineer says a generic test would be equivalent.

What is the best distinction?

A. Unit tests and generic tests are interchangeable because both validate rows after materialization.

B. Unit tests validate transformation logic with controlled inputs and expected outputs, while generic tests assert reusable data properties on built resources.

C. Generic tests are only for sources.

D. Unit tests require snapshots.

## Question 30
A developer runs `dbt build --select model_a+`. `model_a` succeeds, but one of its tests fails.

What is the best expectation for downstream execution?

A. Downstream models may be skipped because a failing test on an upstream selected node can block downstream execution in `dbt build`.

B. Downstream models always continue because tests are non-blocking.

C. Only singular tests can block downstream nodes.

D. Tests run after all downstream models complete.

## Question 31
A project manually overrides `generate_schema_name` for all environments. Another engineer suggests `generate_schema_name_for_env`.

Why might that be preferable?

A. It can simplify common environment-aware schema naming behavior with a more standard helper pattern.

B. It forces all developers to share one schema.

C. It disables custom aliases automatically.

D. It is required for `dbt build --empty`.

## Question 32
A developer sees:

```text
Database Error in model fct_revenue
  001003 (42000): SQL compilation error:
  syntax error line 27 at position 14 unexpected ')'
```

What is the best next step?

A. Inspect the compiled SQL for `fct_revenue` in the target compiled path.

B. Re-run `dbt deps`.

C. Delete `manifest.json`.

D. Convert the model to ephemeral.

## Question 33
A source test uses:

```yaml
config:
  severity: warn
  error_if: ">10"
  warn_if: ">0"
```

Three failing rows are returned.

What is the best outcome?

A. Error, because `error_if` exists

B. Warn, because the failure count meets `warn_if` but not `error_if`

C. Pass, because fewer than 10 rows failed

D. Error, because any nonzero failure count overrides severity

## Question 34
Which scenario best fits `dbt clone`?

A. Rebuilding only failed tests from the last run

B. Creating database objects in a target environment by cloning existing relations rather than recomputing them, where supported

C. Downloading packages from `packages.yml`

D. Copying Git branches into dbt Cloud

## Question 35
A model references a seed with `ref('country_codes')`. The seed file changes, but the downstream model is not selected in a narrow run.

What is the best statement?

A. The downstream model automatically updates because `ref()` propagates data changes without execution.

B. The downstream model must be rebuilt to reflect the changed seed data in its own materialized output.

C. Seeds cannot be referenced with `ref()`.

D. `dbt seed` rebuilds all downstream models automatically.

## Question 36
A developer wants to keep a long-lived feature branch current with `main` while inspecting incoming changes first.

Which sequence is best?

A. `git pull`, then inspect

B. `git fetch`, inspect, then merge or rebase intentionally

C. `git push`, then `git fetch`

D. `git checkout main`, then delete the feature branch

## Question 37
A model YAML file contains a formatting mistake. dbt returns:

```text
Parsing Error
  Error reading contact_center: int_orders.yml - Runtime Error
    Syntax error near line 14
```

What is the best interpretation?

A. The warehouse rejected generated SQL.

B. dbt failed before execution while parsing project files, so the issue is in YAML structure or syntax.

C. The model contract was violated after build.

D. A source freshness threshold was exceeded.

## Question 38
A team uses `dbt build --sample` for exploratory runs on large data.

Which statement is best?

A. `--sample` is intended to reduce processed data volume for supported workflows, but it does not imply identical behavior to a full production run.

B. `--sample` guarantees identical row counts to production.

C. `--sample` only affects tests.

D. `--sample` is equivalent to `--empty`.

## Question 39
A model is changed from unversioned to versioned. One downstream consumer must remain on the old shape temporarily, while new consumers should use the new shape.

What is the best approach?

A. Keep one model and rely only on contracts to preserve both shapes.

B. Create model versions and pin the legacy consumer with a versioned `ref`, while allowing unpinned consumers to resolve to the latest version.

C. Use `defer` so old consumers keep reading the old shape forever.

D. Replace `ref()` with hard-coded relation names.

## Question 40
A developer runs `dbt build --select state:modified+ --state prod_artifacts`. Unchanged upstream parents are not selected, and execution fails because those parents do not exist in the CI schema.

What is the best explanation?

A. `state` selection alone compares artifacts for selection, but it does not redirect unresolved references to another environment unless `--defer` is also used.

B. `state:modified+` always excludes parents.

C. `prod_artifacts` can only be used with `dbt docs generate`.

D. `dbt build` ignores manifests during CI.

## Question 41
A model has a generic `not_null` test on `customer_id` with:

```yaml
config:
  where: "order_date >= current_date - 3"
```

What is the best interpretation?

A. The test only evaluates rows matching the filter condition.

B. The model only materializes rows matching the filter condition.

C. The test stops after three days of runtime.

D. The filter applies only to warnings, not errors.

## Question 42
A team wants to ensure a reusable assertion that every fact table has a non-null surrogate key and a valid load timestamp.

What is the best implementation choice?

A. A singular test copied into every fact model folder

B. A custom generic test or reusable generic test pattern applied across models

C. A snapshot on every fact table

D. A `dbt show` query in CI

## Question 43
A developer changes only a column description in a model YAML file. CI uses `dbt build --select state:modified --state prod_artifacts`.

What is the best expectation?

A. The model can still be selected as modified because state comparison can include metadata changes.

B. The model cannot be selected because only SQL changes count.

C. Only tests are selected, never models.

D. dbt ignores YAML changes unless `dbt docs generate` is run first.

## Question 44
A model configured as incremental with `append` receives updates to existing rows in the source.

What is the most likely outcome?

A. Existing target rows are updated automatically because dbt compares hashes.

B. Updated source rows are appended as new rows unless the SQL logic prevents duplicates.

C. dbt raises an error because `append` requires immutable data.

D. dbt silently converts the strategy to `merge`.

## Question 45
A developer sees this error during parsing:

```text
Compilation Error
  Invalid test config given in models/marts/orders.yml:
  Additional properties are not allowed ('store_failure' was unexpected)
```

What is the best diagnosis?

A. The warehouse does not support persisted failures.

B. The YAML uses an invalid config key name.

C. The test query returned too many rows.

D. `store_failures` can only be used in SQL files.

## Question 46
A team wants to expose a BI dashboard as a downstream dependency of a mart model.

What dbt feature best fits?

A. Exposure

B. Snapshot

C. Seed

D. Constraint

## Question 47
A model references two upstream models with `ref()`. One upstream model is excluded from the run and does not exist in the target schema.

Without `--defer`, what is the best expectation?

A. The downstream model may fail at runtime because the excluded upstream relation is unavailable in the target environment.

B. `ref()` automatically materializes excluded parents.

C. dbt rewrites the missing parent to a source.

D. The downstream model succeeds because lineage is enough.

## Question 48
A team wants to validate that a source column contains only `web`, `store`, or `partner`.

Which test is the best fit?

A. `relationships`

B. `accepted_values`

C. `unique`

D. `not_null`

## Question 49
A developer runs `dbt build --select result:error --state target/` immediately after a successful run that overwrote `run_results.json`.

Why might the selector not behave as expected?

A. `result:error` depends on prior run results, and a successful run may overwrite the artifact that previously recorded failures.

B. `result:error` only works with seeds.

C. `result:error` ignores `--state`.

D. `run_results.json` is only used by `dbt docs generate`.

## Question 50
A model contract is enforced, and a developer adds an extra column in SQL that is not declared in the contract.

What is the best expectation?

A. The model may fail because the built shape no longer matches the declared contract.

B. dbt silently adds the column to the contract.

C. The extra column is ignored in the warehouse.

D. Only docs generation fails.

## Question 51
A project uses `packages.yml` to install `dbt_utils`. A developer adds a local macro with the same name as a `dbt_utils` macro to customize behavior.

What is the best statement?

A. The package macro always wins because package code is immutable.

B. The local macro can override the package macro in normal resolution order.

C. dbt refuses to parse the project.

D. The override only works if the package is removed.

## Question 52
A team wants to test a very large incremental model but only on recent data each run.

Which configuration is most appropriate for the test itself?

A. `where`

B. `store_failures`

C. `limit`

D. `severity`

## Question 53
A developer runs `dbt run --full-refresh --select fct_sessions`. The model is incremental.

What is the best interpretation?

A. dbt rebuilds the incremental model from scratch for that run.

B. dbt ignores `--full-refresh` unless `dbt build` is used.

C. dbt only refreshes downstream models.

D. dbt converts the model to a view permanently.

## Question 54
A source freshness check errors in production, but the same source passes its `not_null` and `unique` tests.

What is the best explanation?

A. Freshness and data tests evaluate different concerns; a source can be structurally valid yet too stale.

B. Freshness errors imply all source tests should also fail.

C. `not_null` and `unique` override freshness thresholds.

D. Freshness only runs when tests fail.

## Question 55
A developer wants to inspect the exact SQL generated by Jinja, macros, and refs for a failing model.

What artifact or location is most useful?

A. The compiled SQL in the target compiled directory

B. `packages.yml`

C. The seed CSV file

D. The exposure definition

## Question 56
A team has a model with many CTEs reused across several marts. They want to reduce duplication while keeping logic modular.

What is the best dbt-oriented approach?

A. Copy the same SQL into each mart to avoid extra nodes.

B. Extract reusable logic into upstream models or macros where appropriate, balancing DRY with maintainability.

C. Convert every CTE into a snapshot.

D. Replace all models with seeds.

## Question 57
A developer sees:

```text
Database Error in test relationships_fct_orders_customer_id__customer_id__ref_dim_customers_
  relation "analytics.dim_customers" does not exist
```

What is the best explanation?

A. The relationships test is checking a referenced relation that is unavailable in the current target environment.

B. The `relationships` test only works on sources.

C. The test failed because duplicate keys were found.

D. The model contract blocked the test.

## Question 58
A team wants to choose between `merge` and `append` for an incremental model. Source rows are mostly new inserts, but occasional updates to existing business keys occur.

What is the best choice?

A. `append`, because it is always correct when most rows are inserts

B. `merge`, because updates to existing rows need a strategy that can match and update target rows

C. `append`, because `merge` requires snapshots

D. `microbatch`, because any updates require it

## Question 59
A developer uses `source('stripe', 'payments')` in a model, but the raw table is later renamed in the warehouse. The YAML source definition is not updated.

What is the most likely result?

A. dbt automatically discovers the new raw table name.

B. The model may fail because the source declaration no longer matches the physical object.

C. `source()` falls back to `ref()`.

D. Only docs generation fails.

## Question 60
A team wants to keep answer choices in a mock exam from following obvious patterns.

Which design choice best supports that goal?

A. Make option B correct whenever the scenario mentions CI.

B. Distribute correct answers across options and use plausible distractors that differ by one critical dbt detail.

C. Make the longest option correct most of the time.

D. Use obviously wrong distractors to reduce ambiguity.

## Question 61
A developer runs `dbt build --select +model_b`. They expect only direct parents and `model_b` itself.

Why might that expectation be wrong?

A. `+model_b` selects only children.

B. `+model_b` includes all upstream ancestors, not just direct parents.

C. `+model_b` is invalid syntax.

D. Graph operators only work with `dbt test`.

## Question 62
A model YAML declares a `relationships` test from `fct_orders.customer_id` to `dim_customers.customer_id`. The dimension is versioned, and the fact model uses an unpinned `ref('dim_customers')`.

What is the best exam-style implication?

A. The test target follows the same resolution behavior as the referenced model relation, so version changes can affect which dimension object is validated unless refs are pinned.

B. `relationships` tests ignore model versioning.

C. Versioned models cannot be used in tests.

D. The test always points to version 1.

## Question 63
A developer wants to know whether a failure came from model execution or from a test executed during `dbt build`.

What is the best way to reason about it from logs?

A. Check whether the failing node is a model node or a test node in the run output and error context.

B. Any failure during `dbt build` is always a model failure.

C. Any failure after a model succeeds must be a snapshot failure.

D. `dbt build` does not log node types.

## Question 64
A team uses `dbt build --select state:modified+ --defer --state prod_artifacts` in Slim CI. A developer changes only a test configuration from `severity: error` to `severity: warn`.

What is the best expectation?

A. No nodes are selected because test config changes do not affect state.

B. Relevant test nodes can be selected as modified because configuration changes are part of state comparison.

C. Only seeds are selected.

D. `--defer` suppresses test selection.

## Question 65
A developer is deciding whether to use a singular test or a custom generic test for a rule that will be reused across many models with different column names.

What is the best choice?

A. Singular test, because reuse across models is easier with copied SQL files.

B. Custom generic test, because the rule is reusable and parameterizable across models and columns.

C. Snapshot, because snapshots are the reusable form of tests.

D. Exposure, because exposures document repeated logic.

---

# Answer Key

1. B  
2. C  
3. A  
4. B  
5. B  
6. B  
7. A  
8. B  
9. C  
10. A  
11. C  
12. B  
13. B  
14. B  
15. A  
16. B  
17. B  
18. B  
19. B  
20. B  
21. A  
22. A  
23. B  
24. B  
25. A  
26. B  
27. B  
28. A  
29. B  
30. A  
31. A  
32. A  
33. B  
34. B  
35. B  
36. B  
37. B  
38. A  
39. B  
40. A  
41. A  
42. B  
43. A  
44. B  
45. B  
46. A  
47. A  
48. B  
49. A  
50. A  
51. B  
52. A  
53. A  
54. A  
55. A  
56. B  
57. A  
58. B  
59. B  
60. B  
61. B  
62. A  
63. A  
64. B  
65. B

---

# Explanations for Selected Hard Questions

## Question 1
`--state` and `state:modified+` determine comparison and selection. `--defer` changes how unresolved upstream refs are resolved when those parents are not rebuilt in the current environment. That is the key distinction.

## Question 12
`unique_key` does not deduplicate the incoming source batch. If duplicate keys arrive in the same merge batch, behavior can fail or depend on the adapter and warehouse merge semantics.

## Question 15
`ref()` gives dependency tracking and relation naming abstraction, but it does not guarantee the referenced object physically exists in the current target schema. That is why compile success and runtime failure can coexist.

## Question 28
This is the classic Slim CI pattern: `--state` for comparison, `state:modified` for selection, and `--defer` for resolving unchanged upstream dependencies from another environment.

## Question 30
In `dbt build`, tests are part of orchestration. A failing upstream test can block downstream execution, which is a common exam trap when comparing `dbt build` with separate `dbt run` and `dbt test` workflows.

## Question 49
`result:error` depends on prior run results. If a later successful run overwrites `run_results.json`, the failure context you expected to select from may no longer be present.

## Question 62
Versioning can affect which relation an unpinned `ref()` resolves to. If a test depends on that relation, version changes can alter what object is being validated unless the reference is pinned explicitly.
