# Obelisk

|install ~dister-nomryg-nilref %obelisk

### RDBMS for the Urbit computer

* Time traveling databases, every database state is indexed by time.

* Queries are (implicitly) idempotent, thanks to indexed database states.

* Tables, views, and query results are always proper sets of the data rows.

* No NULLS, anywhere, ever.

* Scripts are atomic (pass/fail)

Obelisk employs a dialect of SQL called "urQL" that provides for these properties.

See [Reference/Preliminaries](/desk/doc/usr/reference/01-preliminaries.md) and the [Users Guide](/desk/doc/sur/users-guide.md) in the docs folder for more information.

### Using the %hawk UI

The best user experience with %obelisk directly comes with the preinstalled %hawk Obelisk UI: click the Obelisk landscape tile to open %hawk to Obelisk. UX is similar to SQL Studio. You can write and run scripts, save scripts and results, and open script templates.

You will find the same actions from the %dojo execute a little faster, the UI does add some overhead. Still the UI is the recommended interface for most direct user interactions with the %obelisk desk.

### Beta release

Installing the beta release will overwrite state from previous manually installed alpha releases. All releases going forward will migrate state.

### Sample database

This repository includes a sample database, "animal-shelter", derived from https://github.com/ami-levin/Animal_Shelter.

The animal-shelter database comes installed, but should you drop it and wish to reinstall from the %dojo:

:obelisk &obelisk-action [%tape2 %animal-shelter (reel .^(wain %cx /=obelisk=/gen/animal-shelter/all-animal-shelter/txt) |=([a=cord b=tape] (weld (trip a) b)))]

Depending on your system it will load in about 30 seconds.

You can also install it from the %hawk UI, but this will be much slower and is not recommended.

### Developers

Copy sur/ast/hoon to your project to work with Obelisk results.

You are free to poke the %obelisk desk with urQL via the %tape or %tape2 actions or use the API defined in sur/ast/hoon and poke via %commands. There are no scries.

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