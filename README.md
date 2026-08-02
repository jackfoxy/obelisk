# Obelisk

##### |install ~dister-nomryg-nilref %obelisk

### RDBMS for the Urbit computer

* Time traveling databases, every database state is indexed by time.

* Queries are (implicitly) idempotent, thanks to indexed database states.

* Tables, views, and query results are always proper sets of the data rows.

* No NULLS, anywhere, ever.

* Scripts are atomic (pass/fail)

Obelisk employs a dialect of SQL called "urQL" that provides for these properties.

For more information see
[Reference/Preliminaries](/desk/doc/usr/reference/preliminaries.md), the
[Users Guide](/desk/doc/usr/users-guide.md), and the USTJ article
[Obelisk: Reinventing SQL for Modern Computing](https://urbitsystems.tech/article/v03-i01/obelisk-reinventing-sql-for-modern-computing).

### Native web interface

The Obelisk desk includes a native Sail workbench. Click the Obelisk tile or
visit `/apps/obelisk` on your ship. No external UI app is required.

The workbench supports Run, Parse, schema browsing, multiple editor tabs,
Clay-backed script and result files, result paging, copying, and delimited
exports. See the [Users Guide](/desk/doc/usr/users-guide.md) for the interface
and dojo workflows.

### Beta release

Installing the beta release will overwrite state from previous manually installed alpha releases. All releases going forward will migrate state.

### Sample database

This repository includes a sample database, "animal-shelter", derived from https://github.com/ami-levin/Animal_Shelter.

The animal-shelter database comes installed, but should you drop it and wish to reinstall from the %dojo:

:obelisk &obelisk-action [%tape %animal-shelter (reel .^(wain %cx /=obelisk=/gen/animal-shelter/all-animal-shelter/txt) |=([a=cord b=tape] (weld (trip a) b)))]

Depending on your system it will load in about 30 seconds.

You can submit the same script through the native web interface, but the dojo
is recommended for this large initial import.

### Developers

Copy sur/obelisk-ast.hoon to your project to work with Obelisk results.

You are free to poke the %obelisk desk with urQL via the %tape or %tape-print actions or use the API defined in sur/obelisk-ast.hoon and poke via %commands. There are no scries.

You can also read directly from the server state, although this is not recommended. If you update the server state directly, you are on your own, in other words "strongly discouraged".

### Bug reporting

Reporting bugs is encouraged and appreciated. Please open an issue with a minimal urQL script reproducing the bug using the sample database, or if it's not possible to reproduce in the sample database provide the full DDL and urQL script to reproduce.

Reporting documentation bugs is also appreciated.

### Contributions

This project welcomes contributors. Contact the author for more information.

Thanks to @widmes-hassen for his contributions to scalar functions.

### Roadmap

See [the roadmap](/roadmap.md) for upcoming functionality.

Your feedback helps determine the future of Obelisk.
