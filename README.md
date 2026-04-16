# Obelisk

### RDBMS for the Urbit computer

* Time traveling databases, every database state is indexed by time.

* Queries are (implicitly) idempotent, thanks to indexed database states.

* Tables, views, and query results are always proper sets of the data rows.

* No NULLS, anywhere, ever.

* Scripts are atomic (pass/fail)

Obelisk employs a dialect of SQL called "urQL" that provides for these properties.

See [Reference/Preliminaries](/desk/doc/usr/reference/01-preliminaries.md) and the [Users Guide](/desk/doc/sur/users-guide.md) in the docs folder for more information.

### Using the %hawk UI

To interact with Obelisk from %hawk:

- Ensure you have %hawk installed
  `|install ~dister-migrev-dolseg %hawk`
- Create an "obelisk" file sibling to the manual in your hawk namespace.
- Get the latest Obelisk UI template from templates/hawk.hoon in this repo or from https://hawk.computer/~~/templates/ (not guaranteed to be current). Paste the contents into the obelisk hawk file.

Now clicking the Obelisk landscape tile will take you to the Obelisk UI, with UX similar to SQL Studio.

Be patient with the Obelisk UI. It is still beta and under development. You will find the same actions from the %dojo execute much faster. Still the UI is the recommended interface for most direct user interactions with the %obelisk desk.

### Beta release

The beta release is not compatible with any manually installed alpha releases.

### Sample database

This repository includes a sample database, "animal-shelter", derived from https://github.com/ami-levin/Animal_Shelter.

The recommended way to install the sample database is from the %dojo:

:obelisk &obelisk-action [%tape2 %animal-shelter (reel .^(wain %cx /=obelisk=/gen/animal-shelter/all-animal-shelter/txt) |=([a=cord b=tape] (weld (trip a) b)))]

Depending on your system it will load in about 30 - 40 seconds.

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