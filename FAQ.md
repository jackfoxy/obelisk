# Frequently Asked Questions

If you don't find your question here, open an issue or contact us directly.

## Why would I want to use Obelisk?

1) Implementing Obelisk as your data store provides search capability "out of the box". Obelisk's scripting language is a dialect of SQL, the most powerful database language there is. Dynamically generate urQL queries or use the Obelisk API directly. (But protect yourself from SQL injection attacks, just like you must do in other programming environments.) Search your data and/or mixed data sets with the full power of first order predicate calculus.

2) Mash-up your app's data with data from other apps and personal data. Obelisk allows for cross-database queries and someday even cross-server (cross-ship) queries.

3) Reliance on a data store that provides for good data hygiene. Obelisk provides not only for storing data using the relational model, but unlike other SQL databases, Obelisk data sets are always proper sets. Full relational integrity is on [the roadmap](roadmap.md).

4) Never lose your data. Obelisk's unique time travelling capability means if you delete or overwrite the wrong data you can always recover.

5) Built in auditing of content and schema changes via Obelisk time travelling.

## How can I get familiar with Obelisk?

Obelisk comes with a sample database and instructions on loading it in the [Users Guide](docs/users-guide.md).

It also integrates with the popular %hawk app which provides an ad hoc scripting environment much like popular "SQL Studio" apps. Get the latest [Obelisk UI](https://hawk.computer/~~/templates/obelisk-ui/).

Read [the Preliminaries document](docs/reference/01-preliminaries.md), especially the last section on *Time* to understand Obelisk's unique time travelling capabilities.

## I tried Obelisk for my database and some queries were too slow.

The second beta release of Obelisk will include user-defined views.

Obelisk's unique time-travelling capability provides for all SELECT queries being implicitly idempotent. This allows us to cache view results, meaning that whenever underlying content changes there is a one-time performance hit while the system performs a raw SELECT query and caches the results. We believe this will result in sub-half-second queries on views.

In principle there is no reason we cannot cache every SELECT query's results and look-up whether a query has been cached.

That being said, we are always working on improving Obelisk's query plan execution performance.

## Relying on an app for the database of another app and/or my important personal data seems sketchy.

We are talking to the Urbit Foundation about integrating the Obelisk RDBMS directly into Urbit by making Obelisk a vane. Reach out to us about this and let the foundation know you want a time-travelling RDBMS vane.

## I need RDBMS functionality missing in Obelisk.

Take a look at [the roadmap](roadmap.md). Chances are the functionality you require is there. Open an issue or contact us directly and we will prioritize it.

## I want to store my app's data in Obelisk, but my data model is complex.

Reach out to us. We can provide assistance in normalizing an RDBMS data model for you. [The roadmap](roadmap.md) includes permitting columns of non-atomic nouns. If this would be helpful for you we can prioritize.

## What about security?

Currently Obelisk can only be accessed from the host ship. [The roadmap](roadmap.md) includes a fine-grained security model for foreign ship access. If this would be helpful for you we can prioritize. You can still expose your Obelisk data through a publicly available app, c.f. the question about SQL injection.

## How can I protect my app from SQL injection?

You may want to allow injection of some SQL commands in your app. The general solution is to submit your script to the Obelisk parser which returns a list of Obelisk API commands. Filter on the commands you want to allow and submit those for execution, or construct API commands directly.

## Can Obelisk do \__?

RTFM. Obelisk has comprehensive reference documents and Users Guide. If any SQL RDBMS can do it, Obelisk can or it is on [the roadmap](roadmap.md).

And Obelisk can do much more, like built it data recovery and change auditing. And because data sets are always proper sets data hygeine is better than any other SQL database.
