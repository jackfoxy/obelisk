# Obelisk

### RDBMS for the Urbit computer

* Time traveling databases, every database state is indexed by time.

* Queries are (implicitly) idempotent, thanks to indexed database states.

* Query results are proper sets of the result rows.

* No NULLS, anywhere, ever.

Obelisk employs a dialect of SQL called urQL that provides for these properties.

See References/Preliminaries and the Users Guide in the docs folder for more information.

### Sample database

This repository includes a sample database, "animal-shelter", derived from https://github.com/ami-levin/Animal_Shelter.  

### Bug reporting

Reporting bugs is encouraged and appreciated. Please open an issue with a minimal urQL script reproducing the bug using the sample database, or if it's not possible to reproduce in the sample database provide the full DDL and other commands to reproduce.

Reporting documentation bugs is also appreciated.